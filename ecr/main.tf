provider "aws" {
  region = "ap-south-1"
}

#############################################
# ECR REPOSITORY
#############################################

resource "aws_ecr_repository" "main_repo" {

  name = "devops-demo-repository"

  image_tag_mutability = "MUTABLE"

  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {

    encryption_type = "AES256"

  }

  tags = {

    Name        = "devops-demo-repository"
    Environment = "dev"
    Owner       = "rameshwar"
    Terraform   = "true"

  }

}

#############################################
# LIFECYCLE POLICY
#############################################

resource "aws_ecr_lifecycle_policy" "repo_policy" {

  repository = aws_ecr_repository.main_repo.name

  policy = jsonencode({

    rules = [

      {

        rulePriority = 1
        description  = "Expire untagged images after 7 days"

        selection = {

          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7

        }

        action = {

          type = "expire"

        }

      },

      {

        rulePriority = 2
        description  = "Keep last 10 images"

        selection = {

          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10

        }

        action = {

          type = "expire"

        }

      }

    ]

  })

}

#############################################
# REPOSITORY POLICY
#############################################

resource "aws_ecr_repository_policy" "repo_access_policy" {

  repository = aws_ecr_repository.main_repo.name

  policy = jsonencode({

    Version = "2008-10-17"

    Statement = [

      {

        Sid = "AllowPullPush"

        Effect = "Allow"

        Principal = {

          AWS = "*"

        }

        Action = [

          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"

        ]

      }

    ]

  })

}

#############################################
# REGISTRY SCANNING CONFIGURATION
#############################################

resource "aws_ecr_registry_scanning_configuration" "scan_config" {

  scan_type = "ENHANCED"

  rule {

    scan_frequency = "SCAN_ON_PUSH"

    repository_filter {

      filter      = "*"
      filter_type = "WILDCARD"

    }

  }

}

#############################################
# REPLICATION CONFIGURATION
#############################################

resource "aws_ecr_replication_configuration" "replication" {

  replication_configuration {

    rule {

      destination {

        region      = "ap-south-1"
        registry_id = "123456789012"

      }

    }

  }

}

#############################################
# REGISTRY POLICY
#############################################

resource "aws_ecr_registry_policy" "registry_policy" {

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Sid = "AllowReplication"

        Effect = "Allow"

        Principal = {

          AWS = "*"

        }

        Action = [

          "ecr:ReplicateImage"

        ]

        Resource = "*"

      }

    ]

  })

}
