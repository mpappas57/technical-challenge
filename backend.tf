terraform {
  backend "s3" {
    bucket = "tf-start-backend"
    key    = "test1/"
    region = "us-east-1"
  }
}