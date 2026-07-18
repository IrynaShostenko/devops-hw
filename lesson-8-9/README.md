# Lesson 8-9 - Jenkins, Terraform, Helm and Argo CD CI/CD

This project implements a CI/CD workflow for a Django application using Jenkins, Terraform, Helm, ECR and Argo CD.

The goal is to automate the process of:

1. Building a Docker image for the Django application.
2. Pushing the image to Amazon ECR.
3. Updating the image tag in Helm values.yaml.
4. Synchronizing the application in Kubernetes through Argo CD.

## CI/CD workflow

The workflow is:

    Developer pushes code to GitHub
              |
              v
    Jenkins pipeline starts
              |
              v
    Kaniko builds Docker image
              |
              v
    Docker image is pushed to Amazon ECR
              |
              v
    Jenkins updates image.tag in Helm values.yaml
              |
              v
    Jenkins pushes updated values.yaml to Git
              |
              v
    Argo CD detects Git changes
              |
              v
    Argo CD syncs Django application in EKS

## Project structure

    lesson-8-9/
    ├── main.tf
    ├── backend.tf
    ├── providers.tf
    ├── variables.tf
    ├── outputs.tf
    ├── Jenkinsfile
    ├── README.md
    ├── modules/
    │   ├── s3-backend/
    │   │   ├── s3.tf
    │   │   ├── dynamodb.tf
    │   │   ├── variables.tf
    │   │   └── outputs.tf
    │   ├── vpc/
    │   │   ├── vpc.tf
    │   │   ├── routes.tf
    │   │   ├── variables.tf
    │   │   └── outputs.tf
    │   ├── ecr/
    │   │   ├── ecr.tf
    │   │   ├── variables.tf
    │   │   └── outputs.tf
    │   ├── eks/
    │   │   ├── eks.tf
    │   │   ├── aws_ebs_csi_driver.tf
    │   │   ├── variables.tf
    │   │   └── outputs.tf
    │   ├── jenkins/
    │   │   ├── jenkins.tf
    │   │   ├── variables.tf
    │   │   ├── providers.tf
    │   │   ├── values.yaml
    │   │   └── outputs.tf
    │   └── argo_cd/
    │       ├── argo_cd.tf
    │       ├── variables.tf
    │       ├── providers.tf
    │       ├── values.yaml
    │       ├── outputs.tf
    │       └── charts/
    │           └── argocd-apps/
    │               ├── Chart.yaml
    │               ├── values.yaml
    │               └── templates/
    │                   ├── application.yaml
    │                   └── repository.yaml
    └── charts/
        └── django-app/
            ├── Chart.yaml
            ├── values.yaml
            └── templates/
                ├── deployment.yaml
                ├── service.yaml
                ├── configmap.yaml
                └── hpa.yaml

## Infrastructure

Terraform creates and manages the following resources:

- S3 bucket for Terraform remote state
- DynamoDB table for state locking
- VPC with public and private subnets
- Internet Gateway
- NAT Gateway
- ECR repository
- EKS cluster
- EKS managed node group
- EBS CSI driver
- Jenkins installation through Helm
- Argo CD installation through Helm
- Argo CD Application for the Django Helm chart

## AWS region

The project uses:

    us-west-2

## Terraform usage

Initialize Terraform:

    terraform init

Format Terraform files:

    terraform fmt -recursive

Validate configuration:

    terraform validate

Check execution plan:

    terraform plan

Apply infrastructure:

    terraform apply

Destroy infrastructure:

    terraform destroy

## Backend workflow

The project uses S3 and DynamoDB for Terraform remote state.

Important note:

At the first launch, the S3 bucket and DynamoDB table must exist before the S3 backend can be used.

A common workflow is:

1. Temporarily disable backend.tf.
2. Run Terraform with local state.
3. Create S3 and DynamoDB resources.
4. Enable backend.tf.
5. Run:

       terraform init -migrate-state

After infrastructure deletion with terraform destroy, the S3 bucket and DynamoDB table are also removed. For the next launch, the backend bootstrap process must be repeated.

## EKS access

After Terraform creates the EKS cluster, configure kubectl:

    aws eks update-kubeconfig --region us-west-2 --name lesson-8-9-eks

Check nodes:

    kubectl get nodes

Expected result:

    STATUS   Ready

## Jenkins

Jenkins is installed with Terraform using the official Jenkins Helm chart.

Jenkins module creates:

- Jenkins namespace
- Jenkins Helm release
- LoadBalancer service
- StorageClass for Jenkins persistent volume
- Persistent Jenkins storage

Jenkins admin credentials for this homework environment:

    Username: admin
    Password: admin123456

In production, credentials must not be stored in Terraform code.

## Jenkins credentials

The Jenkins pipeline expects the following credentials to be configured in Jenkins:

    aws-access-key-id
    aws-secret-access-key
    github-token

Credential types:

    aws-access-key-id       Secret text
    aws-secret-access-key   Secret text
    github-token            Username with password

For github-token:

    Username: GitHub username
    Password: GitHub personal access token

## Jenkins pipeline

The pipeline is defined in:

    Jenkinsfile

Pipeline stages:

1. Checkout source code.
2. Generate Docker image tag from Jenkins build number and Git commit.
3. Build Docker image using Kaniko.
4. Push Docker image to Amazon ECR.
5. Update image.tag in Helm values.yaml.
6. Commit and push updated Helm values to Git.

Kaniko is used because it can build container images inside Kubernetes without Docker daemon.

## ECR

ECR repository:

    lesson-8-9-ecr

The Jenkins pipeline pushes images to:

    559292737982.dkr.ecr.us-west-2.amazonaws.com/lesson-8-9-ecr

## Argo CD

Argo CD is installed with Terraform using Helm.

Argo CD module creates:

- Argo CD namespace
- Argo CD Helm release
- Argo CD repository secret
- Argo CD Application for Django app

The Argo CD Application watches:

    Repository: https://github.com/IrynaShostenko/devops-hw.git
    Branch: lesson-8-9
    Path: lesson-8-9/charts/django-app

The application uses automated sync:

- prune enabled
- selfHeal enabled

This means Argo CD automatically applies Git changes to the Kubernetes cluster.

## Django Helm chart

The Django Helm chart is located in:

    charts/django-app

It includes:

- Deployment
- Service
- ConfigMap
- HPA
- values.yaml

The Deployment uses ConfigMap through:

    envFrom

The Service type is:

    LoadBalancer

HPA scales pods from 2 to 6 replicas when CPU usage is higher than 70%.

## How to check Jenkins

Check Jenkins resources:

    kubectl get pods -n jenkins
    kubectl get svc -n jenkins

Get Jenkins URL:

    kubectl get svc -n jenkins

Open the LoadBalancer hostname in a browser.

## How to check Argo CD

Check Argo CD resources:

    kubectl get pods -n argocd
    kubectl get svc -n argocd

Get Argo CD URL:

    kubectl get svc -n argocd

Check Argo CD applications:

    kubectl get applications -n argocd

Expected application:

    django-app

## How to check Django application

Check Django resources:

    kubectl get pods
    kubectl get svc
    kubectl get hpa
    kubectl get configmap

Get LoadBalancer hostname:

    ELB=$(kubectl get svc django-app-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    echo $ELB

Check response:

    curl -I http://$ELB

Expected result:

    HTTP/1.1 200 OK

## Cleanup

Cloud resources may generate costs.

Before deleting infrastructure, remove Helm-managed application resources if needed.

Then destroy infrastructure:

    terraform destroy

After destroy, check AWS resources:

    aws eks list-clusters --region us-west-2
    aws ecr describe-repositories --region us-west-2
    aws dynamodb list-tables --region us-west-2
    aws s3 ls

Make sure that the following resources are removed:

- lesson-8-9-eks
- lesson-8-9-ecr
- lesson-8-9 VPC resources
- NAT Gateway
- LoadBalancers
- terraform-locks
- Terraform state S3 bucket
