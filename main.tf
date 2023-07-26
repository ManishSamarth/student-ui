provider "aws" {
  region = "us-east-2"
}

variable "instance_profile_name" {
  type    = string
  default = "ec2-instance-profile"
}

variable "iam_policy_name" {
  type    = string
  default = "s3-and-ec2-full-acess"
}

variable "role_name" {
  type    = string
  default = "role-for-instance-terraform"
}

# Create an IAM policy
resource "aws_iam_policy" "jenkins_iam_policy" {
  name = var.iam_policy_name

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
        
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "ec2:*"
            ],
            "Resource": "*"
        }
    ]
})
}

# Create an IAM role
resource "aws_iam_role" "jenkins_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the IAM policy to the IAM role
resource "aws_iam_policy_attachment" "jenkins_role_policy_attachment" {
  name = "Policy Attachement"
  policy_arn = aws_iam_policy.jenkins_iam_policy.arn
  roles       = [aws_iam_role.jenkins_role.name]
}

# Create an IAM instance profile
resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name = var.instance_profile_name
  role = aws_iam_role.jenkins_role.name
}

resource "aws_instance" "iam-instance-profile-test" {
  ami           = "ami-00c6c849418b7612c"
  instance_type = "t2.micro"
  key_name      = "mykey"
  iam_instance_profile = aws_iam_instance_profile.jenkins_instance_profile.name
  vpc_security_group_ids = [aws_security_group.jenkins-sg-new.id]

  user_data = <<-EOF
  #!/bin/bash
  BUCKET=artifactory-manish
  sudo yum update 
  sudo yum install java-1.8.0-amazon-corretto-devel.x86_64  -y 
  wget https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.91/bin/apache-tomcat-8.5.91.zip
  sudo yum install zip  -y 
  sudo unzip apache-tomcat-8.5.91.zip
  sudo mv apache-tomcat-8.5.91 /mnt/tomcat
  KEY=`aws s3 ls $BUCKET --recursive | sort | tail -n 1 | awk '{print $4}'`
  aws s3 cp s3://$BUCKET/$KEY /mnt/tomcat/webapps/student.war
  sudo chown -R ec2-user: /mnt/tomcat
  cd /mnt/tomcat/bin
  sudo chmod 755 *
  sudo ./catalina.sh start 
EOF

  tags = {
    Name = "iam-instance-profile-test"
  }
}

resource "aws_security_group" "jenkins-sg-new" {
  name        = "jenkins-sg-new"
  description = "Allow TLS inbound traffic"

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 8080
    to_port     = 8080
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
    Name = "jenkins-sg-new"
  }
}
