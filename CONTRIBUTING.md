# Contributing to ShopMicro

Welcome! This guide will help you set up your development environment and understand the workflow for contributing to the ShopMicro platform.

---

## 🛠️ Prerequisites

To help with this project, you need:
- **AWS CLI**: Configured with credentials that have sufficient permissions (Compute/Network/S3).
- **Terraform (v1.5+)**: For infrastructure changes.
- **Docker & Docker Compose**: For local testing and image building.
- **Node.js (v18+)** & **Python (v3.12)**: For local service development.

---

## 💻 Local Development Workflow

1. **Clone & Setup**:
   ```bash
   git clone https://github.com/amr-elzoghby/web-app.git
   cd web-app
   cp .env.example .env
   ```
2. **Environment Variables**: Update `.env` with your local secrets.
3. **Run Services**:
   ```bash
   cd web-app/ecommerce-microservices
   docker-compose up -d
   ```

---

## 🏗️ Infrastructure Workflow (Terraform)

We use a **layered state strategy**. If you are modifying the infrastructure, follow this lifecycle:

1. **Format Check**: Always run `terraform fmt -recursive` before committing.
2. **Lifecycle Order**:
   - Change common code in `modules/`.
   - Test in `environments/dev/` before touching `environments/prod/`.
3. **Deployment Order**:
   1. `network`: VPC and Security components.
   2. `storage`: S3 buckets.
   3. `compute`: ECR, ALB, ASG, and Lambda.

---

## 🔄 Branching & Pull Requests

1. **Branch Naming**:
   - `feature/description` for new features.
   - `fix/description` for bug fixes.
   - `infra/description` for IAC changes.
2. **PR Previews**: 
   - Add the label `pr-deploy` to your PR to trigger a temporary preview environment.
   - Wait for the **GitHub Actions** status checks to pass before asking for a review.
3. **Code Review**: All PRs must be reviewed and approved before merging into `main`.

---

## 🧪 Testing Standards

- **Terraform**: Must pass `terraform validate` and `tflint`.
- **Docker**: No secrets in Dockerfiles; images must scan clean on ECR.
- **Backend**: Ensure service-to-service communication works through the `nginx` gateway.

---

## 📜 Code of Conduct
Be professional, respect the non-root container constraints, and always optimize for cloud costs (delete temporary resources!).
