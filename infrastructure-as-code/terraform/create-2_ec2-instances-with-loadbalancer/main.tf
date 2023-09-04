# VPC
resource "aws_vpc" "default" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_hostnames = true
    enable_dns_support = true
}

# SUBNET1
resource "aws_subnet" "subnet1" {
    vpc_id = aws_vpc.default.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = var.az_1
}

# SUBNET2
resource "aws_subnet" "subnet2" {
    vpc_id = aws_vpc.default.id
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = true
    availability_zone = var.az_2
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "default" {
    vpc_id = aws_vpc.default.id
}

# ROUTE TABLE
resource "aws_route_table" "default" {
    vpc_id = aws_vpc.default.id
}

# ROUTE
resource "aws_route" "default" {
    route_table_id = aws_route_table.default.id
    gateway_id = aws_internet_gateway.default.id
    destination_cidr_block = "0.0.0.0/0"
}

# ROUTE TABLE ASSOCIATION1
resource "aws_route_table_association" "asn_subnet1" {
    subnet_id = aws_subnet.subnet1.id
    route_table_id = aws_route_table.default.id
}

# ROUTE TABLE ASSOCIATION2
resource "aws_route_table_association" "asn_subnet2" {
    subnet_id = aws_subnet.subnet2.id
    route_table_id = aws_route_table.default.id
}

# APPLICATION LOADBALANCER
resource "aws_lb" "default" {
    name = "lb"
    internal = false
    load_balancer_type = "application"

    security_groups = [
        aws_security_group.default.id
    ]

    subnets = [
        aws_subnet.subnet1.id,
        aws_subnet.subnet2.id,
    ]
}

# SECURITY GROUP
resource "aws_security_group" "default" {
    name = "lb-group"
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

# ALB LISTENER
resource "aws_lb_listener" "listener1" {
    load_balancer_arn = aws_lb.default.id
    port = "80"
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.default.arn
    }
}

# ALB LISTENER RULE
resource "aws_lb_listener_rule" "listener1_rule" {
    listener_arn = aws_lb_listener.listener1.arn
    priority = 99

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.default.arn
    }

    condition {
        path_pattern {
          values = ["/*"]
        }
    }
}

# ALB TARGET GROUP
resource "aws_lb_target_group" "default" {
    name = "ATG"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.default.id

    health_check {
        path = "/index.html"
    }
}

# ATG ATTACHMENT1
resource "aws_lb_target_group_attachment" "attach1" {
    target_group_arn = aws_lb_target_group.default.arn
    target_id = aws_instance.ins1.id
    port = 80
}

# ATG ATTACHMENT2
resource "aws_lb_target_group_attachment" "attach2" {
    target_group_arn = aws_lb_target_group.default.arn
    target_id = aws_instance.ins2.id
    port = 80
}

# EC2 INSTANCE1
resource "aws_instance" "ins1" {
    ami = "ami-0c3fd0f5d33134a76"
    vpc_security_group_ids = [aws_security_group.default.id]
    instance_type = "t2.micro"
    subnet_id = aws_subnet.subnet1.id
}

# EC2 INSTANCE2
resource "aws_instance" "ins2" {
    ami = "ami-0c3fd0f5d33134a76"
    vpc_security_group_ids = [aws_security_group.default.id]
    instance_type = "t2.micro"
    subnet_id = aws_subnet.subnet2.id
}