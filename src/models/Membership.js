const pool = require("../../db");

/**
 * Resolve any supported user identifier to the PUBLIC user_login.user_id.
 *
 * Supported:
 *   MGU26092205
 *   19
 *   20
 *   23
 *   131            <-- old internal user_login.id
 *
 * IMPORTANT:
 * user_memberships.user_id now stores the PUBLIC user_login.user_id.
 */
const resolvePublicUserId = async (userId, client = pool) => {
  if (
    userId === null ||
    userId === undefined ||
    userId === ""
  ) {
    return null;
  }

  const value = String(userId).trim();

  /*
   * FIRST:
   * Try the value directly against public user_login.user_id.
   *
   * This is important because some older public IDs are numeric,
   * such as "19", "20", "21", "23".
   */
  const publicResult = await client.query(
    `
    SELECT
      id,
      user_id
    FROM user_login
    WHERE user_id = $1
      AND is_active = true
    LIMIT 1
    `,
    [value]
  );

  if (publicResult.rows[0]) {
    return publicResult.rows[0].user_id;
  }

  /*
   * SECOND:
   * Backward compatibility for callers that still pass
   * the internal numeric user_login.id.
   */
  if (/^\d+$/.test(value)) {
    const internalResult = await client.query(
      `
      SELECT
        id,
        user_id
      FROM user_login
      WHERE id = $1
        AND is_active = true
      LIMIT 1
      `,
      [Number(value)]
    );

    if (internalResult.rows[0]) {
      return internalResult.rows[0].user_id;
    }
  }

  return null;
};


/**
 * Resolve any supported user identifier to the INTERNAL
 * user_login.id.
 *
 * This is ONLY used where the database still requires the
 * internal numeric ID.
 *
 * Currently:
 * membership_wallet_transactions.user_id
 *     -> FK -> user_login.id
 */
const resolveInternalUserId = async (
  userId,
  client = pool
) => {
  if (
    userId === null ||
    userId === undefined ||
    userId === ""
  ) {
    return null;
  }

  const value = String(userId).trim();

  /*
   * First try the value as a PUBLIC user_login.user_id.
   */
  const publicResult = await client.query(
    `
    SELECT id
    FROM user_login
    WHERE user_id = $1
      AND is_active = true
    LIMIT 1
    `,
    [value]
  );

  if (publicResult.rows[0]) {
    return publicResult.rows[0].id;
  }

  /*
   * Backward compatibility:
   * caller may already be passing user_login.id.
   */
  if (/^\d+$/.test(value)) {
    const internalResult = await client.query(
      `
      SELECT id
      FROM user_login
      WHERE id = $1
        AND is_active = true
      LIMIT 1
      `,
      [Number(value)]
    );

    if (internalResult.rows[0]) {
      return internalResult.rows[0].id;
    }
  }

  return null;
};


/**
 * Create a new membership.
 *
 * user_memberships.user_id stores PUBLIC user_login.user_id.
 */
const createMembership = async ({
  userId,
  planId,
  paymentId,
  walletBalance,
  discountPercent,
  monthlyClaim,
  expiryDate,
  termsAndConditions = false,
  assignedBy = null,
  assignedRole = null,
  referralCode = null,
}) => {
  const resolvedPublicUserId =
    await resolvePublicUserId(userId);

  if (!resolvedPublicUserId) {
    throw new Error("User not found");
  }

  /*
   * Expire previous active membership.
   */
  await pool.query(
    `
    UPDATE user_memberships
    SET
      status = 'EXPIRED',
      updated_at = NOW()
    WHERE
      user_id = $1
      AND status = 'ACTIVE'
    `,
    [resolvedPublicUserId]
  );

  /*
   * Create new membership using PUBLIC user ID.
   */
  const result = await pool.query(
    `
    INSERT INTO user_memberships
    (
      user_id,
      plan_id,
      payment_id,
      wallet_balance,
      discount_percent,
      monthly_claim,
      expiry_date,
      terms_and_conditions,
      assigned_by,
      assigned_role,
      referral_code
    )
    VALUES
    ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
    RETURNING *;
    `,
    [
      resolvedPublicUserId,
      planId,
      paymentId,
      walletBalance,
      discountPercent,
      monthlyClaim,
      expiryDate,
      termsAndConditions,
      assignedBy,
      assignedRole,
      referralCode,
    ]
  );

  return result.rows[0];
};


/**
 * Get active membership.
 *
 * user_memberships.user_id is PUBLIC user ID.
 */
const getActiveMembership = async (userId) => {
  const resolvedPublicUserId =
    await resolvePublicUserId(userId);

  if (!resolvedPublicUserId) {
    return null;
  }

  const result = await pool.query(
    `
    SELECT
      um.*,
      sp.plan_name,
      sp.plan_price,
      sp.wallet_bonus,
      sp.discount_percentage,
      sp.monthly_claim,
      sp.monthly_limit_litres,
      sp.validity_months
    FROM user_memberships um

    INNER JOIN subscription_plans sp
      ON sp.id = um.plan_id

    WHERE
      um.user_id = $1
      AND um.status = 'ACTIVE'

    ORDER BY um.id DESC

    LIMIT 1
    `,
    [resolvedPublicUserId]
  );

  return result.rows[0];
};


/**
 * Get membership wallet and transactions.
 */
const getMembershipWallet = async (userId) => {
  const resolvedPublicUserId =
    await resolvePublicUserId(userId);

  if (!resolvedPublicUserId) {
    return null;
  }

  const membershipResult = await pool.query(
    `
    SELECT
      um.id AS membership_id,
      um.user_id,
      um.status,
      um.wallet_balance,
      um.monthly_claim,
      um.monthly_claim_used,
      um.expiry_date,

      sp.plan_name,
      sp.plan_price,
      sp.wallet_bonus,
      sp.discount_percentage,
      sp.monthly_claim AS plan_monthly_claim

    FROM user_memberships um

    INNER JOIN subscription_plans sp
      ON sp.id = um.plan_id

    WHERE
      um.user_id = $1
      AND um.status = 'ACTIVE'

    ORDER BY um.id DESC

    LIMIT 1
    `,
    [resolvedPublicUserId]
  );

  if (membershipResult.rows.length === 0) {
    return null;
  }

  const membership =
    membershipResult.rows[0];

  const transactionResult = await pool.query(
    `
    SELECT
      mwt.id,
      mwt.order_id,
      mwt.transaction_type,
      mwt.amount,
      mwt.balance_after,
      mwt.description,
      mwt.created_at

    FROM membership_wallet_transactions mwt

    WHERE
      mwt.membership_id = $1

    ORDER BY
      mwt.created_at DESC,
      mwt.id DESC
    `,
    [membership.membership_id]
  );

  const walletBonus =
    Number(membership.wallet_bonus || 0);

  const walletBalance =
    Number(membership.wallet_balance || 0);

  const usedWalletAmount =
    Math.max(
      0,
      walletBonus - walletBalance
    );

  return {
    membership: {
      id: membership.membership_id,

      /*
       * Return PUBLIC ID to the application.
       */
      userId: resolvedPublicUserId,

      status: membership.status,

      planName: membership.plan_name,

      planPrice:
        Number(membership.plan_price || 0),

      walletBonus,

      walletBalance,

      usedWalletAmount,

      monthlyClaim:
        Number(
          membership.monthly_claim ||
          membership.plan_monthly_claim ||
          0
        ),

      monthlyClaimUsed:
        Number(
          membership.monthly_claim_used || 0
        ),

      discountPercentage:
        Number(
          membership.discount_percentage || 0
        ),

      expiryDate:
        membership.expiry_date,
    },

    transactions:
      transactionResult.rows.map(
        (transaction) => ({
          id: transaction.id,

          orderId:
            transaction.order_id,

          type:
            transaction.transaction_type,

          amount:
            Number(transaction.amount),

          balanceAfter:
            Number(
              transaction.balance_after
            ),

          description:
            transaction.description,

          createdAt:
            transaction.created_at,
        })
      ),
  };
};


/**
 * Update membership usage after an order.
 *
 * user_memberships.user_id:
 *     PUBLIC ID
 *
 * membership_wallet_transactions.user_id:
 *     INTERNAL user_login.id
 */
const updateMembershipUsage = async ({
  userId,
  litresUsed,
  walletUsed,
  orderId,
}) => {
  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    /*
     * Resolve PUBLIC membership ID inside the same
     * transaction/connection.
     */
    const resolvedPublicUserId =
      await resolvePublicUserId(
        userId,
        client
      );

    if (!resolvedPublicUserId) {
      throw new Error("User not found");
    }

    /*
     * Resolve INTERNAL ID specifically for
     * membership_wallet_transactions.user_id.
     */
    const resolvedInternalUserId =
      await resolveInternalUserId(
        resolvedPublicUserId,
        client
      );

    if (!resolvedInternalUserId) {
      throw new Error(
        "Internal user ID not found"
      );
    }

    /*
     * Lock the active membership.
     */
    const membershipResult =
      await client.query(
        `
        SELECT
          id,
          wallet_balance
        FROM user_memberships
        WHERE
          user_id = $1
          AND status = 'ACTIVE'
        ORDER BY id DESC
        LIMIT 1
        FOR UPDATE
        `,
        [resolvedPublicUserId]
      );

    if (
      membershipResult.rows.length === 0
    ) {
      throw new Error(
        "Active membership not found"
      );
    }

    const membership =
      membershipResult.rows[0];

    /*
     * Update membership usage.
     */
    const result =
      await client.query(
        `
        UPDATE user_memberships
        SET
          used_litres =
            used_litres + $1,

          monthly_claim_used =
            monthly_claim_used + $2,

          wallet_balance =
            wallet_balance - $2,

          updated_at = NOW()

        WHERE id = $3

        RETURNING *;
        `,
        [
          litresUsed,
          walletUsed,
          membership.id,
        ]
      );

    const updatedMembership =
      result.rows[0];

    /*
     * Create wallet transaction.
     *
     * IMPORTANT:
     * This table still has FK:
     *
     * membership_wallet_transactions.user_id
     *     -> user_login.id
     *
     * Therefore we intentionally store the
     * INTERNAL numeric ID here.
     */
    if (Number(walletUsed) > 0) {
      await client.query(
        `
        INSERT INTO membership_wallet_transactions
        (
          membership_id,
          user_id,
          order_id,
          transaction_type,
          amount,
          balance_after,
          description
        )
        VALUES
        ($1, $2, $3, 'DEBIT', $4, $5, $6)
        `,
        [
          updatedMembership.id,
          resolvedInternalUserId,
          orderId,
          Number(walletUsed),
          Number(
            updatedMembership.wallet_balance
          ),
          `Used for Order #${orderId}`,
        ]
      );
    }

    await client.query("COMMIT");

    return updatedMembership;

  } catch (error) {
    await client.query("ROLLBACK");
    throw error;

  } finally {
    client.release();
  }
};


/**
 * Reset monthly membership benefits.
 */
const resetMonthlyBenefits = async (
  membershipId
) => {
  const result = await pool.query(
    `
    UPDATE user_memberships
    SET
      used_litres = 0,
      monthly_claim_used = 0,
      last_reset_date = CURRENT_DATE,
      updated_at = NOW()
    WHERE id = $1
    RETURNING *;
    `,
    [membershipId]
  );

  return result.rows[0];
};


/**
 * Check whether monthly benefits need reset.
 */
const checkAndResetMonthlyBenefits = async (
  userId
) => {
  const membership =
    await getActiveMembership(userId);

  if (!membership) {
    return null;
  }

  const today = new Date();

  const lastReset =
    new Date(
      membership.last_reset_date
    );

  const monthChanged =
    today.getMonth() !==
      lastReset.getMonth() ||
    today.getFullYear() !==
      lastReset.getFullYear();

  if (!monthChanged) {
    return membership;
  }

  return await resetMonthlyBenefits(
    membership.id
  );
};


/**
 * Accept membership terms.
 */
const acceptTerms = async (userId) => {
  const resolvedPublicUserId =
    await resolvePublicUserId(userId);

  if (!resolvedPublicUserId) {
    throw new Error("User not found");
  }

  const result = await pool.query(
    `
    UPDATE user_memberships
    SET
      terms_and_conditions = TRUE
    WHERE
      user_id = $1
    RETURNING *
    `,
    [resolvedPublicUserId]
  );

  if (result.rows.length === 0) {
    throw new Error(
      "Membership record not found"
    );
  }

  return result.rows[0];
};


module.exports = {
  createMembership,
  getActiveMembership,
  getMembershipWallet,
  updateMembershipUsage,
  acceptTerms,
  resetMonthlyBenefits,
  checkAndResetMonthlyBenefits,
};