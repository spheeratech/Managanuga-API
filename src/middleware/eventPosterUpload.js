const multer = require("multer");
const path = require("path");
const fs = require("fs");

const uploadDir =
  process.env.EVENT_POSTER_UPLOAD_DIR ||
  path.resolve(__dirname, "../../../Managanuga-WebApp/public/images");

fs.mkdirSync(uploadDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (req, file, callback) => {
    callback(null, uploadDir);
  },

  filename: (req, file, callback) => {
    const extension = path.extname(file.originalname).toLowerCase();

    const originalName = path
      .basename(file.originalname, extension)
      .trim()
      .replace(/[^a-zA-Z0-9_-]/g, "-")
      .replace(/-+/g, "-")
      .replace(/^-|-$/g, "");

    const safeName = originalName || "event-poster";

    callback(null, `${safeName}-${Date.now()}${extension}`);
  },
});

const fileFilter = (req, file, callback) => {
  const allowedTypes = ["image/jpeg", "image/png", "image/webp", "image/gif"];

  if (!allowedTypes.includes(file.mimetype)) {
    return callback(
      new Error("Only JPG, PNG, WEBP and GIF images are allowed."),
    );
  }

  callback(null, true);
};

const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 10 * 1024 * 1024,
  },
});

module.exports = {
  upload,
  uploadDir,
};
