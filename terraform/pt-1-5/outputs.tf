output "public_instance_ips" {
  value = [for i in aws_instance.public : i.public_ip]
}


output "private_instance_ips" {
  value = [for i in aws_instance.private : i.private_ip]
}


output "s3_bucket_name" {
  value = try(aws_s3_bucket.project[0].bucket, null)
}
