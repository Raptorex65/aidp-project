data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.70.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "aidp-phase7-vpc"
  })
}

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = merge(local.common_tags, {
    Name = "aidp-phase7-igw"
  })
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.70.1.0/24"
  availability_zone       = local.azs[0]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name                     = "aidp-phase7-public-a"
    "kubernetes.io/role/elb" = "1"
  })
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.70.2.0/24"
  availability_zone       = local.azs[1]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name                     = "aidp-phase7-public-b"
    "kubernetes.io/role/elb" = "1"
  })
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.70.11.0/24"
  availability_zone = local.azs[0]

  tags = merge(local.common_tags, {
    Name                              = "aidp-phase7-private-a"
    "kubernetes.io/role/internal-elb" = "1"
  })
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.70.12.0/24"
  availability_zone = local.azs[1]

  tags = merge(local.common_tags, {
    Name                              = "aidp-phase7-private-b"
    "kubernetes.io/role/internal-elb" = "1"
  })
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "aidp-phase7-nat-eip"
  })

  depends_on = [aws_internet_gateway.eks_igw]
}

resource "aws_nat_gateway" "eks_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_a.id

  tags = merge(local.common_tags, {
    Name = "aidp-phase7-nat"
  })

  depends_on = [aws_internet_gateway.eks_igw]
}
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = merge(local.common_tags, {
    Name = "aidp-phase7-public-rt"
  })
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_nat.id
  }

  tags = merge(local.common_tags, {
    Name = "aidp-phase7-private-rt"
  })
}

resource "aws_route_table_association" "public_a_assoc" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b_assoc" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_a_assoc" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_b_assoc" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "aidp-phase7-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_node_role" {
  name = "aidp-phase7-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_cluster" "eks" {
  name     = local.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id, aws_subnet.private_a.id, aws_subnet.private_b.id]

    endpoint_private_access = false
    endpoint_public_access  = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]

  tags = merge(local.common_tags, {
    Name = local.eks_cluster_name
  })
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = local.node_group_name
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  instance_types  = [var.node_instance_type]
  ami_type        = "AL2023_x86_64_STANDARD"
  capacity_type   = "ON_DEMAND"
  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_readonly_policy
  ]

  tags = merge(local.common_tags, {
    Name = "aidp-phase7-ng"
  })
}

############# OIDC provider ###
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint
  ]
}
###############################

#####EBS CSI IAM role##########
resource "aws_iam_role" "ebs_csi_driver_role" {
  name = "aidp-phase7-ebs-csi-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "aidp-phase7-ebs-csi-role"
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
  role       = aws_iam_role.ebs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = aws_eks_cluster.eks.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_driver_role.arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_driver_policy,
    aws_eks_node_group.main
  ]

  tags = merge(local.common_tags, {
    Name = "aidp-phase7-ebs-csi-addon"
  })
}
#######################