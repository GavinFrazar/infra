.PHONY: all
all:
	@echo "all/default target does nothing."

.PHONY: apply
apply:
	terraform apply

.PHONY: destroy
destroy:
	terraform destroy

.PHONY: eks-cluster
eks-cluster:
	terraform apply \
		-target='module.eks.aws_eks_cluster.this[0]'

.PHONY: teleport-eks
teleport-eks:
	terraform apply \
		-target='module.teleport_eks'

.PHONY: aws
aws:
	terraform apply \
		-target="module.aws_iam_roles" \
		-target="module.aws_rds_postgres" \
		-target="module.aws_redshift" \
		-target="module.aws_redshift_serverless" \
		-target="module.aws_iam_redshift_serverless_user" \
		-target="module.aws_ci_e2e_test" \
		-target="module.aws_ecr" \
		-target="module.aws_databases_host" \
		-target="module.vpc"

.PHONY: azure
azure:
	terraform apply \
		-target='module.azure_vm' \
		-target='module.azure_mysql'

.PHONY: gcp
gcp:
	terraform apply \
		-target='module.gcp_spanner' \
		-target='module.gcp_iam_spanner'
