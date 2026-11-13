const Razorpay = require("razorpay");
const crypto = require("crypto");
const { logException, logIntegrationCall } = require("../utils/exceptionLogger");

const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});


const createRazorpayOrder = async (amount) => {
  const finalAmount = Math.round(Number(amount) * 100);

  return await razorpay.orders.create({
    amount: finalAmount,
    currency: "INR",
    receipt: "rcpt_" + Date.now(),
  });
};


const verifyPaymentSignature = (
  razorpay_order_id,
  razorpay_payment_id,
  razorpay_signature,
) => {
  const body = razorpay_order_id + "|" + razorpay_payment_id;

  const expected = crypto
    .createHmac("sha256", process.env.RAZORPAY_KEY_SECRET)
    .update(body)
    .digest("hex");

  return expected === razorpay_signature;
};
console.log("RAZORPAY KEY ID:", process.env.RAZORPAY_KEY_ID);
console.log(
  "RAZORPAY SECRET:",
  process.env.RAZORPAY_KEY_SECRET ? "LOADED" : "MISSING",
);

const fetchRazorpayPayment = async (paymentId) => {
  const startedAt = process.hrtime.bigint();

  try {
    const payment = await razorpay.payments.fetch(paymentId);
    await logIntegrationCall({
      service: "razorpay",
      operation: "payments.fetch",
      outcome: "success",
      durationMs: Number(process.hrtime.bigint() - startedAt) / 1e6,
      httpStatus: 200,
    });
    return payment;
  } catch (error) {
    const httpStatus = error.statusCode || error.status;

    await Promise.all([
      logIntegrationCall({
        service: "razorpay",
        operation: "payments.fetch",
        outcome: "failure",
        durationMs: Number(process.hrtime.bigint() - startedAt) / 1e6,
        error,
        httpStatus,
      }),
      logException(error),
    ]);
    throw error;
  }
};

module.exports = {
  createRazorpayOrder,
  verifyPaymentSignature,
  fetchRazorpayPayment
};
