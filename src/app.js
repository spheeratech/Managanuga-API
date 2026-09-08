// console.log("APP FILE LOADED");
const express = require("express");
const cors = require("cors");
require("dotenv").config();
const vendorRoutes = require("./routes/vendorRoutes");
const resellerRoutes = require("./routes/resellerRoutes");
const authRoutes = require("./routes/authRoutes");
const walletRoutes = require("./routes/walletRoutes");
const productRoutes = require("./routes/productRoutes");
const productReviewRoutes = require("./routes/productReviewRoutes");
const cartRoutes = require("./routes/cartRoutes");
const app = express();
const addressRoutes = require("./routes/addressRoutes");
const orderRoutes = require("./routes/orderRoutes");
const paymentRoutes = require("./routes/paymentRoutes");
const subscriptionRoutes = require("./routes/subscriptionRoutes");
const notificationRoutes = require("./routes/notificationRoutes");
const legalContentRoutes = require("./routes/legalContentRoutes");
const userDocumentRoutes = require("./routes/userDocumentRoutes");
const eventPosterRoutes = require("./routes/eventPosterRoutes");
app.use(cors());
app.use(express.json());

app.use("/api/auth", authRoutes);
app.use("/api/products", productRoutes);
app.use("/api/event-posters", eventPosterRoutes);
app.use("/api/products", productReviewRoutes);
app.use("/api/cart", cartRoutes);
app.use("/api/address", addressRoutes);
app.use("/api/user-documents", userDocumentRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/payments", paymentRoutes);
app.use("/api/subscriptions", subscriptionRoutes);
app.use("/api/wallet", walletRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/vendor", vendorRoutes);
app.use("/api/reseller", resellerRoutes);
app.use("/api/legal", legalContentRoutes);
app.get("/test", (req, res) => {
res.json({
    message: "Main app working"
  });
});

module.exports = app;
