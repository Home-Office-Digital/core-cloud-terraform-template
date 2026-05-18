# Add calling modules here.
#
# Example: call a Terraform module from a different git repository.
#
# module "external_module_example" {
#   source = "git::https://github.com/org_name/repo_name.git?ref=tag"
#
#   environment  = var.environment
#   project_name = var.project_name
#   vpc_id       = var.vpc_id
#   tags         = var.tags
# }
#
# Example: call child modules that live in this repository.
#
# module "module1" {
#   source = "./modules/module1"
#
#   environment  = var.environment
#   project_name = var.project_name
#   vpc_id       = var.vpc_id
#   tags         = var.tags
# }
#
# module "module2" {
#   source = "./modules/module2"
#
#   environment  = var.environment
#   project_name = var.project_name
#   vpc_id       = var.vpc_id
#   tags         = var.tags
# }
