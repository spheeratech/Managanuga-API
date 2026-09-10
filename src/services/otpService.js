const { sendSMS } = require("./smsService");

const otpStore = new Map();
const verifiedForgotPasswordStore = new Map();

const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

const sendOtp = async (mobile) => {
  const otp = generateOTP();

  console.log("GENERATED OTP:", otp);

  otpStore.set(mobile, {
    otp,
    expiresAt: Date.now() + 5 * 60 * 1000,
  });

  const message = `Use OTP ${otp} to complete your login to ManaGanuga. Do not share this code.`;

  await sendSMS(
    mobile,
    message,
    process.env.SMS_TEMPLATE_ID
  );

  return true;
};

const verifyOtp = (mobile, otp) => {
  const record = otpStore.get(mobile);

  if (!record) {
    return {
      success: false,
      message: "OTP not found",
    };
  }

  if (Date.now() > record.expiresAt) {
    otpStore.delete(mobile);

    return {
      success: false,
      message: "OTP expired",
    };
  }

  if (record.otp !== otp) {
    return {
      success: false,
      message: "Invalid OTP",
    };
  }

  otpStore.delete(mobile);

  return {
    success: true,
  };
};


// ==========================================
// FORGOT PASSWORD VERIFICATION
// ==========================================

const markForgotPasswordVerified = (mobile) => {
  verifiedForgotPasswordStore.set(mobile, {
    expiresAt: Date.now() + 10 * 60 * 1000,
  });
};


const isForgotPasswordVerified = (mobile) => {
  const record = verifiedForgotPasswordStore.get(mobile);

  if (!record) {
    return false;
  }

  if (Date.now() > record.expiresAt) {
    verifiedForgotPasswordStore.delete(mobile);
    return false;
  }

  return true;
};


const clearForgotPasswordVerified = (mobile) => {
  verifiedForgotPasswordStore.delete(mobile);
};


module.exports = {
  sendOtp,
  verifyOtp,
  markForgotPasswordVerified,
  isForgotPasswordVerified,
  clearForgotPasswordVerified,
};