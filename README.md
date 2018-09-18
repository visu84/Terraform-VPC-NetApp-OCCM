# terraform-aws-vpc-Ontap Cloud Manager 

This repository contains a [Terraform][] project that builds 

1 VPC, 2 Public Subnets, 2 Private subets, 1 NAT Gateway, 1 Internet Gateway, Route tables etc., 
NetApp OnCommand Cloud Manager environment into the chosen AWS region and location.

### NetApp and Amazon Marketplace registration
Prior running this template, you will need to ensure that your AWS account has subscribed to the official ONTAP Cloud for AWS and OnCommand Cloud Manager images 

### Cloud Manager AMI

Post registration at Market place and before proceeding, please make sure the AMI at below location and update the same for variable "occm_amis" in variables.tf 

https://aws.amazon.com/marketplace/pp/B018REK8QG



###  Make sure to provide below variables in terraform.tfvars, Rest of the variables are optional to change

aws_access_key = ""
aws_secret_key = ""

aws_region = ""
vpc_cidr = ""

public_subnet1_cidr = ""
public_subnet2_cidr = ""
private_subnet1_cidr = ""
private_subnet2_cidr = ""



key_name =""
occm_email =""
occm_password =""
company_name =""




## Usage

`terraform.tfvars` holds variables which should be overriden with valid ones.

### Plan

```
terraform plan -var-file terraform.tfvars
```

### Apply

```
terraform apply -var-file terraform.tfvars
```

### Destroy

```
terraform destroy -var-file terraform.tfvars
```

## Author


