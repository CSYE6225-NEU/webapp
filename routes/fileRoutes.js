// routes/fileRoutes.js
const express = require("express");
const router = express.Router();
const { uploadFile, getFile, deleteFile } = require("../controllers/fileController");
const { 
  upload, 
  handleFileUploadError,
  validateFileMethod,
  handleRootGet
} = require("../middleware/fileUploadMiddleware");

// Apply method validation to all requests first
router.use(validateFileMethod);

// Handle GET requests to root path
router.use(handleRootGet);

// Define the allowed routes
router.post("/", upload.single("profilePic"), handleFileUploadError, uploadFile);
router.get("/:id", getFile);
router.delete("/:id", deleteFile);

module.exports = router;