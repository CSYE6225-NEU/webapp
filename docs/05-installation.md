# Installation and Running the Application

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

3. Install StatsD client for metrics
   ```bash
   npm install hot-shots --save
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