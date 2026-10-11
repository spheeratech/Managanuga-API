const FAQ = require("../models/FAQ");
const pool = require("../../db");
const { getRoleName } = require("../utils/userRoles");

const getFAQs = async (req, res) => {
  try {
    const { userId } = req.query;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    const loginResult = await pool.query(
      `
      SELECT
        user_login.user_id,
        user_login.id AS login_id,
        ur.role_name AS role
      FROM user_login
      LEFT JOIN user_roles ur
        ON ur.id = user_login.role
      WHERE (
        user_login.user_id = $1
        OR user_login.id::text = $1
      )
      AND user_login.is_active = 1
      LIMIT 1
      `,
      [String(userId).trim()]
    );

    const loginUser = loginResult.rows[0];

    if (!loginUser) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Convert numeric role ID to role name.
    const loginRole = getRoleName(loginUser.role);

    if (!loginRole) {
      return res.status(400).json({
        success: false,
        message: "Invalid user role",
      });
    }

    // Customer FAQ uses the USER FAQ document.
    const faqRole =
      loginRole === "CUSTOMER" ? "USER" : loginRole;

    if (!["USER", "VENDOR", "RESELLER"].includes(faqRole)) {
      return res.status(400).json({
        success: false,
        message: "FAQ is not available for this role",
      });
    }

    const faq = await FAQ.getByRole(faqRole);

    if (!faq) {
      return res.status(404).json({
        success: false,
        message: "FAQ document not found",
      });
    }

    return res.status(200).json({
      success: true,
      data: {
        user_id: loginUser.user_id,
        login_id: loginUser.login_id,
        login_role: loginRole,
        faq_role: faqRole,
        document_type: faq.document_type,
        document_link: faq.document_link,
        faqs: faq.faqs,
      },
    });
  } catch (error) {
    console.error("Get FAQs error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch FAQs",
    });
  }
};

module.exports = {
  getFAQs,
};