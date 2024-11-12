resource "aws_iam_role" "ec2-role" {
  name = "ec2-role"
  assume_role_policy = <<EOF
  {
         "Version": "2012-10-17",
        "Statement": [
       {
          "Effect": "Allow",
          "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
       ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "policy1" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "profile1" {
  name = "profile1"
  role = aws_iam_role.ec2-role.name
}

resource "aws_security_group" "ec2-sg" {
  name        = "ec2-sg"
  description = "sg for ec2"
  ingress = [ 
    for port in [22,80,8080,8081,9000]: {
        description      = "for multiple ports"
        from_port        = port
        to_port          = port
        protocol         = "tcp"
        cidr_blocks      = [ "0.0.0.0/0" ]
        ipv6_cidr_blocks = []
        prefix_list_ids  = []
        self             = false
        security_groups  = []
    }
   ]
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags={
        Name = "ec2-sg"
    }
}

resource "aws_instance" "instance" {
 ami                    = var.ami_value
 instance_type          = var.instancetype
 key_name               = var.ssh
 iam_instance_profile   = aws_iam_instance_profile.profile1.name
 vpc_security_group_ids = [aws_security_group.ec2-sg.id]

root_block_device {
   volume_size = 30
 }
 
 tags={
    Name = "Jenkins-server"
 }
}
