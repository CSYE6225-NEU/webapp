# Development and Project Structure

## Project Structure

```
.
├── config/               # Configuration files
│   └── database.js       # Database connection setup
├── controllers/          # Request handlers
│   ├── fileController.js # File operations handlers
│   └── healthCheckController.js
├── middleware/           # Express middleware functions
│   ├── fileUploadMiddleware.js # File upload middleware
│   ├── healthCheckMiddleware.js
│   └── metricsMiddleware.js # API metrics tracking middleware
├── models/               # Sequelize data models
│   ├── File.js           # File metadata model
│   └── HealthCheck.js
├── routes/               # API routes
│   ├── fileRoutes.js     # File operation routes
│   └── healthCheckRoutes.js
├── services/             # Service layer
│   ├── s3service.js      # S3 integration service
│   └── cloudwatchService.js # CloudWatch metrics and logging
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
│       ├── cloudwatch-setup.sh # CloudWatch agent setup
│       ├── amazon-cloudwatch-config.json # CloudWatch configuration
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

## Scripts

The `scripts` folder contains a shell script (`script.sh`) designed to automate setup tasks on a Linux cloud machine. It can:
- Set up the SQL database
- Unzip and prepare the application
- Configure system permissions and users

## Coding Standards

- **ESLint**: JavaScript linting with the Airbnb style guide
- **Prettier**: Code formatting
- **Jest**: Testing framework
- **JSDoc**: Documentation standard

## Development Workflow

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