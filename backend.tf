terraform {
  backend "s3" {
    bucket = "sctp-ce8-tfstate"
    key    = "coach16.1.tfstate"
    region = "ap-southeast-1"
  }
}