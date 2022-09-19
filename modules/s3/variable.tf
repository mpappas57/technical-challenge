#S3 Vars
variable "s3_folders" {
  type        = list
  description = "The list of S3 folders to create"
  default     = ["Images", "Logs"]
}
variable "s3_bucket_name" {}
variable "s3_acl" {}               
variable "block_public_acls" {}     
variable "block_public_policy"     {}
variable "ignore_public_acls"     {}
variable "restrict_public_buckets" {}