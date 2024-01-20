module "remote-state" {
    source = "./modules/remote-state"
    
    aws_profile = var.aws_profile
    aws_region  = var.aws_region
}