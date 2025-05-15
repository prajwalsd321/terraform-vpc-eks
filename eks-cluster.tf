module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.8.4"

  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  enable_irsa = true

  # Enable EBS CSI driver (needed for dynamic EBS volume provisioning)
  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  tags = {
    cluster = "demo"
  }

  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    instance_types         = ["t3.medium"]
    vpc_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  }

  eks_managed_node_groups = {
    on_demand = {
      min_size     = 1
      max_size     = 3
      desired_size = 1
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      labels = {
        lifecycle = "on-demand"
      }

      tags = {
        Name = "on-demand-ng"
      }
    }

    spot = {
      min_size     = 1
      max_size     = 3
      desired_size = 1
      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"

      labels = {
        lifecycle = "spot"
      }

      taints = [{
        key    = "spotInstance"
        value  = "true"
        effect = "NO_SCHEDULE"
      }]

      tags = {
        Name = "spot-ng"
      }
    }
  }
}
