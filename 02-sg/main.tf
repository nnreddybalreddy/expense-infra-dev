module "db" {
   source = "git::https://github.com/nnreddybalreddy/terraform-security-group.git"
   project_name=var.project_name
   environment = var.environment
   sg_description = "allow sg for db"
   common_tags=var.common_tags
   sg_name="db"
   vpc_id=data.aws_ssm_parameter.vpc_id.value
}

module "backend" {
   source = "git::https://github.com/nnreddybalreddy/terraform-security-group.git"
   project_name=var.project_name
   environment = var.environment
   sg_description = "allow sg for backend"
   common_tags=var.common_tags
   sg_name="backend"
   vpc_id=data.aws_ssm_parameter.vpc_id.value
}

module "frontend" {
   source = "git::https://github.com/nnreddybalreddy/terraform-security-group.git"
   project_name=var.project_name
   environment = var.environment
   sg_description = "allow sg for frontend"
   common_tags=var.common_tags
   sg_name="frontend"
   vpc_id=data.aws_ssm_parameter.vpc_id.value
}

module "bastion" {
  source = "git::https://github.com/nnreddybalreddy/terraform-security-group.git"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for Bastion Instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
  sg_name = "bastion"
}



  module"app_alb"{
  source="git::https://github.com/NarendraNReddy1/terraform-aws-secruitygroup.git"
  project_name =var.project_name
  environment =var.environment
  sg_description ="SG for app_ab Instances"
  vpc_id=data.aws_ssm_parameter.vpc_id.value
  sg_name="app_alb"
  common_tags =var.common_tags


}


module"vpn"{
  source="git::https://github.com/NarendraNReddy1/terraform-aws-secruitygroup.git"
  project_name =var.project_name
  environment =var.environment
  sg_description ="SG for vpn Instances"
  vpc_id=data.aws_ssm_parameter.vpc_id.value
  sg_name="vpn"
  common_tags =var.common_tags
  ingress_rules=var.vpn_sg_rules
}





# DB is accepting connections from backend
resource "aws_security_group_rule" "db_backend" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.backend.sg_id # source is where you are getting traffic from
  security_group_id = module.db.sg_id
}

resource "aws_security_group_rule" "db_bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id # source is where you are getting traffic from
  security_group_id = module.db.sg_id
}

resource"aws_security_group_rule""db_vpn"{
  type             ="ingress"
  to_port          =3306
  from_port        =3306
  protocol         ="tcp"
  source_security_group_id=module.vpn.sg_id#backend
  security_group_id=module.db.sg_id
}



resource"aws_security_group_rule""backend_app_alb"{
  type             ="ingress"
  to_port          =8080
  from_port        =8080
  protocol         ="tcp"
  source_security_group_id=module.app_alb.sg_id#backend
  security_group_id=module.backend.sg_id
}

resource "aws_security_group_rule" "backend_vpn_ssh" {
  type              = "ingress"
  to_port           = 22
  from_port         = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id #backend
  security_group_id = module.backend.sg_id
}


resource "aws_security_group_rule" "backend_vpn_http" {
  type              = "ingress"
  to_port           = 8080
  from_port         = 8080
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id #backend
  security_group_id = module.backend.sg_id
}

resource "aws_security_group_rule" "backend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id # source is where you are getting traffic from
  security_group_id = module.backend.sg_id
}


resource"aws_security_group_rule""app_alb_vpn"{
  type             ="ingress"
  to_port          =80
  from_port        =80
  protocol         ="tcp"
  source_security_group_id=module.vpn.sg_id #backend
  security_group_id=module.app_alb.sg_id
}


# resource "aws_security_group_rule" "frontend_public" {
#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]
#   security_group_id = module.frontend.sg_id
# }


# resource "aws_security_group_rule" "frontend_bastion" {
#   type              = "ingress"
#   from_port         = 22
#   to_port           = 22
#   protocol          = "tcp"
#   source_security_group_id = module.bastion.sg_id # source is where you are getting traffic from
#   security_group_id = module.frontend.sg_id
# }

resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id
}

# resource "aws_security_group_rule" "backend_bastion" {
#   type              = "ingress"
#   from_port         = 22
#   to_port           = 22
#   protocol          = "tcp"
#   source_security_group_id = module.bastion.sg_id # source is where you are getting traffic from
#   security_group_id = module.backend.sg_id
# }





