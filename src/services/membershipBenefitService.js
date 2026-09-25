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
 * assignedRole = "RESELLER"
 *
 * The service then determines whether that reseller has a
 * parent vendor through user_login.created_by.
 */
const processMembershipBenefit = async ({
  membershipId,
  customerId,
  assignedBy,
  assignedRole,
  subscriptionAmount,
  client = pool,
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
  if (assignedRole === "VENDOR") {

    const vendorResult = await client.query(
      `
      SELECT
        user_id,
        role
      FROM user_login
      WHERE
        user_id = $1
        AND role = 'VENDOR'
        AND is_active = true
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
  else if (assignedRole === "RESELLER") {

    const resellerResult = await client.query(
      `
      SELECT
        user_id,
        role,
        created_by
      FROM user_login
      WHERE
        user_id = $1
        AND role = 'RESELLER'
        AND is_active = true
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
          AND role = 'VENDOR'
          AND is_active = true
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

    /*
     * --------------------------------------------------------
     * Make sure beneficiary wallet exists
     * --------------------------------------------------------
     */
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
        benefit.beneficiaryId,
        benefit.beneficiaryRole,
      ]
    );


    /*
     * --------------------------------------------------------
     * Credit wallet
     * --------------------------------------------------------
     */
    await client.query(
      `
      UPDATE wallets
      SET
        balance = balance + $1,
        updated_at = NOW()
      WHERE
        user_id = $2
      `,
      [
        benefit.benefitAmount,
        benefit.beneficiaryId,
      ]
    );


    /*
     * --------------------------------------------------------
     * Record benefit history
     * --------------------------------------------------------
     */
    await client.query(
      `
      INSERT INTO benefits
      (
        membership_id,
        customer_id,
        beneficiary_id,
        beneficiary_role,
        benefit_percent,
        benefit_amount,
        status
      )
      VALUES
      ($1, $2, $3, $4, $5, $6, 'CREDITED')
      `,
      [
        membershipId,
        customerId,
        benefit.beneficiaryId,
        benefit.beneficiaryRole,
        benefit.benefitPercent,
        benefit.benefitAmount,
      ]
    );
  }


  return benefits;
};


module.exports = {
  processMembershipBenefit,
};