resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.demo-hyq.id

  tags = {
    Name = "igw"
  }
}