Automated CI/CD Pipeline with Jenkins, GitHub and AWS-

This project demonstrates the automation of the continuous integration and continuous deployment (CI/CD) pipeline using Jenkins, GitHub, and AWS. Code changes pushed to the GitHub repository automatically trigger Jenkins to build, test, and deploy the application. The pipeline includes:
* Building Docker images
* Pushing the images to Docker Hub
* Deploying the images to EKS clusters for both staging and production environments

The staging environment is used to run acceptance tests on the application using K6 before deploying the changes to production, ensuring the application meets performance and reliability requirements.

Terraform is used to provision the necessary AWS infrastructure, including the Jenkins EC2 instance and the EKS clusters.
