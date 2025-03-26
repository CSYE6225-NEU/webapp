const AWS = require("aws-sdk");
const cloudwatchService = require("./cloudwatchService");
require("dotenv").config();

// AWS S3 will automatically use the EC2 instance profile credentials
// when deployed on EC2, so we don't need to configure credentials
const s3 = new AWS.S3();

const bucketName = process.env.S3_BUCKET_NAME;

// Upload a file to S3
const uploadFile = async (file) => {
  const startTime = Date.now();
  
  try {
    const params = {
      Bucket: bucketName,
      Key: `${file.id}/${file.originalname}`,
      Body: file.buffer,
      ContentType: file.mimetype,
    };

    const result = await s3.upload(params).promise();
    
    // Record timing metric for S3 upload
    const executionTime = Date.now() - startTime;
    cloudwatchService.recordS3Timing('upload', executionTime);
    
    // Log the successful upload
    cloudwatchService.log('info', `File uploaded to S3`, {
      fileId: file.id,
      fileName: file.originalname,
      bucketName: bucketName,
      executionTime: `${executionTime}ms`
    });
    
    return result.Location;
  } catch (error) {
    // Log the error
    cloudwatchService.log('error', `S3 upload failed`, {
      fileId: file.id,
      fileName: file.originalname,
      bucketName: bucketName,
      error: error.message
    });
    throw error;
  }
};

// Delete a file from S3
const deleteFile = async (fileKey) => {
  const startTime = Date.now();
  
  try {
    const params = {
      Bucket: bucketName,
      Key: fileKey,
    };

    await s3.deleteObject(params).promise();
    
    // Record timing metric for S3 delete
    const executionTime = Date.now() - startTime;
    cloudwatchService.recordS3Timing('delete', executionTime);
    
    // Log the successful deletion
    cloudwatchService.log('info', `File deleted from S3`, {
      fileKey: fileKey,
      bucketName: bucketName,
      executionTime: `${executionTime}ms`
    });
  } catch (error) {
    // Log the error
    cloudwatchService.log('error', `S3 delete failed`, {
      fileKey: fileKey,
      bucketName: bucketName,
      error: error.message
    });
    throw error;
  }
};

module.exports = {
  uploadFile,
  deleteFile,
};