data "aws_iam_policy_document" "access" {
  count = var.create ? 1 : 0

  statement {
    sid    = "RDSAccess"
    effect = "Allow"
    actions = [
      "rds:DescribeDBInstances",
      "rds:DescribeDBClusters",
      "rds:ModifyDBInstance",
      "rds:ModifyDBCluster",
      "rds:DescribeDBProxies",
      "rds:DescribeDBProxyEndpoints",
      "rds-db:connect"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "RedshiftAccess"
    effect = "Allow"
    actions = [
      "redshift:DescribeClusters",
      "redshift:GetClusterCredentials",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "RedshiftServerlessAccess"
    effect = "Allow"
    actions = [
      "redshift-serverless:GetWorkgroup",
      "redshift-serverless:GetEndpointAccess",
      "redshift-serverless:GetCredentials",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ElastiCacheAccess"
    effect = "Allow"
    actions = [
      "elasticache:DescribeReplicationGroups",
      "elasticache:DescribeUsers",
      "elasticache:Connect",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "MemoryDBAccess"
    effect = "Allow"
    actions = [
      "memorydb:DescribeSubnetGroups",
      "memorydb:DescribeUsers",
      "memorydb:Connect"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "discovery" {
  count = var.create ? 1 : 0

  statement {
    sid    = "RDSDiscovery"
    effect = "Allow"
    actions = [
      "rds:DescribeDBInstances",
      "rds:DescribeDBClusters",
      "rds:DescribeDBProxies",
      "rds:DescribeDBProxyEndpoints",
      "rds:ListTagsForResource",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "RedshiftDiscovery"
    effect = "Allow"
    actions = [
      "redshift:DescribeClusters",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "RedshiftServerlessDiscovery"
    effect = "Allow"
    actions = [
      "redshift-serverless:ListWorkgroups",
      "redshift-serverless:ListEndpointAccess",
      "redshift-serverless:ListTagsForResource"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ElastiCacheDiscovery"
    effect = "Allow"
    actions = [
      "elasticache:ListTagsForResource",
      "elasticache:DescribeReplicationGroups",
      "elasticache:DescribeCacheClusters",
      "elasticache:DescribeCacheSubnetGroups",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "MemoryDBDiscovery"
    effect = "Allow"
    actions = [
      "memorydb:ListTags",
      "memorydb:DescribeClusters",
      "memorydb:DescribeSubnetGroups",
    ]
    resources = ["*"]
  }
}
