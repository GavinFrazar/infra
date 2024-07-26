resource "aws_ecr_lifecycle_policy" "this" {
  count = var.create ? 1 : 0

  repository = one(aws_ecr_repository.this[*].name)
  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire older untagged images",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_repository" "this" {
  count = var.create ? 1 : 0

  force_delete         = true
  image_tag_mutability = "MUTABLE"
  name                 = var.name_prefix

  image_scanning_configuration {
    scan_on_push = false
  }
}
