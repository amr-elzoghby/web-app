# Environments Configuration

This directory contains the root orchestration files for different deployment environments.

## Structure
- Each environment (e.g., `dev`, `prod`) acts as a standalone Terraform project.
- Each environment is subdivided into layers (`network`, `storage`, `compute`) to ensure isolated state files for each component.

## How to Deploy

### 1. Initialize Backend
For any environment/layer, always run init first:
```bash
cd environments/dev/network
terraform init
```

### 2. Follow Deployment Order
Due to dependencies, deploy in this order:
1.  **Network**: `cd environments/<env>/network && terraform apply`
2.  **Storage**: `cd environments/<env>/storage && terraform apply`
3.  **Compute**: `cd environments/<env>/compute && terraform apply`

## Key Differences

| Feature | Development (Dev) | Production (Prod) |
| :--- | :--- | :--- |
| **Name Prefix** | `shop-dev` | `shop-prod` |
| **Instance Type** | `t3.micro` | `t3.medium` |
| **VPC CIDR** | `10.0.0.0/16` | `10.1.0.0/16` |
| **ASG Scale** | 1 desired | 2 desired (Multi-AZ) |
| **State Path** | `dev/` in S3 | `prod/` in S3 |
