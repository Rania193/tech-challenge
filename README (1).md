# Kantox Cloud Engineer Challenge 🚀

Kubernetes-native microservices with GitOps (Argo CD), Terraform IaC, AWS integration (ECR, S3, SSM), and an end-to-end GitHub Actions CI/CD pipeline.

---

## Table of Contents

1. [Project Layout](#project-layout)  
2. [Architecture Overview](#architecture-overview)  
3. [Terraform (IaC)](#terraform-iac)  
4. [CI/CD – GitHub Actions](#cicd--github-actions)  
5. [Local Deployment Guide](#local-deployment-guide)  
6. [Argo CD Usage](#argo-cd-usage)  
7. [Verifying a Successful Release](#verifying-a-successful-release)  
8. [API Testing Guide](#api-testing-guide)  

---

## Project Layout

```text
.
├── argocd/
│   └── kantox-challenge-app.yaml        # Argo CD Application CR
├── k8s/                                 # K8s manifests (synced by Argo CD)
│   ├── config/
│   │   ├── configmap-main.yaml
│   │   └── configmap-aux.yaml
│   ├── deployments/
│   │   ├── main-api-deployment.yaml
│   │   └── auxiliary-service-deployment.yaml
│   ├── namespaces/
│   │   ├── main-api-ns.yaml
│   │   └── auxiliary-service-ns.yaml
│   └── services/
│       ├── main-api-service.yaml
│       └── auxiliary-service-service.yaml
├── main-api/
│   └── app.py                           # Flask app for Main API
├── auxiliary-service/
│   ├── app.py                           # Flask app for Auxiliary Service
│   └── .env.sample                      # Example env file for AWS creds
├── terraform/                           # Terraform root & modules
│   ├── backend.tf                       # Remote state & locking
│   ├── provider.tf                      # AWS provider config
│   ├── variables.tf                     # root variables (`project_name`, etc.)
│   ├── main.tf                          # invokes modules: s3, ssm, ecr, iam
│   ├── outputs.tf                       # bucket name, parameter names, IAM creds
│   ├── bootstrap/                       # state‐bootstrap (S3 + DynamoDB)
│   └── modules/
│       ├── s3/
│       ├── ssm/
│       ├── ecr/
│       └── iam/
└── .github/workflows/
    └── ci-cd-pipeline.yml              # GitHub Actions workflow
```

---

## Architecture Overview

```text
┌────────────────────┐     ┌──────────────────────────┐
│    Main API        │←──▶│ Auxiliary Service        │
│  (Flask on K8s)    │     │ (Flask on K8s)           │
└────────────────────┘     └──────────────────────────┘
           ↑                          ↓
   GitHub Actions builds & pushes   AWS S3 + SSM
        Docker images                via IAM creds
           ↓
     Amazon ECR (tagged by SHA)
           ↓
       Argo CD watches `k8s/`
           ↓
   Kubernetes reconciliation loop
```

- **Namespaces**: `argocd`, `main-api`, `auxiliary-service`.  
- **Terraform**: bootstraps state, S3 bucket, SSM parameters, ECR repos, IAM/OIDC for GitHub.  
- **GitHub Actions**: builds, tags (`${{ github.sha }}`), pushes images; patches k8s manifests; commits back.  
- **Argo CD**: continuous GitOps sync of `k8s/` into the cluster.

---

## Terraform (IaC)

### Root variables (`terraform/variables.tf`)

| Name           | Default                   | Description                                  |
|----------------|---------------------------|----------------------------------------------|
| `aws_region`   | `eu-west-1`               | AWS region for all resources                 |
| `project_name` | `kantox-challenge`        | Used as prefix for resource names            |
| `environment`  | `dev`                     | Supports multi-env (dev/prod)                |
| `github_repo`  | `Rania193/tech-challenge` | Used in IAM OIDC trust for GitHub Actions    |

### Modules (in `terraform/main.tf`)

| Module      | Purpose                                          | Key Outputs                              |
|-------------|--------------------------------------------------|------------------------------------------|
| **bootstrap** | Remote state S3 bucket & DynamoDB lock         | (internal)                               |
| **s3**        | Application object storage bucket              | `challenge_bucket_name`                  |
| **ssm**       | AWS Parameter Store entries                    | `parameter_names`                        |
| **ecr**       | Two ECR repos (`main-api`, `auxiliary-service`)| `main_api_repository_arn`, `auxiliary_service_repository_arn` |
| **iam**       | OIDC provider, GitHub Actions role, IAM user   | `access_key_id`, `secret_access_key`     |

### Usage

```bash
cd terraform/bootstrap
terraform init
terraform plan
terraform apply
cd ..
terraform init
terraform plan   # inspect changes
terraform apply  # provision AWS infra
```

---

## CI/CD – GitHub Actions

File: `.github/workflows/ci-cd-pipeline.yml`

1. **Trigger**: push to `main`.  
2. **Permissions**:  
   - `id-token: write` (GitHub OIDC)  
   - `contents: write` (to push manifest updates)  
3. **Steps**:
   1. **Checkout code**  
   2. **Assume AWS role** via OIDC (`aws-actions/configure-aws-credentials@v2`)  
   3. **Login to ECR** (`aws-actions/amazon-ecr-login@v1`)  
   4. **Build & push images** (tagged `${{ github.sha }}`)  
   5. **Patch manifests** (`sed -i` updates images + configmap versions)  
   6. **Commit & push** updated `k8s/` manifests  

> Terraform validation steps are predefined but commented out for now.

---

## Local Deployment Guide

### Prerequisites

- Docker Desktop or Podman  
- `kubectl` ≥ 1.25  
- Minikube v1.36.0
- Terraform ≥ 1.7  
- (Optional) Helm  

### 1. Start your cluster

```bash
minikube start --kubernetes-version=v1.29.0
```

### 2. Install Argo CD

```bash
cd argocd/
kubectl apply -f argocd-ns.yaml
kubectl apply -n argocd   -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 3. Expose & login

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Visit https://localhost:8080
# Username: admin
# Get password:
kubectl -n argocd get secret argocd-initial-admin-secret   -o jsonpath='{.data.password}' | base64 -d
```

### 4. ECR pull secrets

```bash
TOKEN=$(aws ecr get-login-password --region eu-west-1)
for ns in main-api auxiliary-service; do
  kubectl create namespace $ns --dry-run=client -o yaml | kubectl apply -f -
  kubectl create secret docker-registry regcred     --docker-server="${AWS_ACCOUNT_ID}.dkr.ecr.eu-west-1.amazonaws.com"     --docker-username=AWS     --docker-password="$TOKEN"     --namespace="$ns" --dry-run=client -o yaml | kubectl apply -f -
done
```

Also create an `aws-credentials` secret in each namespace with your AWS keys.

### 5. Create the Argo CD Application

```bash
kubectl apply -f argocd/kantox-challenge-app.yaml
```

Argo CD will now watch `k8s/` and auto-reconcile your services.

---

## Argo CD Usage

- **Sync**:
  ```bash
  argocd app sync kantox-challenge
  ```
- **Diff**:
  ```bash
  argocd app diff kantox-challenge
  ```
- **UI**: Applications → `kantox-challenge` → Health & History.

---

## Verifying a Successful Release

```bash
kubectl get pods -n main-api
kubectl get pods -n auxiliary-service
# Should be READY 1/1

# Port-forward Main API:
kubectl port-forward svc/main-api -n main-api 8000:8000
curl -s http://localhost:8000/s3-buckets | jq
```

You’ll see bucket names and matching version hashes.

---

## API Testing Guide

### List S3 buckets

```bash
curl -s http://<MAIN_API_HOST>:8000/s3-buckets | jq
```

**Sample response:**

```json
{
  "buckets": ["kantox-challenge-dev-bucket", ...],
  "main_api_version": "abcd1234...",
  "auxiliary_service_version": "abcd1234..."
}
```

### List all parameters

```bash
curl -s http://<MAIN_API_HOST>:8000/parameters | jq
```

### Get a single parameter

```bash
curl -s http://<MAIN_API_HOST>:8000/parameter/<param_name> | jq
```
