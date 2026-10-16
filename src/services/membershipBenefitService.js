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

  for (const benefit of benefits) {
    const beneficiaryId = String(benefit.beneficiaryId).trim();
    const cleanCustomerId = String(customerId).trim();
    const beneficiaryRole = String(benefit.beneficiaryRole)
      .trim()
      .toUpperCase();

    const creditAmount =
      Math.round(Number(benefit.benefitAmount) * 100) / 100;

    if (
      !Number.isFinite(creditAmount) ||
      creditAmount < 0 ||
      !["VENDOR", "RESELLER"].includes(beneficiaryRole)
    ) {
      throw new Error(
        `Invalid membership commission for ${beneficiaryId}`
      );
    }

    // Serialize commission attempts for this customer and beneficiary.
    await client.query(
      `SELECT pg_advisory_xact_lock(hashtext($1))`,
      [
        `MEMBERSHIP_BENEFIT:${cleanCustomerId}:` +
          `${beneficiaryId}:${beneficiaryRole}`,
      ]
    );

    // Confirm that the beneficiary is an active user with the expected role.
    const beneficiaryResult = await client.query(
      `
      SELECT ul.user_id
      FROM user_login ul
      JOIN lkp_user_roles lur
        ON lur.id = ul.role
      WHERE ul.user_id = $1
        AND UPPER(TRIM(lur.role_name)) = $2
        AND ul.is_active = 1
      LIMIT 1
      `,
      [beneficiaryId, beneficiaryRole]
    );

    if (beneficiaryResult.rows.length === 0) {
      throw new Error(
        `Active ${beneficiaryRole} user not found for ${beneficiaryId}`
      );
    }

    // Create the wallet only if this user does not already have one.
    await client.query(
      `
      INSERT INTO user_wallet
        (user_id, wallet_amount, prev_balance, current_balance,
         created_at, updated_at, created_by, is_active)
      VALUES ($1, 0, 0, 0, NOW(), NOW(), $2, 1)
      ON CONFLICT (user_id) DO NOTHING
      `,
      [beneficiaryId, cleanCustomerId]
    );

    // Lock the wallet row before checking and updating its balance.
    const walletResult = await client.query(
      `
      SELECT wallet_id, user_id, wallet_amount, current_balance
      FROM user_wallet
      WHERE user_id = $1
        AND is_active = 1
      FOR UPDATE
      `,
      [beneficiaryId]
    );

    const wallet = walletResult.rows[0];

    if (!wallet) {
      throw new Error(
        `Active wallet not found for ${beneficiaryId}`
      );
    }

    // Keep the existing rule: commission is credited once per
    // customer, beneficiary and role.
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
      [beneficiaryId, wallet.wallet_id, cleanCustomerId]
    );

    if (existingTransactionResult.rows.length > 0) {
      console.log(
        `Benefit already exists for customer ${cleanCustomerId} -> ` +
          `${beneficiaryId} (${beneficiaryRole}). Skipping.`
      );
      continue;
    }

    const updatedWalletResult = await client.query(
      `
      UPDATE user_wallet
      SET
        prev_balance = current_balance,
        current_balance = current_balance + $1,
        wallet_amount = current_balance + $1,
        updated_at = NOW(),
        updated_by = $2
      WHERE wallet_id = $3
        AND user_id = $4
        AND is_active = 1
      RETURNING wallet_id, user_id, current_balance
      `,
      [
        creditAmount,
        cleanCustomerId,
        wallet.wallet_id,
        beneficiaryId,
      ]
    );

    const updatedWallet = updatedWalletResult.rows[0];

    if (!updatedWallet) {
      throw new Error(
        `Unable to credit ${beneficiaryRole} wallet for ${beneficiaryId}`
      );
    }

    // Record the credit against the new wallet_id.
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
        created_at,
        is_active
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, NOW(), 1)
      `,
      [
        "CREDIT",
        `Membership commission [membership_id=${membershipId}; customer_id=${cleanCustomerId}; role=${beneficiaryRole}]`,
        cleanCustomerId,
        beneficiaryId,
        updatedWallet.wallet_id,
        benefit.benefitPercent,
        creditAmount,
        cleanCustomerId,
        "MEMBERSHIP_COMMISSION",
        "COMPLETED",
        updatedWallet.current_balance,
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