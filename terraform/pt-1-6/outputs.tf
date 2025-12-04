output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}

output "private_ips" {
  value = [for i in aws_instance.private : i.private_ip]
}

output "bucket_name" {
  value = aws_s3_bucket.key_bucket.id
}