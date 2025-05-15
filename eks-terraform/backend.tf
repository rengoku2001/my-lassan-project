terraform {
  backend "s3" {
    bucket = "duckbhai"
    region = "ap-south-1"
    key = "k8/terraform.tfstate"
    encrypt = true
    use_lockfile = true
    
  }
}