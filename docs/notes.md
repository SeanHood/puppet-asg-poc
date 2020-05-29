# Notes

* https://github.com/puppetlabs/best-practices
* https://www.devopsgroup.com/blog/setting-up-and-using-puppet/
* https://github.com/dogjarek/puppet-hiera/blob/production/nodes/puppetmaster.puppet.aws.yaml
* https://www.1strategy.com/blog/2018/09/18/monitoring-serverless-microservices-2/


## Puppet Role name, from Terraform to Hiera

The main part of this Proof of Concept is passing in a "role", which is part of the puppet roles and profiles pattern.

This is the route that this string takes to turn it from some config to the purpose the instance has.

1. First we define the role in our node_group module. As puppet_role = "appserver".
1. `puppet_role` is passed as a variable to the node_group module
1. node_group module sets a tag on the `aws_autoscaling_group` resource as `aws_role`
1. `aws_role` is propagated to the EC2 instance when created by the ASG
1. When the EC2 instance boots, the cloud-init script runs
1. cloud-init runs `aws ec2 describe-tags` on itself
1. Still in the cloud-init script, we drop into puppet's csr_attributes.yaml: pp_role: $aws_role
1. Puppet runs and `pp_role: appserver` is baked into the CSR before being sent to the Puppetserver for signing
1. Puppet server signs the certificate
1. When puppet is now ran, it has e


## Problems to Solve

* Puppetsever certs are stateful:
	- Rsync to s3
	- Mount EFS to store certs
	- Mount s3 for certs

* Service Discovery
	- Need a way for instances to find the puppetserver easily in our POC

* Document how a tag gets from Terraform into Hiera
