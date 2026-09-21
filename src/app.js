// console.log("APP FILE LOADED");

const express = require("express");
const cors = require("cors");
require("dotenv").config();

const authRoutes = require("./routes/authRoutes");
const adminOrderRoutes = require("./routes/adminOrderRoutes");
const categoryRoutes = require("./routes/categoryRoutes");
const adminUserRoutes = require("./routes/adminUserRoutes");
const hubRoutes = require("./routes/hubRoutes");
const vendorRoutes = require("./routes/vendorRoutes");
const resellerRoutes = require("./routes/resellerRoutes");
const walletRoutes = require("./routes/walletRoutes");
const productRoutes = require("./routes/productRoutes");
const productReviewRoutes = require("./routes/productReviewRoutes");
const cartRoutes = require("./routes/cartRoutes");
const addressRoutes = require("./routes/addressRoutes");
const orderRoutes = require("./routes/orderRoutes");
const paymentRoutes = require("./routes/paymentRoutes");
const subscriptionRoutes = require("./routes/subscriptionRoutes");
const notificationRoutes = require("./routes/notificationRoutes");
const legalContentRoutes = require("./routes/legalContentRoutes");
const userDocumentRoutes = require("./routes/userDocumentRoutes");
const eventPosterRoutes = require("./routes/eventPosterRoutes");
const appImageRoutes = require("./routes/appImageRoutes");
const faqRoutes = require("./routes/faqRoutes");
const app = express();

// mobile App APIS

app.use(cors());
app.use(express.json());

app.use("/api/categories", categoryRoutes);


app.use("/api/auth", authRoutes);
app.use("/api/products", productRoutes);
app.use("/api/event-posters", eventPosterRoutes);
app.use("/api/products", productReviewRoutes);
app.use("/api/cart", cartRoutes);
app.use("/api/address", addressRoutes);
app.use("/api/user-documents", userDocumentRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/payments", paymentRoutes);
app.use("/api/wallet", walletRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/vendor", vendorRoutes);
app.use("/api/reseller", resellerRoutes);
app.use("/api/legal", legalContentRoutes);
app.use("/api/faqs", faqRoutes);

// Web APP APIs
app.use("/api/hubs", hubRoutes);
app.use("/api/admin/users", adminUserRoutes);
app.use("/api/admin/orders", adminOrderRoutes);

//Common APIs
app.use("/api/subscriptions", subscriptionRoutes);


// App-managed images: logo, banners, login background
app.use("/api/app-images", appImageRoutes);

app.get("/test", (req, res) => {
  res.json({
    message: "Main app working",
  });
});

module.exports = app;