const pool = require("../../db");

/**
 * Process Vendor / Reseller benefit for a membership.
 *
 * Rules:
 *
 * 1. Vendor directly assigned customer
 *    → Vendor gets 20%
 *
 * 2. Direct ManaGanuga reseller
 *    → Reseller gets 15%
 *
 * 3. Vendor-created reseller assigned customer
 *    → Vendor gets 10%
 *    → Reseller gets 10%
 *
 * 4. No valid assignment
 *    → No benefit
 */
const processMembershipBenefit = async ({
  membershipId,
  customerId,
  assignedBy,
  assignedRole,
  subscriptionAmount,
  client = pool,
}) => {

  // No assignment = no benefit
  if (!assignedBy || !assignedRole) {
    console.log(
      "No assigned beneficiary. No wallet benefit."
    );

    return [];
  }

  const benefits = [];

  /*
   * CASE 1
   * Customer assigned directly to Vendor
   */
  if (assignedRole === "VENDOR") {

    const vendorResult = await client.query(
      `
      SELECT user_id, role
      FROM user_login
      WHERE user_id = $1
        AND role = 'VENDOR'
      LIMIT 1
      `,
      [assignedBy]
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
   * CASE 2 / 3
   * Customer assigned to Reseller
   */
  else if (assignedRole === "RESELLER") {

    const resellerResult = await client.query(
      `
      SELECT
        user_id,
        role,
        created_by
      FROM user_login
      WHERE user_id = $1
        AND role = 'RESELLER'
      LIMIT 1
      `,
      [assignedBy]
    );

    const reseller = resellerResult.rows[0];

    if (!reseller) {
      throw new Error(
        "Assigned reseller not found."
      );
    }

    /*
     * Check whether this reseller
     * was created by a Vendor.
     */
    let parentVendor = null;

    if (reseller.created_by) {

      const vendorResult = await client.query(
        `
        SELECT
          user_id,
          role
        FROM user_login
        WHERE user_id = $1
          AND role = 'VENDOR'
        LIMIT 1
        `,
        [reseller.created_by]
      );

      parentVendor = vendorResult.rows[0];
    }

    /*
     * CASE 3
     * Vendor-created reseller
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
     * CASE 2
     * Direct ManaGanuga reseller
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
   * Credit wallets + create benefit records
   */
  for (const benefit of benefits) {

    /*
     * Make sure wallet exists.
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
     * Credit wallet.
     */
    await client.query(
      `
      UPDATE wallets
      SET
        balance = balance + $1,
        updated_at = NOW()
      WHERE user_id = $2
      `,
      [
        benefit.benefitAmount,
        benefit.beneficiaryId,
      ]
    );

    /*
     * Record benefit history.
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