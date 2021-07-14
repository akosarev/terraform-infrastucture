# Terraform infrastructure
This is terraform infrastructure 

## Runtime

First you have to run 
```
terraform init
```

After ```terraform plan``` and ```terraform apply```

During this run next components will be created:

* VPC
* 4 subnets (2 private for web, 2 public for web)
* 2 NAT gateway
* 1 Internet gateway
* 2 EiP and allocation these ips to natgw
* Security groups 
* EKS cluster
* 2 ESK nodes
* role attachments and many other things.


Best practices to choose AMI ID is using data block, so i added it to choose ami_id for ec2 instance:

```
data "aws_ami" "amazon-linux-2" {
    most_recent = true
    owners = [ "amazon" ]

    filter {
        name   = "owner-alias"
        values = ["amazon"]
    }


    filter {
        name   = "name"
        values = ["amzn2-ami-hvm*"]
    }
}
```

I rewrote some parameters in override.tf file. Every parameter i provide there will be asked by Terraform during plan or apply.


Notes:

If you run locally and after want to check EKS you can copy config:
```buildoutcfg
aws eks --region eu-west-1 update-kubeconfig --name eks_infra
```

