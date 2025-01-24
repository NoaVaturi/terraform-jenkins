#!/bin/bash

# Install Jenkins
sudo dnf update -y
sudo dnf install wget -y
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key     
sudo yum upgrade
sudo dnf install java-17-amazon-corretto -y
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Install Git
sudo dnf install git -y

# Install AWS CLI
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo dnf install -y unzip
unzip awscliv2.zip
sudo ./aws/install 

# Install Docker
sudo dnf install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker jenkins

# Install kubectl
sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl
sudo chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# Install Python 3
sudo dnf install -y python3

sudo systemctl restart jenkins


# Ensure Jenkins home directory exists and is owned by jenkins
sudo mkdir -p /var/lib/jenkins/.kube
sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube

# Update kubeconfig for staging and production clusters for Jenkins user
aws eks --region us-east-2 update-kubeconfig --name staging-cluster --alias staging-context --kubeconfig /var/lib/jenkins/.kube/config
aws eks --region us-east-2 update-kubeconfig --name production-cluster --alias production-context --kubeconfig /var/lib/jenkins/.kube/config

# Set correct permissions for kubeconfig
sudo chmod 600 /var/lib/jenkins/.kube/config
sudo chown jenkins:jenkins /var/lib/jenkins/.kube/config


# Install k6
sudo dnf install https://dl.k6.io/rpm/repo.rpm -y
sudo dnf install k6 -y