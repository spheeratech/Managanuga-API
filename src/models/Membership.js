const pool = require("../../db");
const { getUnitLitres } = require("../services/membershipCheckoutService");

const calculateOrderLitres = async (itemIds, quantities, client = pool) => {
  if (
    !Array.isArray(itemIds) ||
    !Array.isArray(quantities) ||
    itemIds.length === 0 ||
    itemIds.length !== quantities.length
  ) {
    throw new Error("Order item snapshot is invalid for membership usage");
  }

  const result = await client.query(
    `
    SELECT
      item.item_id,
      item.quantity,
      product.weight
    FROM unnest($1::integer[], $2::integer[])
      WITH ORDINALITY AS item(item_id, quantity, ordinality)
    LEFT JOIN lkp_products product
      ON product.id = item.item_id
    ORDER BY item.ordinality
    `,
    [itemIds, quantities]
  );

  if (
    result.rows.length !== itemIds.length ||
    result.rows.some((row) => row.weight === null)
  ) {
    throw new Error(
      "Order products are unavailable; membership usage cannot be reconciled"
    );
  }

  return result.rows.reduce(
    (total, row) =>
      total + Number(row.quantity) * getUnitLitres(row.weight),
    0
  );
};

const extractMembershipOrderId = (description) => {
  const match = String(description || "").match(
    /\[membership-order:([^\]]+)\]/
  );

  if (!match) {
    throw new Error("Membership transaction is missing its order reference");
  }

  return decodeURIComponent(match[1]);
};

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
      AND is_active = 1
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
        AND is_active = 1
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
  referralCode = null
}) => {
  const client = await pool.connect();

  try {
    await client.query("BEGIN");
    const resolvedPublicUserId = await resolvePublicUserId(
      userId,
      client
    );

    if (!resolvedPublicUserId) {
      throw new Error("User not found");
    }

    if (paymentId !== null && paymentId !== undefined) {
      await client.query(
        "SELECT pg_advisory_xact_lock(hashtext($1))",
        [`MEMBERSHIP_PAYMENT:${paymentId}`]
      );

      const existingResult = await client.query(
        `
        SELECT *
        FROM user_memberships
        WHERE payment_id = $1
        LIMIT 1
        FOR UPDATE
        `,
        [paymentId]
      );
      const existingMembership = existingResult.rows[0];

      if (existingMembership) {
        if (
          existingMembership.user_id !== resolvedPublicUserId ||
          Number(existingMembership.plan_id) !== Number(planId)
        ) {
          throw new Error(
            "Payment is already associated with a different membership"
          );
        }

        await client.query("COMMIT");
        return existingMembership;
      }
    }

    await client.query(
      `
      UPDATE user_memberships
      SET
        status = 'EXPIRED',
        is_active = 0,
        updated_at = NOW()
      WHERE user_id = $1
        AND status = 'ACTIVE'
      `,
      [resolvedPublicUserId]
    );

    const result = await client.query(
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
        referral_code,
        is_active
      )
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,1)
      RETURNING *
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

    await client.query("COMMIT");
    return result.rows[0];
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
};


/**
 * Get active membership.
 *
 * IMPORTANT:
 * Remaining days are calculated using the IST calendar date.
 *
 * The count changes at 12:00 AM IST.
 *
 * Example:
 * Purchased Sept 26 at 10:00 PM:
 *
 * Sept 26 -> 365 days
 * Sept 27 12:00 AM -> 364 days
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

    INNER JOIN lkp_subscription_plans sp
      ON sp.id = um.plan_id

    WHERE
      um.user_id = $1
      AND um.status = 'ACTIVE'
      AND um.is_active = 1

    ORDER BY um.id DESC

    LIMIT 1
    `,
    [resolvedPublicUserId]
  );

  if (result.rows.length === 0) {
    return null;
  }

  const membership = result.rows[0];

  /*
   * =====================================================
   * CALCULATE REMAINING DAYS USING IST CALENDAR DATE
   * =====================================================
   *
   * We deliberately do NOT compare exact timestamps.
   *
   * This means the day changes at:
   *
   * 12:00 AM IST
   *
   * rather than 24 hours after membership purchase.
   */

  const todayIST = new Intl.DateTimeFormat(
    "en-CA",
    {
      timeZone: "Asia/Kolkata",
      year: "numeric",
      month: "2-digit",
      day: "2-digit"
    }
  ).format(new Date());

  /*
   * Convert expiry_date to an IST calendar date.
   */
  const expiryIST = new Intl.DateTimeFormat(
    "en-CA",
    {
      timeZone: "Asia/Kolkata",
      year: "numeric",
      month: "2-digit",
      day: "2-digit"
    }
  ).format(new Date(membership.expiry_date));

  /*
   * Convert YYYY-MM-DD into UTC midnight.
   *
   * Since both dates are calendar dates, this avoids
   * timezone/hour/minute differences affecting the count.
   */
  const todayDate = new Date(`${todayIST}T00:00:00Z`);
  const expiryDate = new Date(`${expiryIST}T00:00:00Z`);

  const millisecondsPerDay =
    1000 * 60 * 60 * 24;

  let daysRemaining = Math.ceil(
    (expiryDate.getTime() - todayDate.getTime()) /
      millisecondsPerDay
  );

  /*
   * Never return a negative number.
   */
  daysRemaining = Math.max(0, daysRemaining);

  /*
   * If expiry date has arrived/passed, mark membership expired.
   */
  if (daysRemaining <= 0) {
    await pool.query(
      `
      UPDATE user_memberships
      SET
        status = 'EXPIRED',
        updated_at = NOW()
      WHERE id = $1
        AND status = 'ACTIVE'
      `,
      [membership.id]
    );

    return null;
  }

  /*
   * Add calculated value to the response.
   *
   * Database expiry_date remains unchanged.
   */
  return {
    ...membership,
    days_remaining: daysRemaining
  };
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

    INNER JOIN lkp_subscription_plans sp
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

  const membershipMarker =
    `[membership-id:${membership.membership_id}]`;
  const transactionRows = (
    await pool.query(
      `
      SELECT
        wt.id,
        wt.transaction_type,
        wt.benefit_amount AS amount,
        wt.wallet_balance_after AS balance_after,
        wt.description,
        wt.created_at
      FROM wallet_transactions wt
      WHERE wt.user_id = $1
        AND wt.benefit_type = 'MEMBERSHIP_CLAIM'
        AND wt.transaction_type = 'DEBIT'
        AND wt.status = 'COMPLETED'
        AND wt.is_active = 1
        AND wt.benefit_amount > 0
        AND POSITION($2 IN wt.description) > 0
      ORDER BY wt.created_at DESC, wt.id DESC
      `,
      [resolvedPublicUserId, membershipMarker]
    )
  ).rows;

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
        membership.expiry_date
    },

    historyAvailable: true,
    transactions:
      transactionRows.map(
        (transaction) => ({
          id: transaction.id,

          orderId: extractMembershipOrderId(transaction.description),

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
            transaction.created_at
        })
      )
  };
};


/**
 * Update membership usage after an order.
 *
 * user_memberships.user_id:
 *     PUBLIC ID
 *
 * wallet_transactions.user_id stores the PUBLIC user_login.user_id.
 */
const updateMembershipUsage = async ({
  userId,
  membershipId,
  litresUsed,
  walletUsed,
  orderId,
  client: suppliedClient = null
}) => {
  const cleanMembershipId = Number(membershipId);
  const cleanLitresUsed = Number(litresUsed);
  const cleanWalletUsed = Number(walletUsed);
  const cleanOrderId = String(orderId ?? "").trim();

  if (!Number.isInteger(cleanMembershipId) || cleanMembershipId <= 0) {
    throw new Error(
      "The membership used at checkout must be explicitly identified"
    );
  }

  if (
    !Number.isFinite(cleanLitresUsed) ||
    cleanLitresUsed < 0 ||
    !Number.isFinite(cleanWalletUsed) ||
    cleanWalletUsed < 0
  ) {
    throw new Error("Membership usage amounts must be non-negative numbers");
  }

  if ((cleanLitresUsed > 0 || cleanWalletUsed > 0) && !cleanOrderId) {
    throw new Error("Order ID is required for membership usage history");
  }

  const ownsClient = suppliedClient === null;
  const client = suppliedClient || await pool.connect();

  try {
    if (ownsClient) {
      await client.query("BEGIN");
    }

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
     * Lock the active membership.
     */
    const membershipResult =
      await client.query(
        `
        SELECT
          id,
          wallet_balance,
          monthly_claim,
          monthly_claim_used
        FROM user_memberships
        WHERE
          id = $1
          AND
          user_id = $2
          AND status = 'ACTIVE'
          AND is_active = 1
        FOR UPDATE
        `,
        [cleanMembershipId, resolvedPublicUserId]
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

    if (!membership) {
      throw new Error(
        "The membership used at checkout is not active for this user"
      );
    }

    const referenceMarker =
      ` [membership-reference:${JSON.stringify([
        cleanMembershipId,
        cleanOrderId,
      ])}]`;
    const usageMarker =
      ` [membership-usage:${JSON.stringify([
        cleanLitresUsed,
        cleanWalletUsed,
      ])}]`;
    const membershipMarker =
      `[membership-id:${cleanMembershipId}]`;
    const orderMarker =
      `[membership-order:${encodeURIComponent(cleanOrderId)}]`;
    const benefitType =
      cleanWalletUsed > 0
        ? "MEMBERSHIP_CLAIM"
        : "MEMBERSHIP_USAGE";

    if (cleanLitresUsed > 0 || cleanWalletUsed > 0) {
      await client.query(
        "SELECT pg_advisory_xact_lock(hashtext($1))",
        [
          `MEMBERSHIP_USAGE:${JSON.stringify([
            resolvedPublicUserId,
            cleanMembershipId,
            cleanOrderId,
          ])}`,
        ]
      );

      const duplicateResult = await client.query(
        `
        SELECT id, benefit_type, benefit_amount, description
        FROM wallet_transactions
        WHERE user_id = $1
          AND benefit_type IN ('MEMBERSHIP_CLAIM', 'MEMBERSHIP_USAGE')
          AND transaction_type = 'DEBIT'
          AND status = 'COMPLETED'
          AND is_active = 1
          AND RIGHT(description, LENGTH($2)) = $2
        LIMIT 1
        `,
        [resolvedPublicUserId, referenceMarker]
      );

      const existingUsage = duplicateResult.rows[0];
      if (existingUsage) {
        if (
          existingUsage.benefit_type !== benefitType ||
          Number(existingUsage.benefit_amount) !== cleanWalletUsed ||
          !String(existingUsage.description || "").includes(usageMarker)
        ) {
          throw new Error(
            "Membership usage retry does not match the recorded order usage"
          );
        }

        if (ownsClient) {
          await client.query("COMMIT");
        }
        return membership;
      }
    }

    const remainingClaim =
      Number(membership.monthly_claim || 0) -
      Number(membership.monthly_claim_used || 0);
    if (
      cleanWalletUsed > Number(membership.wallet_balance || 0) ||
      cleanWalletUsed > remainingClaim
    ) {
      throw new Error("Membership wallet claim is no longer available");
    }

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

          updated_at = NOW(),
          updated_by = $4

        WHERE id = $3
          AND is_active = 1

        RETURNING *;
        `,
        [
          cleanLitresUsed,
          cleanWalletUsed,
          membership.id,
          resolvedPublicUserId
        ]
      );

    const updatedMembership =
      result.rows[0];

    if (!updatedMembership) {
      throw new Error("Membership usage update failed");
    }

    if (cleanLitresUsed > 0 || cleanWalletUsed > 0) {
      // The shared ledger has no membership/order columns; retain both IDs in a stable marker.
      await client.query(
        `
        INSERT INTO wallet_transactions
        (
          transaction_type,
          description,
          created_by,
          user_id,
          wallet_id,
          benefit_percentage,
          benefit_amount,
          benefited_by,
          benefit_type,
          status,
          wallet_balance_after,
          is_active
        )
        VALUES ($1, $2, $3, $4, NULL, 0, $5, NULL, $6, 'COMPLETED', $7, 1)
        `,
        [
          "DEBIT",
          `Membership usage ${membershipMarker} ${orderMarker}${usageMarker}${referenceMarker}`,
          resolvedPublicUserId,
          resolvedPublicUserId,
          cleanWalletUsed,
          benefitType,
          Number(updatedMembership.wallet_balance),
        ]
      );
    }

    if (ownsClient) {
      await client.query("COMMIT");
    }

    return updatedMembership;

  } catch (error) {
    if (ownsClient) {
      await client.query("ROLLBACK");
    }
    throw error;

  } finally {
    if (ownsClient) {
      client.release();
    }
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
      terms_and_conditions = 1
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
  calculateOrderLitres,
  updateMembershipUsage,
  acceptTerms,
  resetMonthlyBenefits,
  checkAndResetMonthlyBenefits
};