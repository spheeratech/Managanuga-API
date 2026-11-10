
const pool = require("../../db");
const Wallet = require("../models/Wallet");

const REFERRAL_PERCENTAGE = 10;

const normalizeUserId = (value) =>
  String(value || "").trim().toUpperCase();

const validateCustomerReferral = async ({
  referrerId,
  customerId,
}) => {
  const cleanReferrerId = normalizeUserId(referrerId);
  const cleanCustomerId = normalizeUserId(customerId);

  if (!cleanReferrerId || !cleanCustomerId) {
    throw new Error("Referral ID and customer ID are required");
  }

  if (cleanReferrerId === cleanCustomerId) {
    throw new Error("You cannot refer yourself");
  }

  const result = await pool.query(
    `
    SELECT ul.user_id
    FROM user_login ul
    INNER JOIN lkp_user_roles ur ON ur.id = ul.role
    WHERE UPPER(TRIM(ul.user_id)) = $1
      AND ul.is_active = 1
      AND UPPER(TRIM(ur.role_name)) = ANY($2::text[])
    LIMIT 1
    `,
    [cleanReferrerId, ["CUSTOMER", "USER"]]
  );

  if (!result.rows.length) {
    throw new Error("Invalid customer referral ID");
  }

  return {
    valid: true,
    referrerId: result.rows[0].user_id,
  };
};

const creditCustomerReferralReward = async ({
  referrerId,
  referredCustomerId,
  membershipId,
  planAmount,
}) => {
  const cleanPlanAmount = Number(planAmount);

  if (!Number.isFinite(cleanPlanAmount) || cleanPlanAmount <= 0) {
    throw new Error("Invalid subscription plan amount");
  }

  const rewardAmount =
    Math.round(
      cleanPlanAmount * REFERRAL_PERCENTAGE
    ) / 100;

  const transaction = await Wallet.creditCustomerWallet({
    userId: referrerId,
    amount: rewardAmount,
    referenceType: "CUSTOMER_REFERRAL",
    referenceId: membershipId,
    description: `Customer referral reward - Membership ${membershipId}`,
    benefitType: "CUSTOMER_REFERRAL",
    benefitedBy: referredCustomerId,
    benefitPercentage: REFERRAL_PERCENTAGE,
  });

  return {
    rewardAmount,
    percentage: REFERRAL_PERCENTAGE,
    transaction,
  };
};


const redeemCustomerReferralWithClient = async ({
  client,
  userId,
  amount,
  referenceType,
  referenceId,
}) => {
  const cleanUserId = normalizeUserId(userId);
  const cleanAmount = Number(amount);

  if (!client) {
    throw new Error("Database transaction client is required");
  }

  if (!cleanUserId) {
    throw new Error("Customer ID is required");
  }

  if (!Number.isFinite(cleanAmount) || cleanAmount <= 0) {
    throw new Error("Invalid referral wallet redemption amount");
  }

  const normalizedAmount = Math.round(cleanAmount * 100) / 100;

  const result = await Wallet.debitCustomerReferralWalletWithClient(
    client,
    {
      userId: cleanUserId,
      amount: normalizedAmount,
      referenceType,
      referenceId,
      description: `Referral wallet redemption for ${referenceType} ${referenceId}`,
    }
  );

  return {
    redeemedAmount: normalizedAmount,
    wallet: result.wallet,
    transaction: result.transaction,
    duplicate: result.duplicate,
  };
};


const getCustomerReferralSummary = async (userId) => {
  const cleanUserId = normalizeUserId(userId);

  const result = await pool.query(
    `
    SELECT
      COUNT(DISTINCT um.id) AS total_referrals,
      COALESCE(
        SUM(uwt.benefit_amount),
        0
      ) AS total_earnings
    FROM user_memberships um
    LEFT JOIN wallet_transactions uwt
      ON uwt.user_id = $1
      AND uwt.benefit_type = 'CUSTOMER_REFERRAL'
      AND uwt.transaction_type = 'CREDIT'
      AND uwt.status = 'COMPLETED'
      AND uwt.is_active = 1
      AND uwt.description LIKE
          '%[wallet-reference:["CUSTOMER_REFERRAL","%'
          || um.id::text
          || '"]}]%'
    WHERE UPPER(TRIM(um.referral_code)) = $1
      AND um.is_active = 1
    `,
    [cleanUserId]
  );

  return {
    referralId: cleanUserId,
    referralPercentage: REFERRAL_PERCENTAGE,
    totalReferrals: Number(result.rows[0].total_referrals),
    totalEarnings: Number(result.rows[0].total_earnings),
  };
};



module.exports = {
  validateCustomerReferral,
  creditCustomerReferralReward,
  redeemCustomerReferralWithClient,
  getCustomerReferralSummary,
};
