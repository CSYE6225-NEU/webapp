# Dependencies and Contributing

## Dependencies

Primary dependencies for this application:

- **express**: ^4.21.2 - Web server framework
- **sequelize**: ^6.37.5 - ORM for database operations
- **mysql2**: ^3.12.0 - MySQL client for Node.js
- **aws-sdk**: ^2.1579.0 - AWS SDK for S3 integration
- **multer**: ^1.4.5-lts.1 - Middleware for handling multipart/form-data
- **uuid**: ^9.0.1 - UUID generation for file IDs
- **dotenv**: ^16.4.7 - Environment variable management
- **hot-shots**: ^10.0.0 - StatsD client for CloudWatch metrics
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
- [AWS CloudWatch](https://aws.amazon.com/cloudwatch/)
- [StatsD](https://github.com/statsd/statsd)