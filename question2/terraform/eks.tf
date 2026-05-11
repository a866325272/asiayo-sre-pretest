locals {
  subnet_ids = concat([var.pretest-public-ap-southeast-1a_subnet_id,
    var.pretest-public-ap-southeast-1b_subnet_id,
    var.pretest-public-ap-southeast-1c_subnet_id,
    var.pretest-private-ap-southeast-1a_subnet_id,
    var.pretest-private-ap-southeast-1b_subnet_id,
  var.pretest-private-ap-southeast-1c_subnet_id])
}

resource "aws_eks_cluster" "pretest-eks" {

  name     = var.cluster_name
  role_arn = var.cluster_iam_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = local.subnet_ids
  }
}

resource "aws_eks_fargate_profile" "default_fargate" {
  cluster_name           = var.cluster_name
  fargate_profile_name   = "default_fargate"
  pod_execution_role_arn = aws_iam_role.default_fargate.arn
  subnet_ids             = [var.pretest-private-ap-southeast-1a_subnet_id, var.pretest-private-ap-southeast-1b_subnet_id, var.pretest-private-ap-southeast-1c_subnet_id]
  depends_on = [
    aws_eks_cluster.pretest-eks
  ]
}

resource "aws_iam_role" "default_fargate" {
  name = "eks-fargate-profile-default-fargate-${var.cluster_name}"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "default_fargate-AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.default_fargate.name
}

