# CloudWatch Integration

## CloudWatch Agent Configuration

The application uses the AWS CloudWatch Agent to collect logs and metrics:

1. **Log Collection**:
   - Application logs from `/opt/csye6225/webapp.log`
   - System logs from `/var/log/syslog`
   - CloudWatch Agent logs from `/var/log/amazon/amazon-cloudwatch-agent/amazon-cloudwatch-agent.log`

2. **Metrics Collection**:
   - Custom StatsD metrics on port 8125
   - System metrics (CPU, memory, disk usage)
   - Custom namespace: `CSYE6225/Custom`
   - Instance dimensions for metric grouping

## Custom Application Metrics

The application tracks several types of custom metrics:

1. **API Usage Metrics**:
   - Count of API calls by endpoint
   - Response time for each API endpoint

2. **Database Metrics**:
   - Query execution time by operation type (SELECT, INSERT, etc.)

3. **S3 Metrics**:
   - File upload and delete operation timing

## Application Logging

Application logs are structured with the following information:

- Timestamp in ISO 8601 format
- Log level (INFO, WARN, ERROR)
- Descriptive message
- Additional contextual data (when applicable)

Logs can be viewed in CloudWatch Logs under the log group named with the pattern:
`{instance_id}-application-logs`

## Viewing Metrics and Logs

1. **CloudWatch Console**:
   - Navigate to CloudWatch > Metrics > All metrics
   - Find the "CSYE6225/Custom" namespace
   - View API, database, and S3 operation metrics

2. **CloudWatch Logs**:
   - Navigate to CloudWatch > Logs > Log groups
   - Find log groups with the instance ID prefix
   - View application logs, system logs, and agent logs

## Metrics Implementation

The application uses the hot-shots library to send StatsD metrics to the CloudWatch Agent:

```javascript
const StatsD = require('hot-shots');

// Create a StatsD client
const statsd = new StatsD({
  host: 'localhost', 
  port: 8125,
  prefix: 'webapp_'
});

// Record API call count
statsd.increment('api.healthcheck.count');

// Record API timing
statsd.timing('api.healthcheck.time', responseTime);

// Record database query timing
statsd.timing('db.select.time', queryTime);

// Record S3 operation timing
statsd.timing('s3.upload.time', uploadTime);
```