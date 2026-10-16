const pool = require("../../db");
const Membership = require("./Membership");

const CUSTOMER_ROLES = ["CUSTOMER", "USER"];

const normalizeAmount = (value) => {
  const amount = Number(value);

  if (!Number.isFinite(amount) || amount <= 0) {
    throw new Error("Wallet amount must be a valid positive number");
  }

  return Math.round(amount * 100) / 100;
};

const ensureCustomerWallet = async (client, userId) => {
  await client.query(
    `
    INSERT INTO user_wallet
    (
      user_id,
      wallet_amount,
      prev_balance,
      current_balance,
      created_by,
      updated_by,
      is_active
    )
    SELECT
      ul.user_id,
      0,
      0,
      0,
      ul.user_id,
      ul.user_id,
      1
    FROM user_login ul
    INNER JOIN lkp_user_roles ur
      ON ur.id = ul.role
    WHERE ul.user_id = $1
      AND ul.is_active = 1
      AND UPPER(TRIM(ur.role_name)) = ANY($2::text[])
    ON CONFLICT (user_id) DO NOTHING
    `,
    [userId, CUSTOMER_ROLES]
  );

  const result = await client.query(
    `
    SELECT
      uw.wallet_id,
      uw.user_id,
      uw.wallet_amount,
      uw.prev_balance,
      uw.current_balance,
      uw.created_at,
      uw.updated_at
    FROM user_wallet uw
    INNER JOIN user_login ul
      ON ul.user_id = uw.user_id
    INNER JOIN lkp_user_roles ur
      ON ur.id = ul.role
    WHERE uw.user_id = $1
      AND uw.is_active = 1
      AND ul.is_active = 1
      AND UPPER(TRIM(ur.role_name)) = ANY($2::text[])
    FOR UPDATE OF uw
    `,
    [userId, CUSTOMER_ROLES]
  );

  const wallet = result.rows[0];

  if (!wallet) {
    throw new Error("Customer wallet not found");
  }

  return wallet;
};

const findCustomerTransaction = async (
  client,
  {
    userId,
    walletId,
    transactionType,
    benefitType,
    referenceMarker,
    legacyReferenceMarker,
  }
) => {
  const result = await client.query(
    `
    SELECT
      id,
      user_id,
      wallet_id,
      transaction_type,
      description,
      benefit_amount,
      benefit_percentage,
      benefited_by,
      benefit_type,
      status,
      wallet_balance_after,
      created_at
    FROM wallet_transactions
    WHERE user_id = $1
      AND wallet_id = $2
      AND transaction_type = $3
      AND benefit_type = $4
      AND (
        ($5 IS NOT NULL AND RIGHT(description, LENGTH($5)) = $5)
        OR ($6 IS NOT NULL AND RIGHT(description, LENGTH($6)) = $6)
      )
      AND status = 'COMPLETED'
      AND is_active = 1
    ORDER BY id
    LIMIT 1
    `,
    [
      userId,
      walletId,
      transactionType,
      benefitType,
      referenceMarker,
      legacyReferenceMarker,
    ]
  );

  return result.rows[0] || null;
};

const applyCustomerWalletTransaction = async (
  client,
  wallet,
  {
    userId,
    amount,
    transactionType,
    description,
    benefitType,
    benefitedBy = null,
    benefitPercentage = 0,
  }
) => {
  const cleanAmount = normalizeAmount(amount);
  const currentBalance = Number(wallet.current_balance);

  if (
    transactionType === "DEBIT" &&
    cleanAmount > currentBalance
  ) {
    throw new Error("Insufficient wallet balance");
  }

  const nextBalance = Math.round(
    (
      currentBalance +
      (transactionType === "CREDIT" ? cleanAmount : -cleanAmount)
    ) * 100
  ) / 100;

  const balanceResult = await client.query(
    `
    UPDATE user_wallet
    SET
      prev_balance = current_balance,
      current_balance = $1,
      wallet_amount = $1,
      updated_at = NOW(),
      updated_by = $2
    WHERE wallet_id = $3
      AND user_id = $2
      AND is_active = 1
    RETURNING
      wallet_id,
      user_id,
      wallet_amount,
      prev_balance,
      current_balance,
      created_at,
      updated_at
    `,
    [nextBalance, userId, wallet.wallet_id]
  );

  if (!balanceResult.rows[0]) {
    throw new Error("Customer wallet update failed");
  }

  const transactionResult = await client.query(
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
      wallet_balance_after
    )
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, 'COMPLETED', $10)
    RETURNING
      id,
      user_id,
      wallet_id,
      transaction_type,
      description,
      benefit_amount,
      benefit_percentage,
      benefited_by,
      benefit_type,
      status,
      wallet_balance_after,
      created_at
    `,
    [
      transactionType,
      description,
      userId,
      userId,
      wallet.wallet_id,
      transactionType === "DEBIT" ? 0 : benefitPercentage,
      transactionType === "DEBIT" ? 0 : cleanAmount,
      benefitedBy,
      benefitType,
      nextBalance,
    ]
  );

  return {
    wallet: balanceResult.rows[0],
    transaction: transactionResult.rows[0],
  };
};

const createCustomerWalletTransaction = async ({
  userId,
  amount,
  transactionType,
  referenceType,
  referenceId,
  description,
  benefitType,
  benefitedBy = null,
  benefitPercentage = 0,
}) => {
  const cleanUserId = String(userId || "").trim();
  const cleanReferenceType = String(referenceType || "").trim();
  const cleanReferenceId = String(referenceId || "").trim();
  const cleanDescription = String(description || "").trim();
  const cleanBenefitType = String(benefitType || "").trim();

  if (!cleanUserId) {
    throw new Error("User ID is required");
  }

  if (!cleanReferenceType || !cleanReferenceId) {
    throw new Error("Wallet transaction reference is required");
  }

  if (!cleanDescription || !cleanBenefitType) {
    throw new Error("Wallet transaction description and type are required");
  }

  if (!["CREDIT", "DEBIT"].includes(transactionType)) {
    throw new Error("Invalid wallet transaction type");
  }

  const referenceMarker =
    ` [wallet-reference:${JSON.stringify([
      cleanReferenceType,
      cleanReferenceId,
    ])}]`;
  const legacyReferenceMarker =
    cleanReferenceType.includes(":") ||
    cleanReferenceId.includes(":")
      ? null
      : ` [${cleanReferenceType}:${cleanReferenceId}]`;
  const transactionDescription =
    `${cleanDescription}${referenceMarker}`;
  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    const idempotencyKey = JSON.stringify([
      cleanUserId,
      transactionType,
      cleanBenefitType,
      cleanReferenceType,
      cleanReferenceId,
    ]);

    await client.query(
      `SELECT pg_advisory_xact_lock(hashtext($1))`,
      [`CUSTOMER_WALLET_TRANSACTION:${idempotencyKey}`]
    );

    const wallet = await ensureCustomerWallet(client, cleanUserId);
    const existingTransaction = await findCustomerTransaction(
      client,
      {
        userId: cleanUserId,
        walletId: wallet.wallet_id,
        transactionType,
        benefitType: cleanBenefitType,
        referenceMarker,
        legacyReferenceMarker,
      }
    );

    if (existingTransaction) {
      await client.query("COMMIT");
      return {
        wallet,
        transaction: existingTransaction,
        duplicate: true,
      };
    }

    const result = await applyCustomerWalletTransaction(
      client,
      wallet,
      {
        userId: cleanUserId,
        amount,
        transactionType,
        description: transactionDescription,
        benefitType: cleanBenefitType,
        benefitedBy,
        benefitPercentage,
      }
    );

    await client.query("COMMIT");
    return { ...result, duplicate: false };
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
};

const Wallet = {
  async getByUserId(userId) {
    const walletUserId = String(userId || "").trim();

    if (!walletUserId) {
      return null;
    }

    const userResult = await pool.query(
      `
      SELECT
        ul.user_id,
        UPPER(TRIM(ur.role_name)) AS role_name
      FROM user_login ul
      INNER JOIN lkp_user_roles ur
        ON ur.id = ul.role
      WHERE ul.user_id = $1
        AND ul.is_active = 1
      LIMIT 1
      `,
      [walletUserId]
    );

    const user = userResult.rows[0];

    if (!user) {
      return null;
    }

    if (CUSTOMER_ROLES.includes(user.role_name)) {
      const client = await pool.connect();

      try {
        await client.query("BEGIN");
        const wallet = await ensureCustomerWallet(client, walletUserId);
        await client.query("COMMIT");

        return {
          id: wallet.wallet_id,
          user_id: wallet.user_id,
          wallet_type: user.role_name,
          balance: wallet.current_balance,
          wallet_amount: wallet.wallet_amount,
          prev_balance: wallet.prev_balance,
          current_balance: wallet.current_balance,
          created_at: wallet.created_at,
          updated_at: wallet.updated_at,
        };
      } catch (error) {
        await client.query("ROLLBACK");
        throw error;
      } finally {
        client.release();
      }
    }

    if (!["VENDOR", "RESELLER"].includes(user.role_name)) {
      return null;
    }

    const result = await pool.query(
      `
      
SELECT
  uw.wallet_id AS id,
  uw.user_id,
  UPPER(TRIM(ur.role_name)) AS wallet_type,
  uw.current_balance AS balance,
  uw.wallet_amount,
  uw.prev_balance,
  uw.current_balance,
  uw.created_at,
  uw.updated_at
FROM user_wallet uw
INNER JOIN user_login ul
  ON ul.user_id = uw.user_id
INNER JOIN lkp_user_roles ur
  ON ur.id = ul.role
WHERE uw.user_id = $1
  AND UPPER(TRIM(ur.role_name)) = $2
  AND ul.is_active = 1
  AND uw.is_active = 1
LIMIT 1

      `,
      [walletUserId, user.role_name]
    );

    return result.rows[0] || null;
  },

  async getCustomerTransactions(userId) {
    const walletUserId = String(userId || "").trim();

    if (!walletUserId) {
      return [];
    }

    const result = await pool.query(
      `
      SELECT
        wt.id,
        wt.user_id,
        wt.wallet_id,
        wt.transaction_type,
        wt.description,
        wt.benefit_amount,
        wt.benefit_percentage,
        wt.benefited_by,
        wt.benefit_type,
        wt.status,
        wt.wallet_balance_after,
        wt.created_at
      FROM wallet_transactions wt
      INNER JOIN user_wallet uw
        ON uw.wallet_id = wt.wallet_id
       AND uw.user_id = wt.user_id
      INNER JOIN user_login ul
        ON ul.user_id = wt.user_id
      INNER JOIN lkp_user_roles ur
        ON ur.id = ul.role
      WHERE wt.user_id = $1
        AND uw.is_active = 1
        AND wt.is_active = 1
        AND ul.is_active = 1
        AND UPPER(TRIM(ur.role_name)) = ANY($2::text[])
      ORDER BY wt.created_at DESC, wt.id DESC
      `,
     [walletUserId, ["CUSTOMER", "USER", "VENDOR", "RESELLER"]]
    );

    return result.rows;
  },

  async creditCustomerWallet(details) {
    return createCustomerWalletTransaction({
      ...details,
      transactionType: "CREDIT",
    });
  },

  async debitCustomerWallet(details) {
    return createCustomerWalletTransaction({
      ...details,
      transactionType: "DEBIT",
    });
  },

  async payOrderWithCustomerWallet(userId, orderIdentifier) {
    const cleanUserId = String(userId || "").trim();
    const cleanOrderIdentifier = String(orderIdentifier || "").trim();

    if (!cleanUserId || !cleanOrderIdentifier) {
      throw new Error("User ID and order ID are required");
    }

    const client = await pool.connect();

    try {
      await client.query("BEGIN");
const orderResult = await client.query(
  `
  SELECT
    o.id,
    o.order_id,
    o.user_id,
    o.item_id,
    o.actual_amount,
    o.payable_amount,
    o.payment_status,
    o.membership_id,
    o.membership_discount,
    o.wallet_claim,
    o.delivery_charge,
    o.quantity
  FROM orders o
  INNER JOIN user_login ul
    ON ul.user_id = o.user_id
  INNER JOIN lkp_user_roles ur
    ON ur.id = ul.role
  WHERE (o.order_id = $1 OR o.id::text = $1)
    AND o.user_id = $2
    AND o.is_active = 1
    AND ul.is_active = 1
    AND UPPER(TRIM(ur.role_name)) = ANY($3::text[])
  FOR UPDATE OF o
  `,
  [cleanOrderIdentifier, cleanUserId, CUSTOMER_ROLES]
);

      const order = orderResult.rows[0];

      if (!order) {
        throw new Error("Customer order not found");
      }

      const amount = normalizeAmount(order.payable_amount);
      const orderDescription =
        `Wallet payment for order ${order.order_id} ` +
        `[wallet-amount:${amount.toFixed(2)}]`;
      const orderReferenceMarker =
        ` [wallet-reference:${JSON.stringify([
          "ORDER",
          order.order_id,
        ])}]`;
      const legacyOrderReferenceMarker =
        String(order.order_id).includes(":")
          ? null
          : ` [ORDER:${order.order_id}]`;
      const transactionDescription =
        `${orderDescription}${orderReferenceMarker}`;

      const wallet = await ensureCustomerWallet(client, cleanUserId);
      const existingTransaction = await findCustomerTransaction(
        client,
        {
          userId: cleanUserId,
          walletId: wallet.wallet_id,
          transactionType: "DEBIT",
          benefitType: "ORDER_PAYMENT",
          referenceMarker: orderReferenceMarker,
          legacyReferenceMarker: legacyOrderReferenceMarker,
        }
      );

      if (String(order.payment_status || "").toUpperCase() === "PAID") {
        if (!existingTransaction) {
          throw new Error("Order has already been paid");
        }

        const paymentResult = await client.query(
          `
          SELECT *
          FROM payments
          WHERE order_id = $1
            AND payment_gateway = 'WALLET'
            AND UPPER(method) = 'WALLET'
            AND UPPER(payment_type) = 'ORDER'
            AND UPPER(status) = 'PAID'
            AND is_active = 1
          ORDER BY id DESC
          LIMIT 1
          `,
          [order.order_id]
        );

        const walletPayment = paymentResult.rows[0];
        const orderPayableAmount = Number(order.payable_amount);

        if (
          !walletPayment ||
          !existingTransaction.description ||
          Number(
            existingTransaction.description.match(
              /\[wallet-amount:([0-9]+(?:\.[0-9]{1,2})?)\]/
            )?.[1]
          ) !== amount ||
          !Number.isFinite(orderPayableAmount) ||
          Number(walletPayment.payable_amount) !== orderPayableAmount ||
          Number(walletPayment.actual_amount) !==
            Number(order.actual_amount) ||
          Number(walletPayment.membership_id || 0) !==
            Number(order.membership_id || 0)
        ) {
          throw new Error("Order has already been paid");
        }

        await client.query("COMMIT");
        return {
          order,
          wallet,
          transaction: existingTransaction,
          payment: walletPayment,
          duplicate: true,
        };
      }

      const membershipId =
        order.membership_id == null
          ? null
          : Number(order.membership_id);

      if (
        membershipId === null &&
        (Number(order.membership_discount || 0) > 0 ||
          Number(order.wallet_claim || 0) > 0)
      ) {
        throw new Error(
          "Membership-benefit order is missing its persisted membership association"
        );
      }

      if (existingTransaction) {
        throw new Error("Order has already been paid");
      }

      const paidPaymentResult = await client.query(
        `
        SELECT id
        FROM payments
        WHERE order_id = $1
          AND UPPER(status) = 'PAID'
          AND is_active = 1
        ORDER BY id DESC
        LIMIT 1
        FOR UPDATE
        `,
        [order.order_id]
      );

      if (paidPaymentResult.rows[0]) {
        throw new Error("Order has already been paid");
      }

      const result = await applyCustomerWalletTransaction(
        client,
        wallet,
        {
          userId: cleanUserId,
          amount,
          transactionType: "DEBIT",
          description: transactionDescription,
          benefitType: "ORDER_PAYMENT",
        }
      );

      const paymentResult = await client.query(
        `
        INSERT INTO payments
        (
          order_id,
          payment_gateway,
          method,
          actual_amount,
          payable_amount,
          status,
          payment_type,
          membership_id,
          created_by,
          updated_by
        )
        VALUES ($1, 'WALLET', 'WALLET', $2, $3, 'PAID', 'ORDER', $4, $5, $5)
        RETURNING *
        `,
        [
          order.order_id,
          order.actual_amount,
          amount,
          membershipId,
          cleanUserId,
        ]
      );

      const updatedOrderResult = await client.query(
        `
        UPDATE orders
        SET
          payment_status = 'PAID',
          updated_at = NOW(),
          updated_by = $1
        WHERE id = $2
          AND payment_status IS DISTINCT FROM 'PAID'
          AND membership_id IS NOT DISTINCT FROM $3::integer
        RETURNING *
        `,
        [cleanUserId, order.id, membershipId]
      );

      if (!updatedOrderResult.rows[0]) {
        throw new Error("Order payment status could not be updated");
      }

      if (membershipId !== null) {
        const litresUsed = await Membership.calculateOrderLitres(
          order.item_id,
          order.quantity,
          client
        );

        await Membership.updateMembershipUsage({
          userId: cleanUserId,
          membershipId,
          litresUsed,
          walletUsed: Number(order.wallet_claim || 0),
          orderId: order.order_id,
          client,
        });
      }

      await client.query("COMMIT");

      return {
        order: updatedOrderResult.rows[0],
        wallet: result.wallet,
        transaction: result.transaction,
        payment: paymentResult.rows[0],
        duplicate: false,
      };
    } catch (error) {
      await client.query("ROLLBACK");
      throw error;
    } finally {
      client.release();
    }
  },


async createRedeemRequest(userId, requestedAmount) {
  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    const walletUserId = String(userId || "").trim();

    if (!walletUserId) {
      throw new Error("User ID is required");
    }

    const redeemAmount = Number(requestedAmount);

    if (!Number.isFinite(redeemAmount)) {
      throw new Error("Redeem amount must be a valid number");
    }

    if (redeemAmount < 1000) {
      throw new Error("Minimum redeem amount is ₹1,000");
    }

    const normalizedRedeemAmount =
      Math.round(redeemAmount * 100) / 100;

    const walletResult = await client.query(
      `
      SELECT
        uw.wallet_id AS id,
        uw.user_id,
        UPPER(TRIM(ur.role_name)) AS wallet_type,
        uw.current_balance AS balance,
        uw.wallet_amount,
        uw.prev_balance,
        uw.current_balance
      FROM user_wallet uw
      INNER JOIN user_login ul
        ON ul.user_id = uw.user_id
      INNER JOIN lkp_user_roles ur
        ON ur.id = ul.role
      WHERE uw.user_id = $1
        AND ul.is_active = 1
        AND uw.is_active = 1
        AND UPPER(TRIM(ur.role_name)) IN ('VENDOR', 'RESELLER')
      FOR UPDATE OF uw
      `,
      [walletUserId]
    );

    const wallet = walletResult.rows[0];

    if (!wallet) {
      throw new Error("Wallet not found");
    }

    if (!["VENDOR", "RESELLER"].includes(wallet.wallet_type)) {
      throw new Error(
        "Redeem is available only for Vendor or Reseller wallets"
      );
    }

    const walletAmount = Math.round(Number(wallet.balance) * 100) / 100;

    if (!Number.isFinite(walletAmount) || walletAmount < 1000) {
      throw new Error(
        "Minimum wallet balance of ₹1,000 is required for redemption"
      );
    }

    if (normalizedRedeemAmount > walletAmount) {
      throw new Error(
        `Redeem amount cannot exceed your wallet balance of ₹${walletAmount.toFixed(2)}`
      );
    }

    const redeemResult = await client.query(
      `
      INSERT INTO redeem
      (
        user_id,
        user_type,
        wallet_amount,
        redeem_status,
        redeem_created_date,
        created_by
      )
      VALUES ($1, $2, $3, 'IN_PROGRESS', NOW(), $1)
      RETURNING
        id,
        user_id,
        user_type,
        wallet_amount,
        redeem_status,
        redeem_created_date,
        created_by
      `,
      [
        wallet.user_id,
        wallet.wallet_type,
        normalizedRedeemAmount,
      ]
    );

    const redeem = redeemResult.rows[0];

    const newBalance =
      Math.round((walletAmount - normalizedRedeemAmount) * 100) / 100;

    const balanceResult = await client.query(
      `
      UPDATE user_wallet
      SET
        prev_balance = current_balance,
        current_balance = $1,
        wallet_amount = $1,
        updated_at = NOW(),
        updated_by = $2
      WHERE wallet_id = $3
        AND user_id = $2
        AND is_active = 1
      RETURNING wallet_id, user_id, current_balance
      `,
      [newBalance, wallet.user_id, wallet.id]
    );

    if (!balanceResult.rows[0]) {
      throw new Error("Wallet balance update failed");
    }

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
      VALUES (
        'DEBIT',
        $1,
        $2,
        $2,
        $3,
        0,
        $4,
        NULL,
        'WALLET_REDEMPTION',
        'COMPLETED',
        $5,
        1
      )
      `,
      [
        `Wallet redemption request [redeem_id=${redeem.id}]`,
        wallet.user_id,
        wallet.id,
        normalizedRedeemAmount,
        newBalance,
      ]
    );

    await client.query("COMMIT");

    return {
      redeem,
      walletBalance: newBalance,
    };
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
},


  async updateRedeemStatus(redeemId, redeemStatus) {
    const cleanStatus = String(redeemStatus || "").trim().toUpperCase();

    if (!["IN_PROGRESS", "COMPLETED", "REJECTED"].includes(cleanStatus)) {
      throw new Error("Invalid redeem status");
    }

    const result = await pool.query(
      `
      UPDATE redeem
      SET
        redeem_status = $1,
        updated_at = NOW()
      WHERE id = $2
        AND is_active = 1
      RETURNING
        id,
        user_id,
        user_type,
        wallet_amount,
        redeem_status,
        redeem_created_date,
        created_by,
        updated_at
      `,
      [cleanStatus, redeemId]
    );

    if (!result.rows[0]) {
      throw new Error("Redeem request not found");
    }

    return result.rows[0];
  },

  async getLatestRedeem(userId) {
    const walletUserId = String(userId || "").trim();

    const result = await pool.query(
      `
      SELECT
        r.id,
        r.user_id,
        r.user_type,
        r.wallet_amount,
        r.redeem_status,
        r.redeem_created_date,
        r.created_by
      FROM redeem r
      INNER JOIN user_login ul
        ON ul.user_id = r.user_id
       AND ul.is_active = 1
      INNER JOIN lkp_user_roles ur
        ON ur.id = ul.role
      WHERE r.user_id = $1
        AND r.is_active = 1
        AND UPPER(TRIM(ur.role_name)) = ANY($2::text[])
        AND UPPER(TRIM(r.user_type)) = UPPER(TRIM(ur.role_name))
      ORDER BY r.redeem_created_date DESC
      LIMIT 1
      `,
      [walletUserId, ["VENDOR", "RESELLER"]]
    );

    return result.rows[0] || null;
  },

  async getRedeemTransactions(userId) {
    const walletUserId = String(userId || "").trim();

    const result = await pool.query(
      `
      SELECT
        r.id,
        r.user_id,
        r.user_type,
        r.wallet_amount,
        r.redeem_status,
        r.redeem_created_date,
        r.created_by
      FROM redeem r
      INNER JOIN user_login ul
        ON ul.user_id = r.user_id
       AND ul.is_active = 1
      INNER JOIN lkp_user_roles ur
        ON ur.id = ul.role
      WHERE r.user_id = $1
        AND r.is_active = 1
        AND UPPER(TRIM(ur.role_name)) = ANY($2::text[])
        AND UPPER(TRIM(r.user_type)) = UPPER(TRIM(ur.role_name))
      ORDER BY r.redeem_created_date DESC
      `,
      [walletUserId, ["VENDOR", "RESELLER"]]
    );

    return result.rows;
  },
};

module.exports = Wallet;
