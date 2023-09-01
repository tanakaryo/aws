resource "aws_vpc" "default" {
    cidr_block ="10.0.0.0/16"
    enable_dns_hostnames = true
}

resource "aws_subnet" "default" {
    vpc_id = aws_vpc.default.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-northeast-1a"
    map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "default" {
    vpc_id = aws_vpc.default.id
}

resource "aws_route_table" "default" {
    vpc_id = aws_vpc.default.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.default.id
    }
}

resource "aws_route_table_association" "default" {
    subnet_id = aws_subnet.default.id
    route_table_id = aws_route_table.default.id
}

resource "aws_security_group" "default" {
    name = "test-sg"
    vpc_id = aws_vpc.default.id
    
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
}