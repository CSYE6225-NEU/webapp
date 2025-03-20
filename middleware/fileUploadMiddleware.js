const multer = require("multer");

// Configure multer to store files in memory
const storage = multer.memoryStorage();

// Filter files to only allow images
const fileFilter = (req, file, cb) => {
  // Accept only image files
  if (file.mimetype.startsWith("image/")) {
    cb(null, true);
  } else {
    cb(new Error("Only image files are allowed"), false);
  }
};

// Create multer upload instance
const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB file size limit
  },
});

// Handle file upload errors
const handleFileUploadError = (err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    // A Multer error occurred when uploading
    if (err.code === "LIMIT_FILE_SIZE") {
      return res.status(400).json({ error: "File too large" });
    }
    return res.status(400).json({ error: err.message });
  } else if (err) {
    // An unknown error occurred
    return res.status(400).json({ error: err.message });
  }
  // Everything went fine
  next();
};

// Method validation middleware for file routes
const validateFileMethod = (req, res, next) => {
  // For the root path /v1/file
  if (req.path === '/') {
    // Only allow POST and GET methods
    if (req.method === 'POST' || req.method === 'GET') {
      return next();
    }
    
    // Return 405 for all other methods
    return res.status(405).json({ error: "Method Not Allowed" });
  }
  
  // For specific file paths /v1/file/:id
  if (req.path.match(/^\/[^\/]+$/)) {  // Matches /:id but not nested paths
    // Only allow GET and DELETE methods
    if (req.method === 'GET' || req.method === 'DELETE') {
      return next();
    }
    
    // Return 405 for all other methods
    return res.status(405).json({ error: "Method Not Allowed" });
  }
  
  // If we get here, path wasn't handled - pass to next middleware
  next();
};

// Handle proper response for GET requests to root path
const handleRootGet = (req, res, next) => {
  if (req.method === 'GET' && req.path === '/') {
    // For GET /v1/file (without an ID), return 400 Bad Request
    return res.status(400).json({ error: "Bad Request" });
  }
  next();
};

module.exports = {
  upload,
  handleFileUploadError,
  validateFileMethod,
  handleRootGet
};