# Add calling modules here 

# The below code snippet shows how to call a TF modules from a different git repo based on provided tag.
module "enter name here" {
  source = "git::https://github.com/org_name/repo_name.git?ref=tag"

  # Add required inputs for the module being called
  # These values could come from the variables defined in terraform/environments/<environment-name>/terraform.tfvars
  # The below values are something that you could use but feel free to update and change depending on your need/requirements
  environment  = ""
  project_name = ""
  vpc_id       = ""
  sudbnet_ids  = ""
  tags         = var.tags
}

# The below code snippet shows how you can call other TF modules that are located in the same repo.
module "calling_module_1" {
  source = "./modules/module1"

  # Add required inputs for the module being called
  # These values could come from the variables defined in terraform/environments/<environment-name>/terraform.tfvars
  # The below values are something that you could use but feel free to update and change depending on your need/requirements
  environment  = ""
  project_name = ""
  vpc_id       = ""
  tags         = var.tags
}

module "calling_module_2" {
  source = "./modules/module2"

  # Add required inputs for the module being called
  # These values could come from the variables defined in terraform/environments/<environment-name>/terraform.tfvars
  # The below values are something that you could use but feel free to update and change depending on your need/requirements
  environment  = ""
  project_name = ""
  vpc_id       = ""
  tags         = var.tags
}