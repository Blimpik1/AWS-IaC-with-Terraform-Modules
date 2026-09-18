module "network" {
  source = "./modules/network"

  vpc_cidr         = var.vpc_cidr
  vpc_name         = "${var.project_id}-vpc"
  igw_name         = "${var.project_id}-igw"
  route_table_name = "${var.project_id}-rt"
  project_id       = var.project_id

  public_subnets = {
    subnet_a = {
      cidr_block        = "10.10.1.0/24"
      availability_zone = "eu-west-1a"
      name              = "${var.project_id}-subnet-public-a"
    }
    subnet_b = {
      cidr_block        = "10.10.3.0/24"
      availability_zone = "eu-west-1b"
      name              = "${var.project_id}-subnet-public-b"
    }
    subnet_c = {
      cidr_block        = "10.10.5.0/24"
      availability_zone = "eu-west-1c"
      name              = "${var.project_id}-subnet-public-c"
    }
  }
}

module "network_security" {
  source = "./modules/network_security"

  vpc_id               = module.network.vpc_id
  allowed_ip_range     = var.allowed_ip_range
  ssh_sg_name          = "${var.project_id}-ssh-sg"
  public_http_sg_name  = "${var.project_id}-public-http-sg"
  private_http_sg_name = "${var.project_id}-private-http-sg"
  project_id           = var.project_id
}

module "application" {
  source = "./modules/application"

  vpc_id                      = module.network.vpc_id
  subnet_ids                  = module.network.public_subnet_ids
  alb_security_group_id       = module.network_security.public_http_sg_id
  instance_security_group_ids = [module.network_security.ssh_sg_id, module.network_security.private_http_sg_id]
  instance_type               = "t3.micro"
  launch_template_name        = "${var.project_id}-template"
  asg_name                    = "${var.project_id}-asg"
  alb_name                    = "${var.project_id}-lb"
  project_id                  = var.project_id
}