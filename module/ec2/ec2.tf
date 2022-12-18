/**
 * EC2 - Webサーバ
 *
 */

//---------------------------------------------------------
// 変数
//---------------------------------------------------------
// Network
variable "vpc_id" { }
variable "subnet_id" { }

// SSH Keypair
variable "keyname" { }
variable "public_key" { }

// EC2
variable "name" { }
variable "ami" {
    default = "ami-0548e5d1cef315c7f"  // AmazonLinux2 ARM 64bit
}
variable "instance_type" {
    default = "t4g.micro"
}

//---------------------------------------------------------
// Keypair
//---------------------------------------------------------
resource "aws_key_pair" "webserver_key" {
    key_name = var.keyname
    public_key = var.public_key
}

//---------------------------------------------------------
// Security Group
//---------------------------------------------------------
resource "aws_security_group" "webserver_sg" {
    vpc_id = var.vpc_id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "neec"
    }
}

//---------------------------------------------------------
// EC2
//---------------------------------------------------------
resource "aws_instance" "webserver" {
    ami = var.ami
    instance_type = var.instance_type
    vpc_security_group_ids = [
        aws_security_group.webserver_sg.id
    ]
    subnet_id = var.subnet_id
    associate_public_ip_address = "true"
    key_name = aws_key_pair.webserver_key.key_name
    user_data = file("./module/ec2/setup.sh")
    tags = {
        Name = var.name
    }
}

//---------------------------------------------------------
// Elastic IP
//---------------------------------------------------------
resource "aws_eip" "webserver" {
    vpc = true
    instance = aws_instance.webserver.id
    tags = {
        Name = "neec"
    }
}

