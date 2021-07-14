
output "eks_cluster_endpoint1" {
  value = aws_eks_cluster.aws_eks.endpoint
}

output "eks_cluster_certificate_authority1" {
  value = aws_eks_cluster.aws_eks.certificate_authority 
}
output "region1" {
    value = data.aws_region.current
}
output "name" {
    value = aws_eks_cluster.aws_eks.name
}
output "endpoint" {
  value = aws_eks_cluster.aws_eks.endpoint
}
output "certificate_authority" {
  value = aws_eks_cluster.aws_eks.certificate_authority.0.data
}
