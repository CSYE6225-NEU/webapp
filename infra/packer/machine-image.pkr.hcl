packer {
  required_plugins {
    amazon-ebs = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = ">= 1.0.0" # Ensures compatibility with latest features
    }
  }
}

# Timestamp for unique image identification and traceability
variable "timestamp" {
  type    = string
  default = "${formattime("YYYYMMDD-hhmmss", timestamp())}"
}

# AWS environment configuration parameters
variable "aws_region" {
  type    = string
  default = "us-east-1"
  description = "AWS region where the image will be built"
}

variable "aws_source_ami" {
  type    = string
  default = "ami-0812f893ed55215a7"
  description = "Base Ubuntu 24.04 LTS AMI to build upon"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
  description = "AWS instance type for the build process"
}

variable "demo_account_id" {
  type    = string
  default = ""
  description = "Target AWS account ID for cross-account image sharing"
}

# GCP environment configuration parameters
variable "gcp_project_id" {
  type    = string
  default = ""
  description = "Source GCP project for image building"
}

variable "gcp_demo_project_id" {
  type    = string
  default = ""
  description = "Target GCP project for image sharing"
}

variable "gcp_source_image" {
  type    = string
  default = "ubuntu-2404-noble-amd64-v20250214"
  description = "Base Ubuntu 24.04 image for GCP builds"
}

variable "gcp_zone" {
  type    = string
  default = "us-east1-b"
  description = "GCP zone for the build environment"
}

variable "gcp_machine_type" {
  type    = string
  default = "e2-medium"
  description = "GCP instance type for the build process"
}

variable "gcp_storage_location" {
  type    = string
  default = "us"
  description = "Multi-regional storage location for the GCP image"
}

# Common image naming convention for cross-platform consistency
locals {
  image_name = "custom-nodejs-mysql-${var.timestamp}"
}

# AWS builder configuration for AMI creation
source "amazon-ebs" "ubuntu" {
  region                      = var.aws_region
  source_ami                  = var.aws_source_ami
  instance_type               = var.instance_type
  ssh_username                = "ubuntu"
  ami_name                    = local.image_name
  ami_description             = "Production-ready image with Node.js runtime and MySQL database"
  associate_public_ip_address = true
  ssh_timeout                 = "10m"
  
  # Conditional AMI sharing with demo environment
  ami_users                   = var.demo_account_id != "" ? [var.demo_account_id] : []
  
  tags = {
    Name        = local.image_name
    Environment = "dev"
    BuildDate   = var.timestamp
    Managed     = "Packer"
  }
}

# GCP builder configuration for Compute Engine image creation
source "googlecompute" "ubuntu" {
  project_id         = var.gcp_project_id
  source_image       = var.gcp_source_image
  machine_type       = var.gcp_machine_type
  zone               = var.gcp_zone
  image_name         = local.image_name
  image_family       = "custom-images"
  image_description  = "Production-ready image with Node.js runtime and MySQL database"
  ssh_username       = "ubuntu"
  wait_to_add_ssh_keys = "10s"
  
  labels = {
    environment = "dev"
    build_date  = var.timestamp
    managed     = "packer"
  }
}

# Build process definition
build {
  name = "webapp-image"
  
  sources = [
    "source.amazon-ebs.ubuntu",
    "source.googlecompute.ubuntu"
  ]

  # Stage 1: Transfer application binary
  provisioner "file" {
    source      = "dist/webapp"
    destination = "/tmp/webapp"
  }

  # Stage 2: Transfer installation script
  provisioner "file" {
    source      = "setup.sh"
    destination = "/tmp/setup.sh"
  }
  
  # Stage 3: Transfer service definition
  provisioner "file" {
    source      = "webapp.service"
    destination = "/tmp/webapp.service"
  }

  # Stage 4: Execute installation process
  provisioner "shell" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo /tmp/setup.sh"
    ]
  }

  # Generate build metadata for deployment automation
  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}