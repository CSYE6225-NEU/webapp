# CI/CD Pipeline and Deployment

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
3. Installs and configures the CloudWatch Agent
4. Configures the application without installing local MySQL
5. Creates an AMI from the instance
6. Shares the AMI with the target account using `ami_migration.sh`

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
  --image webapp-nodejs-rds-s3-cloudwatch-xxxxx \
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
      image = "webapp-nodejs-rds-s3-cloudwatch-xxxxx"
    }
  }
}
```