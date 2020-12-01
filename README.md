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

## What's going to be build
The Jenkins build job is separated in three stages and will create the following artifacts:
1. **Stage one: prepare aws iam**  
   IAM Role, User and Permission to build and access the EKS cluster. This is done via Cloud Formation. The script creates
   an IAM User and Role. The Role will be used as Admin role for accessing the cluster and will have the user added in its trust relationship. The user in turn
   will be granted permissions to assume this role. Further it will update the aws config and aws credentials files for allowing access via kubectl.
2. **Stage two: install udacity eks cluster**  
   In this step the EKS cluster is build with eksctl. 
3. **Stage three: update eks config**  
   The last step updates the kubeconfig file and adds the profile created in stage one.