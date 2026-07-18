# Lesson 7 - Kubernetes, EKS, ECR and Helm

This homework creates a Kubernetes cluster on AWS using Terraform, pushes a Django Docker image to Amazon ECR, and deploys the application to EKS using Helm.

## What is included

The project includes:

- AWS VPC with public and private subnets
- S3 bucket for Terraform remote state
- DynamoDB table for Terraform state locking
- ECR repository for the Django Docker image
- EKS cluster
- EKS managed node group
- Helm chart for Django application
- Kubernetes Deployment
- Kubernetes Service of type LoadBalancer
- Kubernetes Horizontal Pod Autoscaler
- Kubernetes ConfigMap for environment variables

## Project structure

    lesson-7/
    ├── main.tf
    ├── backend.tf
    ├── variables.tf
    ├── outputs.tf
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
    │   └── eks/
    │       ├── eks.tf
    │       ├── variables.tf
    │       └── outputs.tf
    └── charts/
        └── django-app/
            ├── Chart.yaml
            ├── values.yaml
            └── templates/
                ├── deployment.yaml
                ├── service.yaml
                ├── configmap.yaml
                └── hpa.yaml

## Terraform infrastructure

Terraform creates the following AWS resources:

### S3 backend

The `s3-backend` module creates:

- S3 bucket for Terraform state
- DynamoDB table for state locking
- S3 bucket versioning
- S3 server-side encryption
- S3 public access block
- S3 lifecycle configuration

The Terraform state is stored remotely in S3.

### VPC

The `vpc` module creates:

- VPC
- 3 public subnets
- 3 private subnets
- Internet Gateway
- NAT Gateway
- Route tables
- Route table associations

The subnets include Kubernetes tags required for EKS LoadBalancer support.

### ECR

The `ecr` module creates:

- ECR repository
- ECR repository policy
- ECR lifecycle policy
- Image scanning on push
- AES256 encryption

The repository is used to store the Django Docker image.

### EKS

The `eks` module creates:

- EKS cluster
- EKS managed node group
- IAM role for the EKS cluster
- IAM role for worker nodes
- Required IAM policy attachments

Worker nodes are created in private subnets.

## AWS region

The project uses:

    us-west-2

## Terraform commands

Initialize Terraform:

    terraform init

Format Terraform files:

    terraform fmt -recursive

Validate configuration:

    terraform validate

Show infrastructure plan:

    terraform plan

Apply infrastructure:

    terraform apply

Destroy infrastructure:

    terraform destroy

## Configure kubectl

After the EKS cluster is created, configure kubectl:

    aws eks update-kubeconfig --region us-west-2 --name lesson-7-eks

Check worker nodes:

    kubectl get nodes

Expected result:

    STATUS   Ready

## Docker image and ECR

The Django application Docker image is built from the Docker project folder:

    ../docker

Login to ECR:

    aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 559292737982.dkr.ecr.us-west-2.amazonaws.com

Build Docker image:

    cd ../docker
    docker build --network=host -t lesson-7-django ./django

Tag Docker image:

    docker tag lesson-7-django:latest 559292737982.dkr.ecr.us-west-2.amazonaws.com/lesson-7-ecr:latest

Push Docker image to ECR:

    docker push 559292737982.dkr.ecr.us-west-2.amazonaws.com/lesson-7-ecr:latest

Check images in ECR:

    aws ecr list-images --repository-name lesson-7-ecr --region us-west-2

## Helm chart

The Helm chart is located in:

    charts/django-app

The chart includes:

- Deployment
- Service
- ConfigMap
- Horizontal Pod Autoscaler
- values.yaml

## ConfigMap

Environment variables from the Docker Compose homework are moved to Kubernetes ConfigMap.

ConfigMap values are defined in:

    charts/django-app/values.yaml

The Deployment uses ConfigMap through:

    envFrom

For production, sensitive values should be stored in Kubernetes Secrets. For this homework, ConfigMap is used according to the task requirements.

## Deploy application with Helm

Install the Helm chart:

    helm install django-app charts/django-app

Check Helm release:

    helm list

Check Kubernetes resources:

    kubectl get pods
    kubectl get svc
    kubectl get hpa
    kubectl get configmap

## Metrics Server

HPA requires Kubernetes metrics. Metrics Server can be installed with:

    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

Check HPA:

    kubectl get hpa

Expected result:

    TARGETS       MINPODS   MAXPODS   REPLICAS
    cpu: .../70%  2         6         2

## External access

The Django application is exposed through a LoadBalancer service.

Get the LoadBalancer hostname:

    ELB=$(kubectl get svc django-app-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    echo $ELB

Check application response:

    curl -I http://$ELB

Expected result:

    HTTP/1.1 200 OK

## Verification results

The infrastructure and application were verified with:

    kubectl get nodes
    kubectl get pods
    kubectl get svc
    kubectl get hpa
    kubectl get configmap
    helm list
    terraform plan

Successful result:

- EKS nodes are Ready
- Django pods are Running
- LoadBalancer service has an external hostname
- HPA is created and receives CPU metrics
- ConfigMap is created
- Helm release is deployed
- Terraform plan shows no changes

## Cleanup

AWS EKS, NAT Gateway, EC2 nodes and LoadBalancer may generate costs.

To remove the Helm application:

    helm uninstall django-app

To remove AWS infrastructure:

    terraform destroy
