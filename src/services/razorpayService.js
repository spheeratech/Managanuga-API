const Razorpay = require("razorpay");
const crypto = require("crypto");

const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});

const createRazorpayOrder = async (amount) => {
  return await razorpay.orders.create({
    amount: amount * 100,
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

module.exports = {
  createRazorpayOrder,
  verifyPaymentSignature,
};
