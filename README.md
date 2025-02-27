# Health Check Web Application

A Node.js web application that provides a health check endpoint to monitor system status and database connectivity.

## Prerequisites

Before you begin, ensure you have the following installed on your system:

1. Node.js (version 14.x or higher)
2. MySQL Server (version 5.7 or higher)
3. npm (Node Package Manager, usually comes with Node.js)

## Environment Setup

1. Create a `.env` file in the root directory with the following variables:

```env
PORT= your_application port
DB_PORT=3306
DB_NAME=your_database_name
DB_USER=your_database_user
MYSQL_ROOT_PASSWORD=your_database_password
DB_HOST=localhost
```

## Database Setup

The database is already bootstrapped, but if you want to configure it beforehand, follow these steps:

1. Install MySQL Server on your system
2. Create a new database:

```sql
CREATE DATABASE your_database_name;
```

3. Create a database user with appropriate permissions:

```sql
CREATE USER 'your_database_user'@'localhost' IDENTIFIED BY 'your_database_password';
GRANT ALL PRIVILEGES ON your_database_name.* TO 'your_database_user'@'localhost';
FLUSH PRIVILEGES;
```

## Installation

1. Clone the repository:

```bash
git clone [repository-url]
cd webapp-remote
```

2. Install dependencies:

```bash
npm install
```

## Running the Application

1. Start the application:

```bash
npm start
```

The server will start on port specified in your .env file.

## Health Check Endpoint

The application provides a health check endpoint at `/healthz` with the following specifications:

- Method: GET
- Path: `/healthz`
- Success Response: 200 OK (empty body)
- Error Response: 503 Service Unavailable (when database connection fails)
- Invalid Method Response: 405 Method Not Allowed
- Invalid Route Response: 404 Not Found

## Unit Tests

The project includes unit tests located in the ⁠ **tests** ⁠ directory. These tests ensure the functionality and reliability of critical API features, including the health check endpoint.

## Scripts

A ⁠ scripts ⁠ folder contains a shell script (⁠ script.sh ⁠). This script is designed to automate setup tasks on a Linux cloud machine. It can:
•⁠ ⁠Set up the SQL database.
•⁠ ⁠Unzip and prepare the application

Additional Features:

- Blocks requests with authorization headers
- Blocks requests with non-empty payloads
- Blocks requests with query parameters
- Includes no-cache headers in responses
- Records successful health checks in the database

## Dependencies

- express: ^4.21.2
- sequelize: ^6.37.5
- mysql2: ^3.12.0
- dotenv: ^16.4.7

## Troubleshooting

If you encounter issues:

1. Check if MySQL server is running
2. Verify database credentials in .env file
3. Ensure all required ports are available
4. Check server logs for specific error messages
