resource "aws_instance" "default" {
    ami = "ami-09d28faae2e9e7138"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.default.id
    vpc_security_group_ids = [aws_security_group.default.id]
    
    user_data = <<EOF
    #!/bin/bash
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    EOF
}