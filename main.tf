/**
 * neec環境構築
 *
 */
//---------------------------------------------------------
// 変数
//---------------------------------------------------------
locals {
    // サーバログイン用
    ssh_keyname = "webserver"
    ssh_pubkey = file("~/.ssh/katsube-aws.pub")
}

//---------------------------------------------------------
// Provider
//---------------------------------------------------------
provider "aws" {
	profile = "default"            // ~/.aws/crendentialsの設定を確認
	region = "ap-northeast-1"      // 東京リージョン
    default_tags {
        tags = {
            env = "neec"
        }
    }
}

//---------------------------------------------------------
// Network
//---------------------------------------------------------
//---------------------------
// VPC
//---------------------------
resource "aws_vpc" "neec_vpc" {
	cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "neec_vpc"
    }
}

//---------------------------
// Subnet
//---------------------------
// Public
resource "aws_subnet" "public_1a" {
	vpc_id = aws_vpc.neec_vpc.id
	availability_zone = "ap-northeast-1a"
	cidr_block = "10.0.1.0/24"
    tags = {
        Name = "public_1a"
    }
}

//---------------------------
// Internet Gateway
//---------------------------
resource "aws_internet_gateway" "neec" {
	vpc_id = aws_vpc.neec_vpc.id
}

//---------------------------
// NAT
//---------------------------
// Elastic IP
resource "aws_eip" "nat_1a" {
	vpc = true
}
// NAT Gateway
resource "aws_nat_gateway" "nat_1a" {
	subnet_id = aws_subnet.public_1a.id
	allocation_id = aws_eip.nat_1a.id
}

//---------------------------
// Route Table - public
//---------------------------
resource "aws_route_table" "public" {
	vpc_id = aws_vpc.neec_vpc.id
}
resource "aws_route" "public" {
	destination_cidr_block = "0.0.0.0/0"
	route_table_id = aws_route_table.public.id
	gateway_id = aws_internet_gateway.neec.id
}
resource "aws_route_table_association" "public_1a" {
	subnet_id = aws_subnet.public_1a.id
	route_table_id = aws_route_table.public.id
}

//---------------------------------------------------------
// EC2: Webサーバ
//---------------------------------------------------------
module "webserver"{
    source = "./module/ec2"
    name = "neec-webserver"

    // Network
    vpc_id     = aws_vpc.neec_vpc.id
    subnet_id  = aws_subnet.public_1a.id

    // Keypair
    keyname    = local.ssh_keyname
    public_key = local.ssh_pubkey
}
