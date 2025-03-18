const express = require("express");
const router = express.Router();
const { uploadFile, getFile, deleteFile } = require("../controllers/fileController");
const { upload, handleFileUploadError } = require("../middleware/fileUploadMiddleware");

// POST /v1/file - Upload a file
router.post("/", upload.single("profilePic"), handleFileUploadError, uploadFile);

// GET /v1/file/:id - Get file metadata
router.get("/:id", getFile);

// DELETE /v1/file/:id - Delete a file
router.delete("/:id", deleteFile);

module.exports = router;