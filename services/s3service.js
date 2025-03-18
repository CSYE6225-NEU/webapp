const AWS = require("aws-sdk");
require("dotenv").config();

// AWS S3 will automatically use the EC2 instance profile credentials
// when deployed on EC2, so we don't need to configure credentials
const s3 = new AWS.S3();

const bucketName = process.env.S3_BUCKET_NAME;

// Upload a file to S3
const uploadFile = async (file) => {
  const params = {
    Bucket: bucketName,
    Key: `${file.id}/${file.originalname}`,
    Body: file.buffer,
    ContentType: file.mimetype,
  };

  const result = await s3.upload(params).promise();
  return result.Location;
};

// Delete a file from S3
const deleteFile = async (fileKey) => {
  const params = {
    Bucket: bucketName,
    Key: fileKey,
  };

  await s3.deleteObject(params).promise();
};

module.exports = {
  uploadFile,
  deleteFile,
};