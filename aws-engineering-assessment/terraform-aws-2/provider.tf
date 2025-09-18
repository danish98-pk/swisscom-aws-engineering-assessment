terraform {
  backend "s3" {
    bucket  = "tf-state-bucket-680343405290"
    key     = "tfstatefile"
    region  = "eu-central-1"
    profile = "default"
  }
}


provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}