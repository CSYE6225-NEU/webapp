# NodeJS Cloud-Native Web Application with AWS RDS and S3 Integration

A production-ready NodeJS application with AWS RDS and S3 integration that provides health check monitoring and file storage capabilities. The application is designed for deployment on AWS with comprehensive CI/CD pipelines.

## Table of Contents

- [Overview](#overview)
- [Feature Highlights](#feature-highlights)
- [System Architecture](#system-architecture)
- [Infrastructure Components](#infrastructure-components)
- [Prerequisites](#prerequisites)
- [Environment Setup](#environment-setup)
- [Database Configuration](#database-configuration)
- [S3 Storage Integration](#s3-storage-integration)
- [Installation](#installation)
- [Running the Application](#running-the-application)
- [API Documentation](#api-documentation)
- [Development](#development)
- [Testing](#testing)
- [CI/CD Pipeline](#cicd-pipeline)
- [Deployment](#deployment)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)
- [Dependencies](#dependencies)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgements](#acknowledgements)


## Overview

This project implements a Node.js web application with health monitoring capabilities that integrates with AWS RDS for data persistence and AWS S3 for file storage. It features a robust CI/CD pipeline using GitHub Actions for automated testing, building, and deployment to cloud environments. The application is packaged as a standalone binary and deployed as custom webapp machine images (AMIs in AWS and Compute Engine images in GCP).

### Use Case

The application provides a reliable health check API endpoint for monitoring service availability and robust file storage capabilities, demonstrating cloud-native AWS service integration within a comprehensive deployment workflow.

## Feature Highlights

### AWS Service Integration

- **RDS Database Integration**:
  - Moves database from local MySQL to AWS RDS
  - Configures database in private subnet for security
  - Uses database parameter groups for optimal configuration
  - Implements connection pooling for performance
  - Secures access through VPC security groups

- **S3 Storage Solution**:
  - UUID-named S3 bucket with server-side encryption
  - Lifecycle policies for automatic storage class transitions after 30 days
  - Direct upload to S3 without temporary local storage
  - Secure URLs generation for file access
  - Proper cleanup of S3 objects on deletion

- **IAM Security Integration**:
  - EC2 instance profiles for secure AWS service access
  - Custom IAM policies following least privilege principle
  - No hardcoded AWS credentials in application code
  - IAM role-based authorization for S3 operations

### Application Features

- **Express API Server**: Lightweight and efficient RESTful API implementation
- **MySQL Integration**: Data persistence using a relational database
- **Sequelize ORM**: Type-safe database interactions with migration support
- **Health Monitoring**: Dedicated health check endpoint with database verification
- **File Operations**: Upload, retrieve, and delete files via API
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

## System Architecture

### Component Interaction Diagram

```
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│   HTTP Client   │─────▶│   Express API   │─────▶│     AWS RDS     │
└─────────────────┘      └─────────────────┘      └─────────────────┘
                                │                         ▲
                                │                         │
                                ▼                         │
                         ┌─────────────────┐              │
                         │  Sequelize ORM  │──────────────┘
                         └─────────────────┘
                                │
                                │
                                ▼
                         ┌─────────────────┐      ┌─────────────────┐
                         │  File Service   │─────▶│     AWS S3      │
                         └─────────────────┘      └─────────────────┘
```

### Application Components

- **Express Server**: Handles HTTP requests, input validation, and response formatting
- **Controller Layer**: Implements business logic for health check and file operations
- **Middleware Layer**: Performs request validation, method checking, and security controls
- **Model Layer**: Defines database schema and interactions using Sequelize ORM
- **Service Layer**: Handles S3 interactions for file storage and retrieval
- **Database Layer**: AWS RDS MySQL/PostgreSQL database for persistent storage
- **Utility Services**: Database initialization and configuration management

### Deployment Architecture

```
┌─────────────────────┐     ┌─────────────────────┐
│   GitHub Actions    │────▶│   Packer Builder    │
└─────────────────────┘     └─────────────────────┘
                                     │
                 ┌───────────────────┴───────────────────┐
                 ▼                                       ▼
        ┌─────────────────┐                    ┌─────────────────┐
        │    AWS AMI      │                    │   GCP Image     │
        └─────────────────┘                    └─────────────────┘
                 │                                       │
                 ▼                                       ▼
        ┌─────────────────┐                    ┌─────────────────┐
        │  EC2 Instances  │                    │  GCP Instances  │
        └─────────────────┘                    └─────────────────┘
```

## Infrastructure Components

### AWS Resources Utilized

- **VPC Network**: Custom VPC with public and private subnets
- **EC2 Instance**: Hosts the application with custom AMI
- **RDS Instance**: MySQL/PostgreSQL database for persistent storage
- **S3 Bucket**: Object storage for file uploads
- **Security Groups**: Network traffic control for instances
- **IAM Roles**: Identity and access management for services
- **Internet Gateway**: Public internet access for EC2
- **Route Tables**: Traffic routing between subnets
- **Subnet Groups**: Database subnet configuration
- **Parameter Groups**: Database configuration parameters

### Architecture Diagram

```
┌────────────────────────────────────────────────────────────────────┐
│                              AWS Region                            │
│                                                                    │
│  ┌────────────────┐     ┌────────────────┐     ┌────────────────┐  │
│  │   AZ - us-1a   │     │   AZ - us-1b   │     │   AZ - us-1c   │  │
│  │                │     │                │     │                │  │
│  │  ┌──────────┐  │     │  ┌──────────┐  │     │  ┌──────────┐  │  │
│  │  │  Public  │  │     │  │  Public  │  │     │  │  Public  │  │  │
│  │  │  Subnet  │  │     │  │  Subnet  │  │     │  │  Subnet  │  │  │
│  │  └──────────┘  │     │  └──────────┘  │     │  └──────────┘  │  │
│  │       │        │     │                │     │                │  │
│  │       ▼        │     │                │     │                │  │
│  │  ┌──────────┐  │     │                │     │                │  │
│  │  │    EC2   │  │     │                │     │                │  │
│  │  │ Instance │  │     │                │     │                │  │
│  │  └──────────┘  │     │                │     │                │  │
│  │       │        │     │                │     │                │  │
│  │       │        │     │                │     │                │  │
│  │  ┌──────────┐  │     │  ┌──────────┐  │     │  ┌──────────┐  │  │
│  │  │  Private │  │     │  │  Private │  │     │  │  Private │  │  │
│  │  │  Subnet  │◀───────┼──│  Subnet  │◀───────┼──│  Subnet  │  │  │
│  │  └──────────┘  │     │  └──────────┘  │     │  └──────────┘  │  │
│  │                │     │       │        │     │                │  │
│  └────────────────┘     └───────┼────────┘     └────────────────┘  │
│                                 │                                   │
│                                 ▼                                   │
│                         ┌──────────────┐                            │
│                         │     RDS      │                            │
│                         │   Instance   │                            │
│                         └──────────────┘                            │
│                                                                     │
│                         ┌──────────────┐                            │
│                         │      S3      │                            │
│                         │    Bucket    │                            │
│                         └──────────────┘                            │
└─────────────────────────────────────────────────────────────────────┘
```

## Prerequisites

- **Node.js**: v18.x or higher
- **npm**: v8.x or later
- **MySQL/PostgreSQL**: v5.7 or higher for local development
- **Git**: v2.x or later
- **pkg**: v5.x or later (for binary packaging)
- **AWS CLI**: v2.x (for AWS deployment)
- **Google Cloud SDK**: v400.0.0 or later (for GCP deployment)
- **Packer**: v1.8.0 or later (for building machine images)
- **GitHub Account**: For CI/CD integration

## Environment Setup

### Local Development Environment

1. Create a `.env` file in the root directory with the following variables:

```env
# Application configuration
PORT=8080
NODE_ENV=development

# Local Database configuration
DB_NAME=csye6225
DB_USER=root
DB_PASSWORD=your_local_password
DB_HOST=localhost
DB_PORT=3306

# Mock S3 configuration for local development
S3_BUCKET_NAME=test-bucket
AWS_REGION=us-east-1
```

### Production Environment Variables

When deployed to EC2, these environment variables are set by the user data script:

```env
# Database Configuration
DB_HOST=your-rds-endpoint.region.rds.amazonaws.com
DB_PORT=3306
DB_NAME=csye6225
DB_USER=csye6225
DB_PASSWORD=your-secure-password

# S3 Configuration
S3_BUCKET_NAME=your-s3-bucket-uuid
PORT=8080
```

## Database Configuration

### Local Database Setup

The database is bootstrapped automatically when the application runs. If you want to configure it manually beforehand:

1. Install MySQL Server on your system
2. Create a new database:
```sql
CREATE DATABASE csye6225;
```
3. Create a database user with appropriate permissions:
```sql
CREATE USER 'root'@'localhost' IDENTIFIED BY 'your_database_password';
GRANT ALL PRIVILEGES ON csye6225.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
```

### RDS Integration Details

The application connects to AWS RDS using Sequelize ORM. Key integration points:

- **Connection Management**: Uses connection pooling for performance
- **Schema Migration**: Automatic table creation through Sequelize models
- **Error Handling**: Robust error handling for database connection issues
- **Transaction Support**: ACID compliance for data operations
- **Security**: Connection over private subnet with security group rules

## S3 Storage Integration

### AWS SDK Integration

The application uses the AWS SDK for JavaScript (v2) to interact with S3:

```javascript
const AWS = require("aws-sdk");
const s3 = new AWS.S3();

// When running on EC2 with proper IAM role, credentials are automatically provided
// No need to configure credentials in the code
```

### File Operation Flow

1. **Upload**: 
   - File received via multipart form data
   - File validated for type and size
   - File uploaded directly to S3 with UUID-based key
   - Metadata stored in RDS

2. **Retrieval**:
   - File ID received in API request
   - Metadata retrieved from database
   - S3 URL returned to client

3. **Deletion**:
   - File ID received in API request
   - Metadata retrieved from database
   - File deleted from S3
   - Metadata removed from database

## Installation

### Local Development Setup

1. Clone the repository
   ```bash
   git clone [repository-url]
   cd webapp-remote
   ```

2. Install dependencies
   ```bash
   npm install
   ```

### Docker Installation (Alternative)

```bash
# Build the Docker image
docker build -t webapp-mysql .

# Run the container
docker run -d -p 8080:8080 --env-file .env --name webapp webapp-mysql
```

## Running the Application

### Development Mode

```bash
npm start
```

The server will start on the port specified in your .env file.

### Building and Running the Binary

```bash
# Install pkg globally
npm install -g pkg

# Build the binary
pkg server.js --output dist/webapp --targets node18-linux-x64

# Run the binary
./dist/webapp
```

### Running with SystemD (Linux)

The application includes a SystemD service file (`webapp.service`) for running as a system service:

```bash
sudo cp webapp.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable webapp
sudo systemctl start webapp
sudo systemctl status webapp
```

## API Documentation

### Health Check Endpoint

#### GET /healthz

Verifies application health by validating database connectivity.

**Request**:
- Method: GET
- Headers: None required
- Body: Empty (required)
- Query Parameters: None allowed

**Response**:
- **200 OK**: Service is healthy
  ```
  (Empty response body)
  ```
  Headers:
  ```
  Cache-Control: no-cache, no-store, must-revalidate
  Pragma: no-cache
  X-Content-Type-Options: nosniff
  ```

- **400 Bad Request**: Invalid request parameters
- **405 Method Not Allowed**: Invalid HTTP method
- **503 Service Unavailable**: Database connection issue
- **404 Not Found**: Invalid route

**Constraints**:
- Authorization header must not be present
- Content-length must be zero or absent
- Query parameters are not allowed
- HEAD requests are not supported

### File Operations API

#### POST /v1/file

Uploads a file to S3 and stores metadata in the database.

**Request**:
- Method: POST
- Content-Type: multipart/form-data
- Body: Form data with "profilePic" field containing an image file

**Response**:
- **201 Created**: File uploaded successfully
  ```json
  {
    "file_name": "image.jpg",
    "id": "d290f1ee-6c54-4b01-90e6-d701748f0851",
    "url": "https://bucket-name.s3.amazonaws.com/d290f1ee-6c54-4b01-90e6-d701748f0851/image.jpg",
    "upload_date": "2025-03-19"
  }
  ```
- **400 Bad Request**: Invalid request or file type
- **405 Method Not Allowed**: Invalid HTTP method

#### GET /v1/file/{id}

Retrieves metadata for a specific file.

**Request**:
- Method: GET
- Path Parameter: id - The UUID of the file

**Response**:
- **200 OK**: File metadata retrieved successfully
- **404 Not Found**: File not found
- **405 Method Not Allowed**: Invalid HTTP method

#### DELETE /v1/file/{id}

Deletes a file from S3 and removes its metadata from the database.

**Request**:
- Method: DELETE
- Path Parameter: id - The UUID of the file

**Response**:
- **204 No Content**: File deleted successfully
- **404 Not Found**: File not found
- **405 Method Not Allowed**: Invalid HTTP method

## Development

### Project Structure

```
.
├── config/               # Configuration files
│   └── database.js       # Database connection setup
├── controllers/          # Request handlers
│   ├── fileController.js # File operations handlers
│   └── healthCheckController.js
├── middleware/           # Express middleware functions
│   ├── fileUploadMiddleware.js # File upload middleware
│   └── healthCheckMiddleware.js
├── models/               # Sequelize data models
│   ├── File.js           # File metadata model
│   └── HealthCheck.js
├── routes/               # API routes
│   ├── fileRoutes.js     # File operation routes
│   └── healthCheckRoutes.js
├── services/             # Service layer
│   └── s3service.js      # S3 integration service
├── utils/                # Utility functions
│   └── dbInitializer.js  # Database initialization
├── tests/                # Test files
├── scripts/              # Automation scripts
│   └── script.sh         # Linux cloud setup script
├── infra/                # Infrastructure files
│   └── packer/           # Packer configuration
│       ├── dist/         # Binary output directory
│       ├── machine-image.pkr.hcl  # Packer template
│       ├── setup.sh      # VM setup script
│       ├── ami_migration.sh  # AWS AMI sharing script
│       └── gcp_migration.sh  # GCP image sharing script
├── .github/              # GitHub configuration
│   ├── actions/          # Custom GitHub Actions
│   │   ├── build-binary/ # Binary build action
│   │   ├── cloud-credentials/ # Cloud credential setup action
│   │   └── setup-environment/ # Environment setup action
│   └── workflows/        # GitHub Actions workflows
│       ├── webapp-ci-pipeline.yml    # PR validation workflow
│       └── image-build-and-distribution.yml  # Image build workflow
├── app.js                # Express application setup
├── server.js             # Application entry point
├── package.json          # Project dependencies
├── .env.example          # Example environment variables
└── README.md             # Project documentation
```

### Scripts

The `scripts` folder contains a shell script (`script.sh`) designed to automate setup tasks on a Linux cloud machine. It can:
- Set up the SQL database
- Unzip and prepare the application
- Configure system permissions and users

### Coding Standards

- **ESLint**: JavaScript linting with the Airbnb style guide
- **Prettier**: Code formatting
- **Jest**: Testing framework
- **JSDoc**: Documentation standard

### Development Workflow

1. Create a feature branch from `main`
   ```bash
   git checkout -b feature/feature-name
   ```

2. Make your changes and write tests

3. Run tests and linting
   ```bash
   npm test
   npm run lint
   ```

4. Commit your changes using conventional commit messages
   ```bash
   git commit -m "feat: add new feature"
   ```

5. Push your branch and create a pull request
   ```bash
   git push origin feature/feature-name
   ```

## Testing

### Running Tests

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:coverage

# Run tests in watch mode
npm run test:watch
```

### Test Types

- **Unit Tests**: Test individual functions and components in isolation
- **Integration Tests**: Test interactions between components
- **API Tests**: Test HTTP endpoints using supertest

The project includes unit tests located in the `tests` directory. These tests ensure the functionality and reliability of critical API features, including the health check endpoint.

## CI/CD Pipeline

### GitHub Actions Workflows

The project includes two main GitHub Actions workflows with reusable components:

#### 1. webapp-ci-pipeline.yml

Validates the application code and Packer configuration:
- **Trigger**: Pull requests to `main`
- **Jobs**:
  - **run-tests**: Executes unit tests with MySQL integration
  - **validate_packer**: Builds application binary and validates Packer templates
- **Uses Custom Actions**:
  - `setup-environment`: Sets up Node.js and installs dependencies
  - `build-binary`: Creates the application executable

#### 2. image-build-and-distribution.yml

Builds and distributes cloud machine images:
- **Trigger**: Push to `main`
- **Jobs**:
  - **infrastructure_image_pipeline**: Builds and distributes cloud images
- **Key Steps**:
  1. Set up development environment
  2. Build application binary
  3. Configure cloud credentials for AWS and GCP
  4. Build cloud machine images using Packer
  5. Migrate images to target environments
  6. Verify successful image creation
  7. Clean up credentials

### Reusable Components

The CI/CD pipeline uses custom GitHub Actions for reusable functionality:

#### setup-environment

Sets up the development environment with proper tools and dependencies:
- Installs Node.js with specified version
- Configures npm cache
- Installs project dependencies
- Optionally installs pkg and Packer

#### build-binary

Creates the standalone application binary:
- Creates output directory
- Builds the binary using pkg
- Makes the binary executable
- Verifies successful build

#### cloud-credentials (not currently used)

Configures cloud provider credentials:
- Sets up AWS authentication
- Creates GCP service account key files
- Configures Google Cloud SDK

### Workflow Architecture

```
┌────────────────┐                          
│  Pull Request  │──┐                      
└────────────────┘  │                        
                    │  ┌────────────────┐   ┌────────────────┐
                    └─▶│  webapp-ci-    │──▶│ Validate Tests │
                       │   pipeline     │   │  and Packer    │
┌────────────────┐     └────────────────┘   └────────────────┘
│  Push to main  │──┐                                         
└────────────────┘  │                                         
                    │  ┌────────────────┐   ┌────────────────┐
                    └─▶│ image-build-   │──▶│ Build & Deploy │
                       │ distribution   │   │ Cloud Images   │
                       └────────────────┘   └────────────────┘
```

## Deployment

### AWS Deployment

The application is packaged as an Amazon Machine Image (AMI) using Packer and can be deployed as EC2 instances.

#### Packer Configuration for AWS

The Packer configuration in `machine-image.pkr.hcl` uses the following variables for AWS:

```hcl
variable "aws_build_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for building the AMI"
}

variable "aws_base_ami" {
  type        = string
  default     = "ami-0c7217cdde317cfec" // Ubuntu 24.04 LTS
  description = "Base AMI ID to use for the build"
}

variable "aws_vm_size" {
  type        = string
  default     = "t2.micro"
  description = "EC2 instance type to use for the build"
}

variable "target_account_id" {
  type        = string
  default     = "980921746832"
  description = "AWS account ID to share the AMI with"
}
```

#### AMI Creation Process

1. Packer provisions a temporary EC2 instance with Ubuntu 24.04
2. Uploads application binary and setup scripts
3. Configures the application without installing local MySQL
4. Creates an AMI from the instance
5. Shares the AMI with the target account using `ami_migration.sh`

#### Launching an Instance from the AMI

```bash
aws ec2 run-instances \
  --image-id ami-xxxxx \
  --instance-type t2.micro \
  --key-name YourKeyPair \
  --security-group-ids sg-xxxxx
```

### GCP Deployment

The application is packaged as a Google Compute Engine image using Packer and can be deployed as VM instances.

#### Packer Configuration for GCP

The Packer configuration in `machine-image.pkr.hcl` uses the following variables for GCP:

```hcl
variable "gcp_dev_project" {
  type        = string
  default     = "dev-project-452101"
  description = "GCP DEV project ID"
}

variable "gcp_target_project" {
  type        = string
  default     = ""
  description = "GCP DEMO project ID to share the image with"
}

variable "gcp_base_image" {
  type        = string
  default     = "ubuntu-2404-noble-amd64-v20250214"
  description = "Base GCP image to use for the build"
}

variable "gcp_build_zone" {
  type        = string
  default     = "us-east1-b"
  description = "GCP zone for building the image"
}

variable "gcp_vm_type" {
  type        = string
  default     = "e2-medium"
  description = "GCP machine type to use for the build"
}

variable "gcp_storage_region" {
  type        = string
  default     = "us"
  description = "GCP storage location for the machine image"
}
```

#### GCP Image Creation Process

1. Packer provisions a temporary VM instance with Ubuntu 24.04
2. Uploads application binary and setup scripts
3. Configures the application without installing local MySQL
4. Creates a GCP Compute Image
5. Creates a Machine Image using `gcp_migration.sh`
6. Shares the image with the target project

#### Launching a VM from the Machine Image

```bash
gcloud compute instances create instance-name \
  --machine-type e2-medium \
  --image webapp-nodejs-rds-s3-xxxxx \
  --image-project project-id
```

### Terraform Integration

The machine images created by Packer can be referenced in Terraform configurations for infrastructure automation:

```hcl
# AWS example
resource "aws_instance" "webapp" {
  ami           = "ami-xxxxx"
  instance_type = "t2.micro"
  tags = {
    Name = "webapp-instance"
  }
}

# GCP example
resource "google_compute_instance" "webapp" {
  name         = "webapp-instance"
  machine_type = "e2-medium"
  zone         = "us-east1-b"
  
  boot_disk {
    initialize_params {
      image = "webapp-nodejs-rds-s3-xxxxx"
    }
  }
}
```

## Security Considerations

### Application Security

- **Input Validation**: Strict validation on all input parameters
- **No-Cache Headers**: Prevents sensitive information caching
- **X-Content-Type-Options**: Prevents MIME-type sniffing
- **Content Length Validation**: Prevents certain types of attacks
- **Method Restrictions**: Only allows specified HTTP methods
- **Authorization Header Blocking**: Prevents unauthorized access attempts
- **File Type Validation**: Only accepts image files for upload

### Deployment Security

- **IAM Role-Based Access**: EC2 instance accesses S3 via IAM role, not credentials
- **Private Subnet for RDS**: Database only accessible from application security group
- **S3 Encryption**: Default server-side encryption for S3 objects
- **S3 Lifecycle Policy**: Transitions objects to STANDARD_IA after 30 days
- **Security Groups**: Traffic restricted to required ports and sources
- **Dedicated User**: Application runs as a non-login system user
- **File Permissions**: Restrictive permissions on application files
  - App directory: `750` (rwxr-x---)
  - Env file: `600` (rw-------)
- **AWS IAM**: Least privilege access for AWS operations
- **GCP IAM**: Service account permissions follow principle of least privilege

### Security Recommendations

- Enable HTTPS with proper TLS configuration
- Implement rate limiting
- Set up Web Application Firewall (WAF)
- Configure network security groups / firewall rules
- Enable audit logging

## Troubleshooting

### Common Issues

#### S3 Access Issues

**Symptoms**: Unable to upload or retrieve files, errors in logs about access denied

**Solutions**:
1. Verify IAM role is attached to EC2 instance
   ```bash
   # Check instance profile association
   aws ec2 describe-instances --instance-id i-xxxx --query 'Reservations[0].Instances[0].IamInstanceProfile'
   ```

2. Check IAM policy permissions
   ```bash
   # View attached policies
   aws iam list-attached-role-policies --role-name EC2-S3-Role
   ```

3. Ensure S3 bucket exists and name is correct in environment variables
   ```bash
   # List S3 buckets
   aws s3 ls
   ```

#### RDS Connection Issues

**Symptoms**: Health check fails with 503 error, database connection errors in logs

**Solutions**:
1. Verify security group allows traffic from application to RDS
   ```bash
   # Check security group rules
   aws ec2 describe-security-groups --group-id sg-xxxx
   ```

2. Check RDS instance status and endpoint in AWS console
3. Test database connection from EC2 instance:
   ```bash
   mysql -h <rds-endpoint> -u csye6225 -p
   ```
4. Verify environment variables are correctly set:
   ```bash
   cat /opt/csye6225/.env
   ```

#### Application Won't Start

**Symptoms**: The application fails to start or returns a connection error.

**Solution**:
1. Check RDS is running:
   ```bash
   aws rds describe-db-instances --db-instance-identifier csye6225 --query 'DBInstances[0].DBInstanceStatus'
   ```
2. Verify database connection settings in `.env`
3. Check permissions on application directory
4. Ensure all required ports are available
5. Examine logs:
   ```bash
   sudo journalctl -u webapp.service
   ```

#### Packer Build Fails

**Symptoms**: The Packer build process fails during GitHub Actions workflow.

**Possible Causes and Solutions**:

1. **Variable Name Mismatch**:
   - Ensure the variable names in `machine-image.pkr.hcl` match those passed to Packer in the GitHub Actions workflow
   - Check for common errors like using `demo_account_id` when the variable is now `target_account_id`

2. **Missing Variables**:
   - Make sure all required variables are passed to Packer. Required variables include:
     - `target_account_id`
     - `gcp_dev_project`
     - `gcp_target_project`
     - `aws_build_region`
     - `gcp_build_zone`
     - `aws_vm_size`
     - `gcp_vm_type`
     - `gcp_storage_region`

3. **GitHub Actions Workflow Issues**:
   - Check if the workflow is triggered correctly
   - Verify the workflow steps execute in the expected order
   - Examine any errors in composite actions

## Dependencies

Primary dependencies for this application:

- **express**: ^4.21.2 - Web server framework
- **sequelize**: ^6.37.5 - ORM for database operations
- **mysql2**: ^3.12.0 - MySQL client for Node.js
- **aws-sdk**: ^2.1579.0 - AWS SDK for S3 integration
- **multer**: ^1.4.5-lts.1 - Middleware for handling multipart/form-data
- **uuid**: ^9.0.1 - UUID generation for file IDs
- **dotenv**: ^16.4.7 - Environment variable management
- **pkg**: ^5.8.1 (dev dependency for binary packaging)
- **jest**: ^29.7.0 (dev dependency for testing)
- **supertest**: ^7.0.0 (dev dependency for API testing)

## Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. Commit your changes
   ```bash
   git commit -m 'feat: add amazing feature'
   ```
4. Push to the branch
   ```bash
   git push origin feature/amazing-feature
   ```
5. Open a Pull Request

Please ensure your code passes all tests and follows the project's coding standards.

### Commit Message Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/) specification:

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Build process or auxiliary tool changes



## Acknowledgements

- [Express.js](https://expressjs.com/)
- [Sequelize](https://sequelize.org/)
- [MySQL](https://www.mysql.com/)
- [pkg](https://github.com/vercel/pkg)
- [Packer](https://www.packer.io/)
- [GitHub Actions](https://github.com/features/actions)