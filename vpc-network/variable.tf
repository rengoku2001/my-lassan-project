variable "region" {
  description = "AWS region"
  type = string
  default = "ap-south-1"
}

variable "vpc-name" {
  description = "VPC name for EKS"
  type = string
  default = "eks-vpc"
}

variable "ig-name" {
  description = "IG name for eks"
  type = string
  default = "eks-IG"
}

variable "pub-subnet-name1" {
  description = "pub subnet name1 for eks"
  type = string
  default = "pub-subnet1"
}

variable "pub-subnet-name2" {
  description = "pub subnet name2 for eks"
  type = string
  default = "pub-subnet2"
}

variable "pvt-subnet-name1" {
    description = "pvt subnet name1 for eks"
    type = string
    default = "pvt-subnet1"
}

variable "pvt-subnet-name2" {
    description = "pvt subnet name2 for eks"
    type = string
    default = "pvt-subnet2"
  
}

#public route table 

variable "public-rt-name" {
  description = "pub Route Table Name for eks"
  type = string
  default = "public-RT"
}

variable "pvt-rt-name" {
  description = "pvt Route Table Name for eks"
  type = string
  default = "private-RT"
}



