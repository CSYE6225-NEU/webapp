# NodeJS MySQL Health Check Application

A production-ready NodeJS application with MySQL integration that provides a health check endpoint to monitor system status and database connectivity. The application is packaged for deployment across multiple cloud platforms (AWS and GCP) with comprehensive CI/CD pipelines.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [System Architecture](#system-architecture)
- [Prerequisites](#prerequisites)
- [Environment Setup](#environment-setup)
- [Database Setup](#database-setup)
- [Installation](#installation)
- [Running the Application](#running-the-application)
- [API Documentation](#api-documentation)
- [Development](#development)
- [Testing](#testing)
- [CI/CD Pipeline](#cicd-pipeline)
- [Deployment](#deployment)
  - [AWS Deployment](#aws-deployment)
  - [GCP Deployment](#gcp-deployment)
- [Monitoring](#monitoring)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgements](#acknowledgements)

## Overview

This project implements a Node.js web application with health monitoring capabilities that integrates with MySQL for data persistence. It features a robust CI/CD pipeline using GitHub Actions for automated testing, building, and deployment to both AWS and GCP cloud environments. The application is packaged as a standalone binary and deployed as custom machine images (AMIs in AWS and Compute Engine images in GCP).

### Use Case

The application provides a reliable health check API endpoint that can be used for monitoring service availability while demonstrating a comprehensive cloud deployment workflow across multiple providers.

## Features

- **Express API Server**: Lightweight and efficient RESTful API implementation
- **MySQL Integration**: Data persistence using a relational database
- **Sequelize ORM**: Type-safe database interactions with migration support
- **Health Monitoring**: Dedicated health check endpoint with database verification
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

## System Architecture

### Component Diagram

```
┌───────────────┐     ┌───────────────┐     ┌───────────────┐
│  HTTP Client  │────▶│  Express API  │────▶│    MySQL DB   │
└───────────────┘     └───────────────┘     └───────────────┘
                             │
                             ▼
                      ┌───────────────┐
                      │  Health Check │
                      │   Monitoring  │
                      └───────────────┘
```

### Application Components

- **Express Server**: Handles HTTP requests, input validation, and response formatting
- **Controller Layer**: Implements business logic for health check operations
- **Middleware Layer**: Performs request validation and security checks
- **Model Layer**: Defines database schema and interactions using Sequelize ORM
- **Database Layer**: MySQL database for persistent storage of health check records
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

## Prerequisites

- **Node.js**: v14.x or higher
- **npm**: v6.x or later
- **MySQL**: v5.7 or higher
- **Git**: v2.x or later
- **pkg**: v5.x or later (for binary packaging)
- **AWS CLI**: v2.x (for AWS deployment)
- **Google Cloud SDK**: v400.0.0 or later (for GCP deployment)
- **Packer**: v1.8.0 or later (for building machine images)
- **GitHub Account**: For CI/CD integration

## Environment Setup

1. Create a `.env` file in the root directory with the following variables:

```env
PORT=8080
DB_PORT=3306
DB_NAME=health_check
DB_USER=root
MYSQL_ROOT_PASSWORD=your_database_password
DB_HOST=localhost
```

## Database Setup

The database is bootstrapped automatically when the application runs. If you want to configure it manually beforehand:

1. Install MySQL Server on your system
2. Create a new database:
```sql
CREATE DATABASE health_check;
```
3. Create a database user with appropriate permissions:
```sql
CREATE USER 'root'@'localhost' IDENTIFIED BY 'your_database_password';
GRANT ALL PRIVILEGES ON health_check.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
```

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
pkg server.js --output dist/webapp --targets node14-linux-x64

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

## Development

### Project Structure

```
.
├── config/               # Configuration files
│   └── database.js       # Database connection setup
├── controllers/          # Request handlers
│   └── healthCheckController.js
├── middleware/           # Express middleware functions
│   └── healthCheckMiddleware.js
├── models/               # Sequelize data models
│   └── HealthCheck.js
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
├── .github/workflows/    # GitHub Actions workflows
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

The project includes three main GitHub Actions workflows:

#### 1. webapp-unit-test.yml

Runs unit tests for the application:
- Triggered on: push to `main`, pull requests to `main`
- Sets up MySQL service container
- Installs dependencies
- Runs test suite

#### 2. packer-validate.yml

Validates Packer configuration files:
- Triggered on: push to `main`, pull requests to `main`
- Installs Packer
- Formats and validates Packer templates

#### 3. packer-build.yml

Builds and deploys machine images:
- Triggered on: pull requests to `main` with changes in `infra/packer/` or workflow file
- Steps:
  1. Runs unit tests
  2. Validates Packer configuration
  3. Builds application binary
  4. Configures AWS and GCP credentials
  5. Builds AWS AMI and GCP Compute Image
  6. Shares AMI with DEMO AWS account
  7. Creates Machine Image from GCP Compute Image
  8. Shares Machine Image with DEMO GCP project

### Workflow Architecture

```
┌────────────────┐     ┌────────────────┐     ┌────────────────┐
│  Pull Request  │────▶│    Run Tests   │────▶│ Validate Packer│
└────────────────┘     └────────────────┘     └────────────────┘
                                                       │
                                                       ▼
┌────────────────┐     ┌────────────────┐     ┌────────────────┐
│ Share to DEMO  │◀────│  Build Images  │◀────│   Build App    │
└────────────────┘     └────────────────┘     └────────────────┘
```

## Deployment

### AWS Deployment

The application is packaged as an Amazon Machine Image (AMI) using Packer and can be deployed as EC2 instances.

#### AMI Creation Process

1. Packer provisions a temporary EC2 instance with Ubuntu 24.04
2. Uploads application binary and setup scripts
3. Installs MySQL and configures the application
4. Creates an AMI from the instance
5. Shares the AMI with the DEMO account using `ami_migration.sh`

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

#### GCP Image Creation Process

1. Packer provisions a temporary VM instance with Ubuntu 24.04
2. Uploads application binary and setup scripts
3. Installs MySQL and configures the application
4. Creates a GCP Compute Image
5. Creates a Machine Image using `gcp_migration.sh`
6. Shares the image with the DEMO project

#### Launching a VM from the Machine Image

```bash
gcloud compute instances create instance-name \
  --machine-type e2-medium \
  --image custom-nodejs-mysql-xxxxx \
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
      image = "custom-nodejs-mysql-xxxxx"
    }
  }
}
```

## Monitoring

### Health Check Monitoring

The application's `/healthz` endpoint can be used with monitoring systems like Prometheus, Nagios, or cloud provider health checks.

#### AWS CloudWatch Example

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name webapp-health-alarm \
  --alarm-description "Alarm when health check fails" \
  --metric-name HealthCheckStatus \
  --namespace AWS/EC2 \
  --statistic Minimum \
  --period 60 \
  --threshold 1 \
  --comparison-operator LessThanThreshold \
  --dimensions Name=InstanceId,Value=i-xxxxx \
  --evaluation-periods 1 \
  --alarm-actions arn:aws:sns:us-east-1:xxxx:alert-topic
```

#### GCP Monitoring Example

```bash
gcloud compute health-checks create http webapp-health-check \
  --port 8080 \
  --request-path /healthz
```

### Logging

The application logs are output to stdout/stderr and can be collected by services like CloudWatch Logs or Google Cloud Logging.

## Security Considerations

### Application Security

- **Input Validation**: Strict validation on all input parameters
- **No-Cache Headers**: Prevents sensitive information caching
- **X-Content-Type-Options**: Prevents MIME-type sniffing
- **Content Length Validation**: Prevents certain types of attacks
- **Method Restrictions**: Only allows specified HTTP methods
- **Authorization Header Blocking**: Prevents unauthorized access attempts

### Deployment Security

- **Dedicated User**: Application runs as a non-login system user
- **File Permissions**: Restrictive permissions on application files
  - App directory: `750` (rwxr-x---)
  - Env file: `600` (rw-------)
- **MySQL Security**: Database secured with password authentication
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

#### Application Won't Start

**Symptoms**: The application fails to start or returns a connection error.

**Solution**:
1. Check MySQL service is running:
   ```bash
   sudo systemctl status mysql
   ```
2. Verify database connection settings in `.env`
3. Check permissions on application directory
4. Ensure all required ports are available
5. Examine logs:
   ```bash
   sudo journalctl -u webapp.service
   ```

#### Health Check Returns 503

**Symptoms**: The health check endpoint returns a 503 Service Unavailable.

**Solution**:
1. Check database connection:
   ```bash
   mysql -u root -p -h localhost -e "SELECT 1;"
   ```
2. Verify user has proper permissions:
   ```bash
   mysql -u root -p -e "SHOW GRANTS FOR 'root'@'localhost';"
   ```
3. Check application logs for specific error messages

#### Packer Build Fails

**Symptoms**: The Packer build process fails during GitHub Actions workflow.

**Solution**:
1. Check GitHub Actions secrets are properly set
2. Verify IAM permissions for AWS and GCP service accounts
3. Review Packer logs in GitHub Actions output
4. Run Packer validate locally:
   ```bash
   cd infra/packer && packer validate machine-image.pkr.hcl
   ```

## Dependencies

- express: ^4.21.2
- sequelize: ^6.37.5
- mysql2: ^3.12.0
- dotenv: ^16.4.7
- pkg: ^5.8.1 (dev dependency for binary packaging)
- jest: ^29.7.0 (dev dependency for testing)
- supertest: ^7.0.0 (dev dependency for API testing)

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