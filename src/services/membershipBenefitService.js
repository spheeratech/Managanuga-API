const pool = require("../../db");

/**
 * Process Vendor / Reseller benefit for a membership.
 *
 * Rules:
 *
 * 1. Customer directly assigned to Vendor
 *    → Vendor gets 20%
 *
 * 2. Customer referred by a direct ManaGanuga Reseller
 *    → Reseller gets 15%
 *
 * 3. Customer referred by a Vendor-created Reseller
 *    → Vendor gets 10%
 *    → Reseller gets 10%
 *
 * 4. No valid assignment/referrer
 *    → No benefit
 *
 * IMPORTANT:
 *
 * The caller is responsible for resolving the referral source
 * and passing its public user_id through assignedBy.
 *
 * Example:
 *
 * assignedBy  = "MGRS260803"
 * assignedRole = 4
 *
 * The service then determines whether that reseller has a
 * parent vendor through user_login.created_by.
 */
const processMembershipBenefitInTransaction = async ({
  membershipId,
  customerId,
  assignedBy,
  assignedRole,
  subscriptionAmount,
  client,
}) => {

  /*
   * ==========================================================
   * NO ASSIGNMENT / REFERRER
   * ==========================================================
   */
  if (!assignedBy || !assignedRole) {
    console.log(
      "No assigned beneficiary. No wallet benefit."
    );

    return [];
  }


  const benefits = [];


  /*
   * ==========================================================
   * CASE 1
   * CUSTOMER REFERRED / ASSIGNED DIRECTLY TO VENDOR
   * ==========================================================
   *
   * Vendor gets 20%.
   */
  if (Number(assignedRole) === 3) {

    const vendorResult = await client.query(
      `
      SELECT
        user_id,
        role
      FROM user_login
      WHERE
        user_id = $1
        AND role = 3
        AND is_active = 1
      LIMIT 1
      `,
      [String(assignedBy).trim()]
    );

    const vendor = vendorResult.rows[0];

    if (!vendor) {
      throw new Error(
        "Assigned vendor not found."
      );
    }

    const benefitPercent = 20;

    const benefitAmount =
      Number(subscriptionAmount) *
      benefitPercent /
      100;

    benefits.push({
      beneficiaryId: vendor.user_id,
      beneficiaryRole: "VENDOR",
      benefitPercent,
      benefitAmount,
    });
  }


  /*
   * ==========================================================
   * CASE 2 / CASE 3
   * CUSTOMER REFERRED / ASSIGNED TO RESELLER
   * ==========================================================
   */
  else if (Number(assignedRole) === 4) {

    const resellerResult = await client.query(
      `
      SELECT
        user_id,
        role,
        created_by
      FROM user_login
      WHERE
        user_id = $1
        AND role = 4
        AND is_active = 1
      LIMIT 1
      `,
      [String(assignedBy).trim()]
    );

    const reseller = resellerResult.rows[0];

    if (!reseller) {
      throw new Error(
        "Assigned reseller not found."
      );
    }


    /*
     * ========================================================
     * FIND PARENT VENDOR
     * ========================================================
     *
     * If this reseller was created by a Vendor:
     *
     * Vendor → Reseller → Customer
     *
     * then both receive 10%.
     */
    let parentVendor = null;

    if (reseller.created_by) {

      const vendorResult = await client.query(
        `
        SELECT
          user_id,
          role
        FROM user_login
        WHERE
          user_id = $1
          AND role = 3
          AND is_active = 1
        LIMIT 1
        `,
        [String(reseller.created_by).trim()]
      );

      parentVendor = vendorResult.rows[0];
    }


    /*
     * ========================================================
     * CASE 3
     * VENDOR-CREATED RESELLER
     * ========================================================
     *
     * Vendor → 10%
     * Reseller → 10%
     */
    if (parentVendor) {

      const vendorPercent = 10;
      const resellerPercent = 10;

      const vendorAmount =
        Number(subscriptionAmount) *
        vendorPercent /
        100;

      const resellerAmount =
        Number(subscriptionAmount) *
        resellerPercent /
        100;


      benefits.push({
        beneficiaryId: parentVendor.user_id,
        beneficiaryRole: "VENDOR",
        benefitPercent: vendorPercent,
        benefitAmount: vendorAmount,
      });


      benefits.push({
        beneficiaryId: reseller.user_id,
        beneficiaryRole: "RESELLER",
        benefitPercent: resellerPercent,
        benefitAmount: resellerAmount,
      });
    }


    /*
     * ========================================================
     * CASE 2
     * DIRECT MANAGANUGA RESELLER
     * ========================================================
     *
     * Reseller → 15%
     */
    else {

      const resellerPercent = 15;

      const resellerAmount =
        Number(subscriptionAmount) *
        resellerPercent /
        100;


      benefits.push({
        beneficiaryId: reseller.user_id,
        beneficiaryRole: "RESELLER",
        benefitPercent: resellerPercent,
        benefitAmount: resellerAmount,
      });
    }
  }


    /*
   * ==========================================================
   * CREDIT BENEFITS
   * ==========================================================
   */

  /*
   * A vendor/reseller can receive a commission from a customer
   * only once, regardless of how many memberships are activated.
   * The advisory lock and wallet row lock serialize concurrent
   * attempts using only the existing wallet and ledger tables.
   */
  for (const benefit of benefits) {
    const beneficiaryId = String(benefit.beneficiaryId).trim();
    const cleanCustomerId = String(customerId).trim();
    const creditAmount =
      Math.round(Number(benefit.benefitAmount) * 100) / 100;

    if (!Number.isFinite(creditAmount) || creditAmount < 0) {
      throw new Error(
        `Invalid membership commission amount for ${beneficiaryId}`
      );
    }

    await client.query(
      `SELECT pg_advisory_xact_lock(hashtext($1))`,
      [
        `MEMBERSHIP_BENEFIT:${cleanCustomerId}:` +
          `${beneficiaryId}:${benefit.beneficiaryRole}`,
      ]
    );

    await client.query(
      `
      INSERT INTO wallets
      (
        user_id,
        wallet_type,
        balance
      )
      VALUES
      ($1, $2, 0)
      ON CONFLICT (user_id)
      DO NOTHING
      `,
      [
        beneficiaryId,
        benefit.beneficiaryRole,
      ]
    );

    const walletResult = await client.query(
      `
      SELECT id, user_id, wallet_type, balance
      FROM wallets
      WHERE user_id = $1
        AND UPPER(TRIM(wallet_type)) = $2
        AND is_active = 1
      FOR UPDATE
      `,
      [beneficiaryId, benefit.beneficiaryRole]
    );

    const wallet = walletResult.rows[0];

    if (!wallet) {
      throw new Error(
        `Active ${benefit.beneficiaryRole} wallet not found for ${beneficiaryId}`
      );
    }

    const existingTransactionResult = await client.query(
      `
      SELECT 1
      FROM wallet_transactions
      WHERE user_id = $1
        AND wallet_id = $2
        AND benefited_by = $3
        AND transaction_type = 'CREDIT'
        AND benefit_type = 'MEMBERSHIP_COMMISSION'
        AND status = 'COMPLETED'
        AND is_active = 1
      LIMIT 1
      `,
      [beneficiaryId, wallet.id, cleanCustomerId]
    );

    if (existingTransactionResult.rows.length > 0) {
      console.log(
        `Benefit already exists for customer ${cleanCustomerId} -> ${beneficiaryId} (${benefit.beneficiaryRole}). Skipping.`
      );
      continue;
    }

    const updatedWalletResult = await client.query(
      `
      UPDATE wallets
      SET
        balance = balance + $1,
        updated_at = NOW(),
        updated_by = $3
      WHERE
        id = $2
        AND is_active = 1
      RETURNING id, user_id, wallet_type, balance
      `,
      [
        creditAmount,
        wallet.id,
        cleanCustomerId,
      ]
    );

    const updatedWallet = updatedWalletResult.rows[0];

    if (!updatedWallet) {
      throw new Error(
        `Unable to credit ${benefit.beneficiaryRole} wallet for ${beneficiaryId}`
      );
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
        wallet_balance_after
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
      `,
      [
        "CREDIT",
        `Membership commission [membership_id=${membershipId}; customer_id=${cleanCustomerId}; role=${benefit.beneficiaryRole}]`,
        cleanCustomerId,
        beneficiaryId,
        updatedWallet.id,
        benefit.benefitPercent,
        creditAmount,
        cleanCustomerId,
        "MEMBERSHIP_COMMISSION",
        "COMPLETED",
        updatedWallet.balance,
      ]
    );
  }


  return benefits;
};

const processMembershipBenefit = async ({
  membershipId,
  customerId,
  assignedBy,
  assignedRole,
  subscriptionAmount,
  client: suppliedClient = pool,
}) => {
  if (!assignedBy || !assignedRole) {
    return processMembershipBenefitInTransaction({
      membershipId,
      customerId,
      assignedBy,
      assignedRole,
      subscriptionAmount,
      client: suppliedClient,
    });
  }

  if (suppliedClient !== pool) {
    return processMembershipBenefitInTransaction({
      membershipId,
      customerId,
      assignedBy,
      assignedRole,
      subscriptionAmount,
      client: suppliedClient,
    });
  }

  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    const result = await processMembershipBenefitInTransaction({
      membershipId,
      customerId,
      assignedBy,
      assignedRole,
      subscriptionAmount,
      client,
    });

    await client.query("COMMIT");
    return result;
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
};


module.exports = {
  processMembershipBenefit,
};