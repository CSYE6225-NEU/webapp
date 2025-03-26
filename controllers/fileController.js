const File = require("../models/File");
const s3Service = require("../services/s3service");
const cloudwatchService = require("../services/cloudwatchService");
const { v4: uuidv4 } = require("uuid");

// Upload a file to S3 and store metadata in the database
const uploadFile = async (req, res) => {
  try {
    cloudwatchService.log('info', 'File upload initiated');
    
    if (!req.file) {
      cloudwatchService.log('warn', 'File upload failed - no file provided');
      return res.status(400).json({ error: "No file provided" });
    }

    // Generate a unique ID for the file
    const fileId = uuidv4();
    
    // Upload file to S3
    const file = {
      id: fileId,
      originalname: req.file.originalname,
      buffer: req.file.buffer,
      mimetype: req.file.mimetype,
    };
    
    const fileUrl = await s3Service.uploadFile(file);
    
    // Store file metadata in database
    const fileRecord = await File.create({
      id: fileId,
      file_name: req.file.originalname,
      url: fileUrl,
      upload_date: new Date(),
    });
    
    cloudwatchService.log('info', 'File upload completed successfully', {
      fileId: fileId,
      fileName: req.file.originalname
    });
    
    // Return file metadata
    return res.status(201).json({
      file_name: fileRecord.file_name,
      id: fileRecord.id,
      url: fileRecord.url,
      upload_date: fileRecord.upload_date.toISOString().split('T')[0],
    });
  } catch (error) {
    cloudwatchService.log('error', 'File upload failed', {
      error: error.message,
      stack: error.stack
    });
    return res.status(500).json({ error: "File upload failed" });
  }
};

// Get file metadata from the database
const getFile = async (req, res) => {
  try {
    const { id } = req.params;
    cloudwatchService.log('info', 'File metadata retrieval initiated', { fileId: id });
    
    // Find file metadata in database
    const file = await File.findOne({ where: { id } });
    
    if (!file) {
      cloudwatchService.log('warn', 'File not found', { fileId: id });
      return res.status(404).json({ error: "File not found" });
    }
    
    cloudwatchService.log('info', 'File metadata retrieved successfully', { fileId: id });
    
    // Return file metadata
    return res.status(200).json({
      file_name: file.file_name,
      id: file.id,
      url: file.url,
      upload_date: file.upload_date.toISOString().split('T')[0],
    });
  } catch (error) {
    cloudwatchService.log('error', 'Get file failed', {
      fileId: req.params.id,
      error: error.message,
      stack: error.stack
    });
    return res.status(500).json({ error: "Get file failed" });
  }
};

// Delete file from S3 and remove metadata from the database
const deleteFile = async (req, res) => {
  try {
    const { id } = req.params;
    cloudwatchService.log('info', 'File deletion initiated', { fileId: id });
    
    // Find file metadata in database
    const file = await File.findOne({ where: { id } });
    
    if (!file) {
      cloudwatchService.log('warn', 'File not found for deletion', { fileId: id });
      return res.status(404).json({ error: "File not found" });
    }
    
    // Extract the file key from the URL
    const url = new URL(file.url);
    const fileKey = url.pathname.substring(1); // Remove leading slash
    
    // Delete file from S3
    await s3Service.deleteFile(fileKey);
    
    // Delete file metadata from database
    await file.destroy();
    
    cloudwatchService.log('info', 'File deleted successfully', { 
      fileId: id,
      fileName: file.file_name
    });
    
    // Return success response with no content
    return res.status(204).end();
  } catch (error) {
    cloudwatchService.log('error', 'Delete file failed', {
      fileId: req.params.id,
      error: error.message,
      stack: error.stack
    });
    return res.status(500).json({ error: "Delete file failed" });
  }
};

module.exports = {
  uploadFile,
  getFile,
  deleteFile,
};