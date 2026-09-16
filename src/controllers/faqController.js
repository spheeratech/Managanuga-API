const FAQ = require("../models/FAQ");
const pool = require("../../db");

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
        user_id,
        id AS login_id,
        role
      FROM user_login
      WHERE (
        user_id = $1
        OR id::text = $1
      )
      AND is_active = true
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

    const faqRole =
      String(loginUser.role).toUpperCase() === "CUSTOMER"
        ? "USER"
        : String(loginUser.role).toUpperCase();

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
        login_role: loginUser.role,
        faq_role: faqRole,
        document_type: faq.document_type,
        document_link: faq.document_link,
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