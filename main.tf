# VPC, this VPC only include one public subnet and two private subnets, without NAT instance
# Just to demo how to use terraform and ansible to provision simple infrastructures and deploy an application.

## Create VPC
resource "aws_vpc" "demo_vpc" {
  cidr_block           = "10.13.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_classiclink   = false

  tags = {
    "Name"  = "eric-demo-vpc"
    "Owner" = "eric"
  }
}

## Create a public subnet for ec2 instance where the wordpress server is located
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.demo_vpc.id
  cidr_block              = "10.13.0.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    "Name"  = "eric-demo-vpc-public-subnet-a1"
    "Owner" = "eric"
  }
}

## Create 2 private subnets for database(mysql)
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.demo_vpc.id
  cidr_block              = "10.13.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false

  tags = {
    "Name"  = "eric-demo-vpc-private-subnet-a1"
    "Owner" = "eric"
  }
}
resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.demo_vpc.id
  cidr_block              = "10.13.3.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = false

  tags = {
    "Name"  = "eric-demo-vpc-private-subnet-b1"
    "Owner" = "eric"
  }
}

## Create a internet gateway for this vpc
resource "aws_internet_gateway" "demo_igw" {
  vpc_id = aws_vpc.demo_vpc.id
  tags   = {
    "Name"  = "IGW-demo-vpc"
    "Owner" = "eric"
  }
}
## Create a route table in this vpc
resource "aws_route_table" "demo_public_rt" {
  vpc_id = aws_vpc.demo_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_igw.id
  }
}
## Associate route table to the public subnet
resource "aws_route_table_association" "demo_public_rt_a" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.demo_public_rt.id
}

## Create security groups for wordpress server and rds
### Security group for wordpress server
resource "aws_security_group" "sg_wordpress" {
  name        = "sgWordPress"
  description = "Allow access to wordpress server"
  vpc_id      = aws_vpc.demo_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Open the SSH port to the deployment server"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["a.b.d.d/32"]
  }

  tags = {
    "Name"  = "sgWordPress"
    "Owner" = "eric"
  }
}

### Security group for RDS
resource "aws_security_group" "sg_mysql" {
  name        = "sgMySQL"
  description = "What server can access the db server"
  vpc_id      = aws_vpc.demo_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description     = "MySQL"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_wordpress.id]
  }

  tags = {
    "Name"  = "sgMySQL"
    "Owner" = "eric"
  }
}

# Ceate a RDS
## Create an option group for this rds instance
resource "aws_db_option_group" "demo_db_option_group" {
  name                     = "demo-db-option-group"
  option_group_description = "The demo rds option group"
  engine_name              = "mysql"
  major_engine_version     = "8.0"

  tags = {
    "Name"  = "demo-db-option-group"
    "Owner" = "eric"
  }
}
## Create a parameter group for the rds instance
resource "aws_db_parameter_group" "demo_db_parameter_group" {
  name   = "demo-db-parameter-group"
  family = "mysql8.0"

  tags = {
    Name  = "demo-db-parameter-group"
    Owner = "eric"
  }
}
## Create a subnet group for this rds instance
resource "aws_db_subnet_group" "demo_db_subnet_group" {
  name       = "demo-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name  = "demo-db-subnet-group"
    Owner = "eric"
  }
}
## Launch a RDS instance
resource "aws_db_instance" "demo_db" {
  engine                     = "mysql"
  engine_version             = "8.0.27"
  identifier                 = "demo-db"
  username                   = var.db_root_user
  password                   = var.db_root_password
  instance_class             = "db.t3.small"
  allocated_storage          = 10
  backup_retention_period    = 1
  db_subnet_group_name       = aws_db_subnet_group.demo_db_subnet_group.id
  parameter_group_name       = aws_db_parameter_group.demo_db_parameter_group.id
  option_group_name          = aws_db_option_group.demo_db_option_group.id
  vpc_security_group_ids     = ["${aws_security_group.sg_mysql.id}"]
  apply_immediately          = true
  skip_final_snapshot        = true
  copy_tags_to_snapshot      = true
  storage_encrypted          = true
  auto_minor_version_upgrade = false
  multi_az                   = false
  backup_window              = "09:46-10:16"
  maintenance_window         = "Mon:00:00-Mon:00:30"

  tags = {
    Name  = "eric-demo-db"
    Owner = "eric"
  }
}
## Create a route 53 record for this rds instance
resource "aws_route53_record" "mysql" {
  zone_id = var.hosted_zone_id
  name    = var.db_address
  records = ["${aws_db_instance.demo_db.address}"]
  type    = "CNAME"
  ttl     = "300"
}

# Launch an EC2 instance for wordpress program
## Find the latest Amazon Linux 2 AMI
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
## Create a key pair to ssh the ec2 instance
resource "aws_key_pair" "key_pair" {
  key_name   = "eric-demo"
  public_key = file(var.PUBLIC_KEY_PATH)
}
## Launch an instance with the ami we found
resource "aws_instance" "wordpress_instance" {
  ami           = data.aws_ami.amzlinux2.id
  instance_type = "t3a.small"
  subnet_id     = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.sg_wordpress.id]
  key_name               = aws_key_pair.key_pair.id

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 10
    volume_type           = "gp3"

    tags = {
      Name  = "wordpress-server-storage"
      Owner = "eric"
    }
  }

  tags = {
    Name  = "demo-wordpress-server"
    Owner = "eric"
  }

  depends_on = [aws_db_instance.demo_db]
}
## Create a route 53 record for wordpress
resource "aws_route53_record" "wordpress" {
  zone_id = var.hosted_zone_id
  name    = var.wordpress_address
  records = ["${aws_instance.wordpress_instance.public_ip}"]
  type    = "A"
  ttl     = "300"
}
## Output the access address
output "access_address" {
  value = "The wordpress service is ready. Go to http://${aws_route53_record.wordpress.fqdn} or https://${aws_route53_record.wordpress.fqdn}"
}

# Connect the ec2 instance to provision wordpress service
resource "null_resource" "wordpress_provision" {
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.PRIV_KEY_PATH)
    host        = aws_instance.wordpress_instance.public_ip
  }

  # Create database and db user on remote client
  provisioner "file" {
    source      = "./files/db_init.sh"
    destination = "/tmp/db_init.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/db_init.sh",
      "sudo /tmp/db_init.sh ${var.db_root_user} ${var.db_root_password} ${var.db_address}",
    ]
  }

  # Play ansible playbook to deploy wordpress service
  provisioner "local-exec" {
     command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user -i '${aws_instance.wordpress_instance.public_ip},' --private-key ${var.PRIV_KEY_PATH} playbook.yaml"
  }
}
