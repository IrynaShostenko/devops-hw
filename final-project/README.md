# Final DevOps Project - AWS, Terraform, EKS, Jenkins, Argo CD, RDS, Prometheus and Grafana

This project implements a full DevOps infrastructure on AWS using Terraform.

It includes:

- VPC
- EKS
- ECR
- RDS / Aurora module
- Jenkins
- Argo CD
- Prometheus
- Grafana
- Django application
- Helm chart
- HPA autoscaling
- CI/CD pipeline

## Project goal

The goal of this final project is to build a complete AWS-based DevOps environment with infrastructure automation, CI/CD, GitOps deployment, database provisioning and monitoring.

The infrastructure is created with Terraform and reusable modules.

## Architecture

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
    Image is pushed to Amazon ECR
              |
              v
    Jenkins updates image tag in Helm values.yaml
              |
              v
    Jenkins pushes updated values.yaml to GitHub
              |
              v
    Argo CD detects Git changes
              |
              v
    Argo CD syncs Django application to EKS
              |
              v
    Prometheus collects metrics
              |
              v
    Grafana displays dashboards

## Project structure

    final-project/
    ├── main.tf
    ├── backend.tf
    ├── providers.tf
    ├── variables.tf
    ├── outputs.tf
    ├── README.md
    ├── Jenkinsfile
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
    │   ├── rds/
    │   │   ├── shared.tf
    │   │   ├── rds.tf
    │   │   ├── aurora.tf
    │   │   ├── variables.tf
    │   │   └── outputs.tf
    │   ├── jenkins/
    │   │   ├── jenkins.tf
    │   │   ├── variables.tf
    │   │   ├── providers.tf
    │   │   ├── values.yaml
    │   │   └── outputs.tf
    │   ├── argo_cd/
    │   │   ├── argo_cd.tf
    │   │   ├── variables.tf
    │   │   ├── providers.tf
    │   │   ├── values.yaml
    │   │   ├── outputs.tf
    │   │   └── charts/
    │   │       └── argocd-apps/
    │   │           ├── Chart.yaml
    │   │           ├── values.yaml
    │   │           └── templates/
    │   │               ├── application.yaml
    │   │               └── repository.yaml
    │   └── monitoring/
    │       ├── monitoring.tf
    │       ├── variables.tf
    │       ├── values.yaml
    │       └── outputs.tf
    ├── charts/
    │   └── django-app/
    │       ├── Chart.yaml
    │       ├── values.yaml
    │       └── templates/
    │           ├── deployment.yaml
    │           ├── service.yaml
    │           ├── configmap.yaml
    │           ├── secret.yaml
    │           ├── postgres.yaml
    │           └── hpa.yaml
    └── Django/
        ├── Dockerfile
        ├── Jenkinsfile
        ├── docker-compose.yaml
        ├── manage.py
        ├── requirements.txt
        └── devops_project/

## Infrastructure components

Terraform creates and manages:

- S3 bucket for Terraform remote state
- DynamoDB table for Terraform state locking
- VPC with public and private subnets
- Internet Gateway
- NAT Gateway
- ECR repository
- EKS cluster
- EKS managed node group
- EBS CSI driver
- RDS instance or Aurora cluster
- Jenkins through Helm
- Argo CD through Helm
- Argo CD Application for Django Helm chart
- Prometheus and Grafana through Helm
- Kubernetes resources for Django application

## AWS region

The project uses:

    us-west-2

## Terraform backend

The project contains `backend.tf` for S3 backend and DynamoDB state locking.

Important note:

At the first launch, the S3 bucket and DynamoDB table must exist before the S3 backend can be used.

For local validation without remote backend:

    terraform init -backend=false
    terraform validate

For real infrastructure deployment with backend:

    terraform init
    terraform plan
    terraform apply

After `terraform destroy`, the S3 bucket and DynamoDB table are also deleted. For the next launch, the backend bootstrap process must be repeated.

## Sensitive variables

Sensitive values are not stored in Git.

Required sensitive variables:

    TF_VAR_jenkins_admin_password
    TF_VAR_rds_master_password
    TF_VAR_grafana_admin_password

Example:

    export TF_VAR_jenkins_admin_password="your-jenkins-password"
    export TF_VAR_rds_master_password="your-database-password"
    export TF_VAR_grafana_admin_password="your-grafana-password"

After Terraform commands, unset them:

    unset TF_VAR_jenkins_admin_password
    unset TF_VAR_rds_master_password
    unset TF_VAR_grafana_admin_password

## Terraform commands

Initialize Terraform:

    terraform init

Format Terraform files:

    terraform fmt -recursive

Validate Terraform configuration:

    terraform validate

Check execution plan:

    terraform plan

Apply infrastructure:

    terraform apply

Destroy infrastructure:

    terraform destroy

## Local validation without backend

For validation only:

    mv backend.tf backend.tf.disabled
    rm -rf .terraform

    terraform init -backend=false
    terraform validate

    mv backend.tf.disabled backend.tf

Expected result:

    Success! The configuration is valid.

## EKS access

After Terraform creates the EKS cluster, configure kubectl:

    aws eks update-kubeconfig --region us-west-2 --name final-project-eks

Check nodes:

    kubectl get nodes

Expected result:

    STATUS   Ready

## Jenkins

Jenkins is installed by Terraform using Helm.

Jenkins resources are created in namespace:

    jenkins

Check Jenkins:

    kubectl get all -n jenkins

Access Jenkins locally:

    kubectl port-forward svc/jenkins 8080:8080 -n jenkins

Open in browser:

    http://localhost:8080

Jenkins admin credentials:

    Username: admin
    Password: provided through TF_VAR_jenkins_admin_password

## Jenkins credentials

The Jenkins pipeline expects these credentials:

    aws-access-key-id
    aws-secret-access-key
    github-token

Credential types:

    aws-access-key-id       Secret text
    aws-secret-access-key   Secret text
    github-token            Username with password

The GitHub token must have permission to read and write repository contents.

## Jenkins pipeline

The pipeline is defined in:

    final-project/Jenkinsfile

Pipeline stages:

1. Checkout source code.
2. Generate Docker image tag.
3. Configure ECR authentication.
4. Build Docker image using Kaniko.
5. Push Docker image to ECR.
6. Update image tag in Helm values.yaml.
7. Commit and push updated Helm values to Git.
8. Clean Jenkins workspace.

Kaniko is used because it can build images inside Kubernetes without Docker daemon.

## ECR

ECR repository:

    final-project-ecr

The Jenkins pipeline pushes Docker images to Amazon ECR.

Check ECR images:

    aws ecr list-images \
      --repository-name final-project-ecr \
      --region us-west-2 \
      --output table

## Argo CD

Argo CD is installed by Terraform using Helm.

Argo CD namespace:

    argocd

Check Argo CD resources:

    kubectl get all -n argocd

Access Argo CD locally:

    kubectl port-forward svc/argocd-server 8081:443 -n argocd

Open in browser:

    https://localhost:8081

Check Argo CD Application:

    kubectl get applications -n argocd

Expected result:

    django-app   Synced   Healthy

The Argo CD Application watches:

    Repository: https://github.com/IrynaShostenko/devops-hw.git
    Branch: final-project
    Path: final-project/charts/django-app

Argo CD uses automated sync with prune and selfHeal enabled.

## Django application

The Django application is located in:

    final-project/Django

It contains:

- Dockerfile
- Jenkinsfile copy
- docker-compose.yaml
- Django project files
- requirements.txt

The Kubernetes Helm chart is located in:

    final-project/charts/django-app

The chart includes:

- Deployment
- Service
- ConfigMap
- Secret
- PostgreSQL Deployment and Service
- HPA
- readiness and liveness probes

Check Django resources:

    kubectl get pods
    kubectl get svc
    kubectl get hpa

Expected result:

    django-app pods are Running
    django-app-service has LoadBalancer hostname
    HPA shows CPU metrics

Get Django LoadBalancer hostname:

    ELB=$(kubectl get svc django-app-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    echo $ELB

Check Django admin endpoint:

    curl -I http://$ELB/admin/

Expected result:

    HTTP/1.1 302 Found
    Location: /admin/login/?next=/admin/

This response is expected because Django redirects unauthenticated users from `/admin/` to the admin login page.

## RDS module

The RDS module is located in:

    final-project/modules/rds

It supports two modes:

    use_aurora = false

Creates a standard RDS instance.

    use_aurora = true

Creates an Aurora cluster.

The module creates:

- DB Subnet Group
- Security Group
- Parameter Group
- Standard RDS instance or Aurora cluster
- Outputs for endpoint, port, database name and security group

The root variable controlling database type is:

    rds_use_aurora

Standard RDS example:

    rds_use_aurora = false
    rds_engine = "postgres"
    rds_engine_version = "15.5"
    rds_instance_class = "db.t3.micro"

Aurora example:

    rds_use_aurora = true
    rds_engine = "postgres"
    rds_engine_version = "15.5"
    rds_instance_class = "db.t3.medium"

## Monitoring

Monitoring is installed by Terraform using Helm chart:

    kube-prometheus-stack

The monitoring module is located in:

    final-project/modules/monitoring

It creates:

- monitoring namespace
- Prometheus
- Grafana
- kube-state-metrics
- node-exporter
- Prometheus Operator
- default monitoring rules and dashboards

Monitoring namespace:

    monitoring

Check monitoring resources:

    kubectl get all -n monitoring

Access Grafana locally:

    kubectl port-forward svc/grafana 3000:80 -n monitoring

Open in browser:

    http://localhost:3000

Grafana credentials:

    Username: admin
    Password: provided through TF_VAR_grafana_admin_password

Check metrics:

    kubectl top nodes
    kubectl top pods
    kubectl get hpa

## Autoscaling

The Django Helm chart includes HPA.

HPA scales Django pods from 2 to 6 replicas when CPU usage is higher than 70%.

Check HPA:

    kubectl get hpa

Expected result:

    django-app-hpa   Deployment/django-app   cpu: <value>/70%   2   6   2

## Verification commands

After deployment, run:

    kubectl get all -n jenkins
    kubectl get all -n argocd
    kubectl get all -n monitoring
    kubectl get applications -n argocd
    kubectl get pods
    kubectl get svc
    kubectl get hpa
    kubectl top nodes
    kubectl top pods

Expected results:

- Jenkins resources are running.
- Argo CD resources are running.
- Monitoring resources are running.
- Argo CD application is Synced and Healthy.
- Django pods are 1/1 Running.
- Django service has LoadBalancer hostname.
- HPA shows CPU metrics.
- Grafana is available through port-forward.

## Screenshots for submission

Recommended screenshots:

1. Terraform apply result.
2. Jenkins pipeline success.
3. ECR repository with pushed image tag.
4. Argo CD application Synced and Healthy.
5. Kubernetes pods, services and HPA.
6. Monitoring namespace resources.
7. Grafana dashboard.
8. Django endpoint response.

## Cleanup

Cloud resources may generate costs.

After verification, destroy all resources:

    export TF_VAR_jenkins_admin_password="your-jenkins-password"
    export TF_VAR_rds_master_password="your-database-password"
    export TF_VAR_grafana_admin_password="your-grafana-password"

    terraform destroy

    unset TF_VAR_jenkins_admin_password
    unset TF_VAR_rds_master_password
    unset TF_VAR_grafana_admin_password

After destroy, check AWS resources:

    aws eks list-clusters --region us-west-2
    aws ecr describe-repositories --region us-west-2
    aws dynamodb list-tables --region us-west-2
    aws s3 ls

Make sure that the following resources are removed:

- final-project-eks
- final-project-ecr
- final-project VPC resources
- NAT Gateway
- LoadBalancers
- RDS / Aurora resources
- terraform-locks
- Terraform state S3 bucket

## Security notes

Sensitive values are not committed to Git.

Jenkins credentials are stored in Jenkins credentials storage.

Temporary AWS access keys used for Jenkins should be deactivated or deleted after project verification.

Database is not publicly accessible by default.

Private subnets are recommended for database resources.

## Submission

Submit:

1. GitHub repository link with branch:

       final-project

2. ZIP archive:

       devops-hw-final-project_Shosstenko.zip

3. Ready-to-run Terraform code.

