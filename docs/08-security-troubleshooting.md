# Security and Troubleshooting

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

- **IAM Role-Based Access**: EC2 instance accesses S3 and CloudWatch via IAM roles, not credentials
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
   aws iam list-attached-role-policies --role-name EC2-Role
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

#### CloudWatch Integration Issues

**Symptoms**: No metrics or logs appearing in CloudWatch

**Solutions**:
1. Verify CloudWatch agent is running:
   ```bash
   sudo systemctl status amazon-cloudwatch-agent
   ```

2. Check CloudWatch agent configuration:
   ```bash
   cat /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
   ```

3. Verify IAM role has CloudWatch permissions:
   ```bash
   aws iam get-policy-document --policy-arn arn:aws:iam::<account-id>:policy/CloudWatch-Access
   ```

4. Check CloudWatch agent logs:
   ```bash
   cat /var/log/amazon/amazon-cloudwatch-agent/amazon-cloudwatch-agent.log
   ```

5. Restart CloudWatch agent:
   ```bash
   sudo systemctl restart amazon-cloudwatch-agent
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