terraform {
  backend "s3" {
    bucket = "nus-iss-equeue-terraform"
    key    = "frontend/tfstate"
    region = "us-east-1"
  }
}