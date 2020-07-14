provider "aws" {
  region = "ap-south-1"
  profile = "task_3"
}

resource "aws_vpc" "tvpc" {
  cidr_block       = "192.168.0.0/16"
  enable_dns_support="true"
  enable_dns_hostnames="true"
  instance_tenancy = "default"

  tags = {
    Name = "t3vpc"
  }
}

resource "aws_subnet" "pubsubnet" {
  vpc_id     =  aws_vpc.tvpc.id
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "prisubnet" {
  vpc_id     =  aws_vpc.tvpc.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "private_subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id =  aws_vpc.tvpc.id

  tags = {
    Name = "in_gateway"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id =  aws_vpc.tvpc.id
  
  tags = {
    Name = "route_table"
  }
}

resource "aws_route" "rt" {
  route_table_id            =   aws_route_table.route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id =  aws_internet_gateway.gw.id
  
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.pubsubnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_key_pair" "key" {
key_name = "mykeyy"
public_key="ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAryh7wbLe3IvfHCLmrc1fbXw1d1dwM7VQN029wAphsKi/gzzWdTLlafUi+Teuo1Ze84sPAb3IxUw5ewwED/N0hTy/7YgvBEX08FTU8X1eH06AtD8Zyf6kAbwXrjO2SGkz/TJ3gebhqfrDu3iYEG1Uo1JKgg284ce8cAd9G3/U5FD/LKdajGmLTAHLIoxp3WHBpRW9ciOK9+JQL9SGnYYF62+++h4fMCc/lyX4A/Sy7UJ7pCFP+ZjsRZ8V6SOXTpy+4PrrdqoDC/NMqs/5pBdBn8ORRk43WjUP8LsvTBEw3AvkMSMgazWl/Ov68tVN3UiwUE9vEQbB0mExsZrixvNYJw== rsa-key-20200713"
}

resource "aws_security_group" "wpsg" {
  name        = "wordpress"
  description = "Allow TLS inbound traffic"
  vpc_id      =   aws_vpc.tvpc.id

  ingress {
    description = "ssh"
    from_port   = 0
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "http"
    from_port   = 0
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "wordpress"
  }
}


resource "aws_security_group" "mysg" {
  name        = "mysql"
  description = "Allow MYSQL"
  vpc_id      =   aws_vpc.tvpc.id

  ingress {
    description = "MYSQL/Aurora"
    from_port   = 0
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "mysql"
  }
}


resource "aws_instance" "wordpress" {
  ami                  = "ami-000cbce3e1b899ebd"
  instance_type  = "t2.micro"
  key_name        = "mykeyy"
  security_groups =  [  aws_security_group.wpsg.id  ]
  subnet_id =  aws_subnet.pubsubnet.id
  
  tags = {
    Name = "wordpress-os"
  }
}


resource "aws_instance" "mysql" {
  ami                  = "ami-08706cb5f68222d09"
  instance_type  = "t2.micro"
  key_name        = "mykeyy"
  security_groups =  [  aws_security_group.mysg.id  ]
  subnet_id =  aws_subnet.prisubnet.id

  
  tags = {
    Name = "mysql-os"
  }
}