resource "aws_vpc" "example_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "Main"
  }
}

resource "aws_subnet" "example_subnet" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "Main"
  }
}