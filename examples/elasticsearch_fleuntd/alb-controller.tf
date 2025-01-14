data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "lb_controller_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [data.aws_eks_cluster.this.identity[0].oidc[0].issuer]
    }
    condition {
      test     = "StringEquals"
      variable = "${data.aws_eks_cluster.this.identity[0].oidc[0].issuer}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_driver" {
  name = "${data.aws_eks_cluster.this.id}-load-balancer-controller-role-1"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/5B9EC64DE4C2D44972DEE753A8B17DD8"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "lb_controller" {
  name               = "${data.aws_eks_cluster.this.id}-load-balancer-controller-role"
  assume_role_policy = data.aws_iam_policy_document.lb_controller_assume_role.json
}

resource "aws_iam_policy_attachment" "lb_controller_policy" {
  name       = "lb-controller-policy-attachment"
  roles      = [aws_iam_role.lb_controller.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy"
}

resource "kubernetes_service_account" "lb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
  }

  automount_service_account_token = true
}

resource "helm_release" "lb_controller" {
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"

  set {
    name  = "clusterName"
    value = data.aws_eks_cluster.this.id
  }

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = "vpc-0e6c09980580ecbf6"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.lb_controller.metadata[0].name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }
}
