resource "aws_vpc" "ontap-demo" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "${var.vpc_name}"
    }
}

resource "aws_internet_gateway" "ontap-igw" {
    vpc_id = "${aws_vpc.ontap-demo.id}"
	tags {
		Name = "${var.igw_name}"
	}
}


/*
  Public Subnets
*/
resource "aws_subnet" "ontap-public1" {
    vpc_id = "${aws_vpc.ontap-demo.id}"

    cidr_block = "${var.public_subnet1_cidr}"
    availability_zone = "${var.az_1}"

    tags {
        Name = "${var.public_subnet1_name}"
    }
}

resource "aws_subnet" "ontap-public2"{
    vpc_id = "${aws_vpc.ontap-demo.id}"

    cidr_block = "${var.public_subnet2_cidr}"
    availability_zone = "${var.az_2}"

    tags {
        Name = "${var.public_subnet2_name}"
    }
}

resource "aws_route_table" "ontap-pub-rt"{
    vpc_id = "${aws_vpc.ontap-demo.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.ontap-igw.id}"
    }

    tags {
        Name = "${var.public_RT}"
    }
}

resource "aws_route_table_association" "ontap-pub-rt1" {
    subnet_id = "${aws_subnet.ontap-public1.id}"
    route_table_id = "${aws_route_table.ontap-pub-rt.id}"
}

resource "aws_route_table_association" "ontap-pub-rt2" {
    subnet_id = "${aws_subnet.ontap-public2.id}"
    route_table_id = "${aws_route_table.ontap-pub-rt.id}"
}

/*
NAT Gateway
*/

resource "aws_eip" "ontap-nat-ip" {
    vpc      = true
}
resource "aws_nat_gateway" "ontap-nat" {
    allocation_id = "${aws_eip.ontap-nat-ip.id}"
    subnet_id = "${aws_subnet.ontap-public1.id}"
    depends_on = ["aws_internet_gateway.ontap-igw"]
	tags {
		Nmae = "${var.nat_name}"
	}
}


/*
  Private Subnet
*/
resource "aws_subnet" "ontap-private1" {
    vpc_id = "${aws_vpc.ontap-demo.id}"

    cidr_block = "${var.private_subnet1_cidr}"
    availability_zone = "${var.az_1}"

    tags {
        Name = "${var.private_subnet1_name}"
    }
}

resource "aws_subnet" "ontap-private2" {
    vpc_id = "${aws_vpc.ontap-demo.id}"

    cidr_block = "${var.private_subnet2_cidr}"
    availability_zone = "${var.az_2}"

    tags {
        Name = "${var.private_subnet2_name}"
    }
}

resource "aws_route_table" "ontap-pri-rt"{
    vpc_id = "${aws_vpc.ontap-demo.id}"

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.ontap-nat.id}"
    }

    tags {
        Name = "${var.private_RT}"
    }
}

resource "aws_route_table_association" "ontap-pri-rt1" {
    subnet_id = "${aws_subnet.ontap-private1.id}"
    route_table_id = "${aws_route_table.ontap-pri-rt.id}"
}

resource "aws_route_table_association" "ontap-pri-rt2" {
    subnet_id = "${aws_subnet.ontap-private2.id}"
    route_table_id = "${aws_route_table.ontap-pri-rt.id}"
}

/*
Create OCCM role
*/

resource "aws_iam_role" "occm_ec2_role" {
  name                = "occm_ec2_role"
  description         = "Grants access to services required by NetApp's OnCommand Cloud Manager"
  assume_role_policy  = "${file("${path.module}/files/occm-ec2-role.json")}"
}

/*
EC2 instance profile based on the provided role above
*/

resource "aws_iam_instance_profile" "occm_instance_profile" {
  name        = "occm_instance_profile"
  role        = "${aws_iam_role.occm_ec2_role.id}"
  depends_on  = [
    "aws_iam_role.occm_ec2_role"
  ]
}

/*
Default policy document for privileges requireed by OnCommand Cloud Manager
*/
resource "aws_iam_role_policy" "occm_role_policy" {
  name        = "occm_role_policy"
  role        = "${aws_iam_role.occm_ec2_role.id}"
  depends_on  = [
    "aws_iam_role.occm_ec2_role"
  ]

  policy = "${file("${path.module}/files/occm-role-policy.json")}"
}

/*
Security group rules for Ontap Cloud Manager Instance
*/

resource "aws_security_group" "occm_access" {
  name                = "${var.occm_name}"
  description         = "Oncommand Cloud Manager Security Group"
  vpc_id              = "${aws_vpc.ontap-demo.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.occm_name}"
	}

}

/*
/*
Launch a new AWS Marketplace instance of Netapp's OnCommand Cloud Manager and assign the newly
created EC2 Instance Profile.
*/
resource "aws_instance" "OCCM" {
  depends_on = [
    "aws_iam_role_policy.occm_role_policy",
    "aws_iam_role.occm_ec2_role",
    "aws_security_group.occm_access"
  ]
  ami                         = "${lookup(var.occm_amis, var.aws_region)}"
  instance_type               = "t2.medium"
  subnet_id                   = "${aws_subnet.ontap-public1.id}"
  vpc_security_group_ids      = ["${aws_security_group.occm_access.id}"]
  key_name                    = "${var.key_name}"
  associate_public_ip_address = "true"
  iam_instance_profile        = "${aws_iam_instance_profile.occm_instance_profile.id}"
  tags {
    Name = "${var.occm_name}"
    }
}