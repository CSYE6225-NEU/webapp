# System Architecture

## Component Interaction Diagram

```
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│   HTTP Client   │─────▶│   Express API   │─────▶│     AWS RDS     │
└─────────────────┘      └─────────────────┘      └─────────────────┘
                                │                         ▲
                                │                         │
                                ▼                         │
                         ┌─────────────────┐              │
                         │  Sequelize ORM  │──────────────┘
                         └─────────────────┘
                                │
                                ├─────────────┐
                                │             │
                                ▼             ▼
                         ┌─────────────────┐ ┌─────────────────┐
                         │  File Service   │ │ CloudWatch Svc  │
                         └─────────────────┘ └─────────────────┘
                                │                   │
                                ▼                   ▼
                         ┌─────────────────┐ ┌─────────────────┐
                         │     AWS S3      │ │   CloudWatch    │
                         └─────────────────┘ └─────────────────┘
```

## Application Components

- **Express Server**: Handles HTTP requests, input validation, and response formatting
- **Controller Layer**: Implements business logic for health check and file operations
- **Middleware Layer**: Performs request validation, method checking, and metrics tracking
- **Model Layer**: Defines database schema and interactions using Sequelize ORM
- **Service Layer**: Handles S3 interactions and CloudWatch metrics/logging
- **Database Layer**: AWS RDS MySQL/PostgreSQL database for persistent storage
- **Utility Services**: Database initialization and configuration management
- **Metrics Service**: Records custom metrics using StatsD protocol

## Deployment Architecture

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
                 │
                 ▼
        ┌─────────────────┐
        │   CloudWatch    │
        └─────────────────┘
```

# Infrastructure Components

## AWS Resources Utilized

- **VPC Network**: Custom VPC with public and private subnets
- **EC2 Instance**: Hosts the application with custom AMI
- **RDS Instance**: MySQL/PostgreSQL database for persistent storage
- **S3 Bucket**: Object storage for file uploads
- **CloudWatch**: Metrics, logs, and monitoring
- **Security Groups**: Network traffic control for instances
- **IAM Roles**: Identity and access management for services
- **Internet Gateway**: Public internet access for EC2
- **Route Tables**: Traffic routing between subnets
- **Subnet Groups**: Database subnet configuration
- **Parameter Groups**: Database configuration parameters

## Architecture Diagram

```
┌───────────────────────────────────────────────────────────────────────┐
│                             AWS Region                                │
│                                                                       │
│  ┌────────────────┐     ┌────────────────┐     ┌────────────────┐     │
│  │   AZ - us-1a   │     │   AZ - us-1b   │     │   AZ - us-1c   │     │
│  │                │     │                │     │                │     │
│  │  ┌──────────┐  │     │  ┌──────────┐  │     │  ┌──────────┐  │     │
│  │  │  Public  │  │     │  │  Public  │  │     │  │  Public  │  │     │
│  │  │  Subnet  │  │     │  │  Subnet  │  │     │  │  Subnet  │  │     │
│  │  └──────────┘  │     │  └──────────┘  │     │  └──────────┘  │     │
│  │       │        │     │                │     │                │     │
│  │       ▼        │     │                │     │                │     │
│  │  ┌──────────┐  │     │                │     │                │     │
│  │  │    EC2   │  │     │                │     │                │     │
│  │  │ Instance │──┼─────┼────────────────┼─────┼────────────┐   │     │
│  │  └──────────┘  │     │                │     │            │   │     │
│  │       │        │     │                │     │            │   │     │
│  │       │        │     │                │     │            │   │     │
│  │  ┌──────────┐  │     │  ┌──────────┐  │     │  ┌─────────▼─┐ │     │
│  │  │  Private │  │     │  │  Private │  │     │  │  Private  │ │     │
│  │  │  Subnet  │◀─┼─────┼──│  Subnet  │◀─┼─────┼──│  Subnet   │ │     │
│  │  └──────────┘  │     │  └──────────┘  │     │  └───────────┘ │     │
│  │                │     │       │        │     │                │     │
│  └────────────────┘     └───────┼────────┘     └────────────────┘     │
│                                 │                                     │
│                                 ▼                                     │
│                         ┌──────────────┐     ┌──────────────┐         │
│                         │     RDS      │     │  CloudWatch  │         │
│                         │   Instance   │     │              │         │
│                         └──────────────┘     └──────────────┘         │
│                                                                       │
│                         ┌──────────────┐                              │
│                         │      S3      │                              │
│                         │    Bucket    │                              │
│                         └──────────────┘                              │
└───────────────────────────────────────────────────────────────────────┘

```