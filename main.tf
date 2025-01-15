module "vpc" {
  source = "./modules/vpc"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  enable_igw = true
  enable_nat_gateway = true
  region = var.region
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["eu-central-1a","eu-central-1b"]
}

module "ec2" {
  source              = "./modules/ec2"
  ami                 = "ami-03074cc1b166e8691"
  instance_type       = "t2.micro"
  subnet_ids          = module.vpc.public_subnet_ids
  name_prefix         = "web-server"
  elastic_ip          = module.ec2.elastic_ip_allocation_id
  vpc_id              = module.vpc.vpc_id
}



module "lambda" {
  source = "./modules/lambda"
  active_instance_id  = module.ec2.instance_ids[0]
  passive_instance_id = module.ec2.instance_ids[1]
  eip                 = module.ec2.elastic_ip_public_ip
  region = var.region
}

module "cloudfront" {
  source = "./modules/cloudfront" 

  }