# udacity-cde-capstone-infra
This project sets up the infrastructure for the [Udacity Cloud DevOps Engineer Capstone Project](https://www.udacity.com/course/cloud-dev-ops-nanodegree--nd9991).
The whole infrastructure setup is configured in a [Jenkinsfile](build/Jenkinsfile) which contains the relevant build steps to get everything up an running.

## Preconditions
The following software needs to be installed:
* Jenkins
* The following Jenkins plugins:
  * Kubernetes Plugin
  * Pipeline AWS Steps
* AWS CLI
* [jq](https://stedolan.github.io/jq/)
* [ytt](https://get-ytt.io/)

## How-to run
### Configure Jenkins
1. **Fork GitHub Repo**  
   Fork the [Infra GitHub Repo](https://github.com/mithie/udacity-cde-capstone-infra.git).
2. **Create AWS Credentials**  
   In Jenkins first create new global AWS Credentials. For `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`put in the credentials of a user with admin permissions within your AWS account.
3. **Create multibranch pipeline**  
   Create a new multibranch pipeline in the Jenkins UI and connect it to your newly created repo. Note that you have to configure credentials in Jenkins that allow access to your repo.
   In the **Build Configuration** section of your pipeline configuration make sure to set **Script Path** to `build/Jenkinsfile`

### Run Build Job
Once the pipeline has been set up and configured properly go to your newly created pipeline and click on the `build now` link. This will setup an EKS cluster with proper permissions
to access it with `kubectl` from the command line.

## Pipeline Stages

| Stage | Description |
|:---- |:----------- |
| `Check if EKS Cluster exists` | Check whether EKS cluster has already been built. If `yes` then the following steps will be ignored. |
| `Prepare AWS IAM` |  IAM Role, User and Permission to build and access the EKS cluster. This is done via Cloud Formation. see [IAM CFN](./config/iam/prepare-iam-cfn.yaml) for details |
| `Install tooling (eksctl, kubectl, ytt)` | Install all the necessary tooling for creating an EKS cluster. |
| `Create EKS Cluster` | Create the EKS cluster with `eksctl`. see [eks config template](./config/eks/cluster-template.yaml) and [eks config values](./config/eks/values.yaml) for further details.  |
| `Update EKS Config` | Updates the kubeconfig file and adds the profile created in the second stage. |
| `Installing Ingress Controller` | Install NGINX ingress controller for enabling external cluster access. |

## Post Actions
| Action | Description |
|:---- |:----------- |
| `failure` | This action rolls back the whole EKS setup when anything went wrong in the previous stages.  |
| `success` | Prints a success message when the EKS cluster was bootstrapped successfully. |
