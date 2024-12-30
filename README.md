Automated CI/CD Pipeline with Jenkins, GitHub and AWS-

This project demonstrates the automation of the continuous integration and continuous deployment pipeline using Jenkins, GitHub and AWS.
Code changes pushed to GitHub repository trigger Jenkins to automatically build, test, and deploy the application. 
The pipeline involves building Docker images, pushing them to Docker Hub, and deploying the images to EKS clusters for staging and production environments. 
Terraform is used to provision the necessary AWS infrastructure, including the Jenkins EC2 instance and the EKS clusters.
