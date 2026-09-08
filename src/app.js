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

app.use("/auth", authRoutes);
app.use("/products", productRoutes);
app.use("/event-posters", eventPosterRoutes);
app.use("/products", productReviewRoutes);
app.use("/cart", cartRoutes);
app.use("/address", addressRoutes);
app.use("/user-documents", userDocumentRoutes);
app.use("/orders", orderRoutes);
app.use("/payments", paymentRoutes);
app.use("/subscriptions", subscriptionRoutes);
app.use("/wallet", walletRoutes);
app.use("/notifications", notificationRoutes);
app.use("/vendor", vendorRoutes);
app.use("/reseller", resellerRoutes);
app.use("/legal", legalContentRoutes);
app.get("/test", (req, res) => {
res.json({
    message: "Main app working"
  });
});

module.exports = app;
