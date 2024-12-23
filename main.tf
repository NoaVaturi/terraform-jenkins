terraform {
  backend "s3" {
    bucket  = "state-bucket-terraform-jenkins"
    region  = "us-east-2"
    key     = "terraform/terraform.tfstate"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-2"  
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "subnet_a" {
  filter {
    name   = "availabilityZone"
    values = ["us-east-2a"]
  }
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnet" "subnet_b" {
  filter {
    name   = "availabilityZone"
    values = ["us-east-2b"]
  }
  vpc_id = data.aws_vpc.default.id
}


provider "kubernetes" {
  alias                  = "staging"
  host                   = aws_eks_cluster.eks_cluster_staging.endpoint
  cluster_ca_certificate  = base64decode(aws_eks_cluster.eks_cluster_staging.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = aws_eks_cluster.eks_cluster_staging.name
}


provider "kubernetes" {
  alias                  = "production"
  host                   = aws_eks_cluster.eks_cluster_production.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster_production.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_cluster_production.token
}

data "aws_eks_cluster_auth" "eks_cluster_production" {
  name = aws_eks_cluster.eks_cluster_production.name
}


resource "aws_eks_cluster" "eks_cluster_staging" {
  name     = "staging-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = [
      data.aws_subnet.subnet_a.id,
      data.aws_subnet.subnet_b.id
    ]
  }
}


resource "aws_eks_cluster" "eks_cluster_production" {
  name     = "production-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = [
      data.aws_subnet.subnet_a.id,
      data.aws_subnet.subnet_b.id
    ]
  }
}


resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}


resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow inbound traffic for Jenkins"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


data "aws_ami" "latest-amazon-linux-2023-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.6.20241209.0-kernel-6.1-x86_64"]  
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name = "jenkins-instance-profile"
  role = "Jenkins-Role"  
}

resource "aws_eip" "jenkins_eip" {
  instance = aws_instance.jenkins_instance.id
  domain = "vpc"
}

resource "aws_instance" "jenkins_instance" {
  ami                 = data.aws_ami.latest-amazon-linux-2023-image.id
  instance_type       = "t3.small"
  key_name            = "jenkins-server-key"
  subnet_id           = data.aws_subnet.subnet_a.id
  security_groups     = [aws_security_group.jenkins_sg.id]
  iam_instance_profile = aws_iam_instance_profile.jenkins_instance_profile.name 
  user_data           = "${file("jenkins_setup.sh")}"
  
  lifecycle {
    prevent_destroy = true
  }
 
  tags = {
    Name = "Jenkins-Instance"
  }
}


resource "aws_eks_node_group" "eks_nodes_staging" {
  cluster_name    = aws_eks_cluster.eks_cluster_staging.name
  node_group_name = "eks-node-group-staging"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [
    data.aws_subnet.subnet_a.id,
    data.aws_subnet.subnet_b.id
  ]
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
  instance_types = ["t2.small"]
}

resource "aws_eks_node_group" "eks_nodes_production" {
  cluster_name    = aws_eks_cluster.eks_cluster_production.name
  node_group_name = "eks-node-group-production"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [
    data.aws_subnet.subnet_a.id,
    data.aws_subnet.subnet_b.id
  ]
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
  instance_types = ["t2.small"]
}


resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_cni_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_registry_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}


output "eks_cluster_staging_name" {
  value = aws_eks_cluster.eks_cluster_staging.name
}

resource "kubernetes_config_map" "aws_auth_staging" {
  depends_on = [aws_eks_cluster.eks_cluster_staging]

  provider = kubernetes.staging

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = jsonencode([
      {
        rolearn  = aws_iam_role.eks_node_role.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      },
      {
        rolearn  = "arn:aws:iam::098211963825:role/Jenkins-Role"
        username = "jenkins"
        groups   = ["system:masters"] 
      }
    ])
  }
}

resource "kubernetes_config_map" "aws_auth_production" {
  depends_on = [aws_eks_cluster.eks_cluster_production]

  provider = kubernetes.production  

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = jsonencode([
      {
        rolearn  = aws_iam_role.eks_node_role.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      },
      {
        rolearn  = "arn:aws:iam::098211963825:role/Jenkins-Role"
        username = "jenkins"
        groups   = ["system:masters"]
      }
    ])
  }
}

output "eks_cluster_production_name" {
  value = aws_eks_cluster.eks_cluster_production.name
}

output "jenkins_instance_public_ip" {
  value = aws_eip.jenkins_eip.public_ip
}

