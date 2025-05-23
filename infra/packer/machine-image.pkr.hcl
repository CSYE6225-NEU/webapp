packer {
  required_plugins {
    amazon-ebs = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = ">= 1.0.0"
    }
  }
}

# AWS Configuration Variables
# ===========================================================
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

# GCP Configuration Variables
# ===========================================================
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

# AWS AMI Build Configuration
# ===========================================================
source "amazon-ebs" "ubuntu" {
  region                      = var.aws_build_region
  source_ami                  = var.aws_base_ami
  instance_type               = var.aws_vm_size
  ssh_username                = "ubuntu"
  ami_name                    = "webapp-nodejs-rds-s3-cloudwatch-{{timestamp}}"
  ami_description             = "Custom webapp image with Node.js binary (RDS, S3, CloudWatch enabled)"
  associate_public_ip_address = true
  ssh_timeout                 = "10m"

  # Share AMI with the DEMO account
  ami_users = [var.target_account_id]
}

# GCP Image Build Configuration
# ===========================================================
source "googlecompute" "ubuntu" {
  project_id           = var.gcp_dev_project
  source_image         = var.gcp_base_image
  machine_type         = var.gcp_vm_type
  zone                 = var.gcp_build_zone
  image_name           = "webapp-nodejs-rds-s3-cloudwatch-{{timestamp}}"
  image_family         = "webapp-images"
  image_description    = "Webapp GCP image with Node.js (RDS, S3, CloudWatch enabled)"
  ssh_username         = "ubuntu"
  wait_to_add_ssh_keys = "10s"
}

# Build Definition
# ===========================================================
build {
  sources = [
    "source.amazon-ebs.ubuntu",
    "source.googlecompute.ubuntu"
  ]

  # Upgrade OS packages first
  provisioner "shell" {
    inline = [
      "echo 'Updating system packages...'",
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y",

      "echo 'Installing required packages...'",
      "sudo apt-get install -y software-properties-common",
      "sudo add-apt-repository -y universe",
      "sudo apt-get update",

      "# Install Node.js using NodeSource repository",
      "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -",
      "sudo apt-get install -y nodejs",

      "# Install AWS CLI v2",
      "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'",
      "sudo apt-get install -y unzip",
      "unzip awscliv2.zip",
      "sudo ./aws/install",
      "rm -rf aws awscliv2.zip",

      "# Install jq",
      "sudo apt-get install -y jq"
    ]
  }

  # Copy application files to the image
  provisioner "file" {
    source      = "dist/webapp"
    destination = "/tmp/webapp"
  }

  # Copy setup script and service definition
  provisioner "file" {
    source      = "setup.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "file" {
    source      = "webapp.service"
    destination = "/tmp/webapp.service"
  }

  # Copy CloudWatch agent configuration
  provisioner "file" {
    source      = "cloudwatch-setup.sh"
    destination = "/tmp/cloudwatch-setup.sh"
  }

  provisioner "file" {
    source      = "amazon-cloudwatch-config.json"
    destination = "/tmp/amazon-cloudwatch-config.json"
  }

  # Execute the setup scripts
  provisioner "shell" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo /tmp/setup.sh",
      "chmod +x /tmp/cloudwatch-setup.sh",
      "sudo /tmp/cloudwatch-setup.sh"
    ]
  }
}