terraform {
  required_version = "1.3.4" #Forcing which version of Terraform needs to be used
  required_providers {
    aws = {
      version = "<= 5.0.0" #Forcing which version of plugin needs to be used.
      source  = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket         = "devopsb28terraformprod"
    key            = "b28-multibranch-prod.tfstate"
    region         = "us-east-1"
    #dynamodb_table = "devopsb25-terraform-state-lock-dynamo"
    #encrypt        = true
  }
}