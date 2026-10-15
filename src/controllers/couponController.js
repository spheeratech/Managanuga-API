
const Coupon = require("../models/Coupon");
const Membership = require("../models/Membership");

const MEMBERSHIP_COUPON_ERROR =
  "Invalid coupon. Your membership discount is greater than this coupon discount.";

const validateCoupon = async (req, res) => {
  try {
    const { couponCode, totalLitres } = req.body;

    if (!couponCode || !String(couponCode).trim()) {
      return res.status(400).json({
        success: false,
        message: "Coupon code is required",
      });
    }

    const coupon = await Coupon.findByCode(
      String(couponCode).trim()
    );

    if (!coupon) {
      return res.status(404).json({
        success: false,
        message: "Invalid coupon",
      });
    }

    if (Number(coupon.is_active) !== 1) {
      return res.status(400).json({
        success: false,
        message: "Coupon expired",
      });
    }

    if (
      !Number.isFinite(Number(coupon.coupon_percentage)) ||
      Number(coupon.coupon_percentage) < 0
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid coupon",
      });
    }

    if (
      !Number.isFinite(Number(totalLitres)) ||
      Number(totalLitres) < 2
    ) {
      return res.status(400).json({
        success: false,
        message: "This coupon requires a minimum purchase of 2 litres",
      });
    }

    const membership = await Membership.getActiveMembership(
      req.authenticatedUser.id
    );
    if (membership) {
      const planPercentage = Number(membership.discount_percentage);
      if (
        !Number.isFinite(planPercentage) ||
        Number(coupon.coupon_percentage) <= planPercentage
      ) {
        return res.status(400).json({
          success: false,
          message: MEMBERSHIP_COUPON_ERROR,
        });
      }
    }

    const alreadyUsed = await Coupon.hasSuccessfulUseForUser({
      userId: req.authenticatedUser.id,
      couponId: coupon.coupon_id,
    });

    if (alreadyUsed) {
      return res.status(400).json({
        success: false,
        message: "You have already used this coupon",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Coupon applied successfully",
      data: {
        coupon_id: coupon.coupon_id,
        coupon_name: coupon.coupon_name,
        coupon_code: coupon.coupon_code,
        coupon_percentage: Number(coupon.coupon_percentage),
        coupon_eligible: coupon.coupon_eligible,
      },
    });
  } catch (error) {
    console.error("VALIDATE COUPON ERROR:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to validate coupon", 
    });
  }
};

module.exports = {
  validateCoupon,
};
