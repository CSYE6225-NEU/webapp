# NodeJS Cloud-Native Web Application with AWS RDS, S3, and CloudWatch Integration

A production-ready NodeJS application with AWS RDS, S3, and CloudWatch integration that provides health check monitoring, file storage capabilities, and comprehensive application metrics. The application is designed for deployment on AWS with comprehensive CI/CD pipelines.

## Overview

This project implements a Node.js web application with health monitoring capabilities that integrates with AWS RDS for data persistence, AWS S3 for file storage, and AWS CloudWatch for logging and metrics. It features a robust CI/CD pipeline using GitHub Actions for automated testing, building, and deployment to cloud environments. The application is packaged as a standalone binary and deployed as custom webapp machine images (AMIs in AWS and Compute Engine images in GCP).

### Use Case

The application provides a reliable health check API endpoint for monitoring service availability, robust file storage capabilities, and comprehensive metrics and logging, demonstrating cloud-native AWS service integration within a comprehensive deployment workflow.

## Feature Highlights

### AWS Service Integration

- **RDS Database Integration**:
  - Moves database from local MySQL to AWS RDS
  - Configures database in private subnet for security
  - Uses database parameter groups for optimal configuration
  - Implements connection pooling for performance
  - Secures access through VPC security groups
  - Records query timing metrics for performance monitoring

- **S3 Storage Solution**:
  - UUID-named S3 bucket with server-side encryption
  - Lifecycle policies for automatic storage class transitions after 30 days
  - Direct upload to S3 without temporary local storage
  - Secure URLs generation for file access
  - Proper cleanup of S3 objects on deletion
  - Records S3 operation timing metrics

- **CloudWatch Integration**:
  - Unified CloudWatch Agent installed and configured in AMI
  - IAM roles and permissions for CloudWatch metrics and logs
  - Custom metrics for API call counts and response times
  - Database query timing metrics
  - S3 operation timing metrics
  - Centralized application logging
  - System metrics capture (CPU, memory, disk)

- **IAM Security Integration**:
  - EC2 instance profiles for secure AWS service access
  - Custom IAM policies following least privilege principle
  - No hardcoded AWS credentials in application code
  - IAM role-based authorization for S3 and CloudWatch operations

### Application Features

- **Express API Server**: Lightweight and efficient RESTful API implementation
- **MySQL Integration**: Data persistence using a relational database
- **Sequelize ORM**: Type-safe database interactions with migration support
- **Health Monitoring**: Dedicated health check endpoint with database verification
- **File Operations**: Upload, retrieve, and delete files via API
- **Metrics Tracking**: StatsD-based metrics for all API calls and operations
- **Structured Logging**: Comprehensive application logging with proper levels
- **Cross-Platform Binary**: Packaged as a standalone executable using `pkg`
- **Infrastructure as Code**: Packer templates for creating machine images
- **Multi-Cloud Support**: Deployment to both AWS and GCP
- **Automated CI/CD**: GitHub Actions workflows for testing and deployment
- **Security-Focused**: Follows security best practices for web applications
- **Request Validation**:
  - Blocks requests with authorization headers
  - Blocks requests with non-empty payloads
  - Blocks requests with query parameters
  - Includes no-cache headers in responses
  - Properly handles HTTP method restrictions