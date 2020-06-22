# Notes

* https://github.com/puppetlabs/best-practices
* https://www.devopsgroup.com/blog/setting-up-and-using-puppet/
* https://github.com/dogjarek/puppet-hiera/blob/production/nodes/puppetmaster.puppet.aws.yaml
* https://www.1strategy.com/blog/2018/09/18/monitoring-serverless-microservices-2/


## Puppet Role name, from Terraform to Puppet Manifests

The main part of this Proof of Concept is passing in a "role", which is part of the puppet roles and profiles pattern.

This is the route that this string takes to turn it from some config to the purpose the instance has.

1. First we define the role in our node_group module. As puppet_role = "appserver".
1. `puppet_role` is passed as a variable to the node_group module
1. node_group module sets a tag on the `aws_autoscaling_group` resource as `aws_role`
1. `aws_role` is propagated to the EC2 instance when created by the ASG
1. When the EC2 instance boots, the cloud-init script runs `aws ec2 describe-tags` on itself
1. In the cloud-init script, we template into puppet's `csr_attributes.yaml`: `pp_role: $aws_role`
1. Puppet runs and `pp_role: appserver` is baked into the CSR before being sent to the Puppetserver for signing
1. Puppet server signs the certificate
1. When puppet is now ran, it has the pp_role (and other attributes) added into the certificate.
1. In our control-repo, under manifests/site.pp we have an `include role::${trusted['extensions']['pp_role']}`
1. 


## Problems to Solve

* Puppetsever certs are stateful:
	- `aws s3 sync` to/from s3 on cron/incron (Current preferred option)
	- Mount EFS to store certs
	- Mount s3 for certs

* Passing data from Terraform to Puppet
	- For example, we create an s3 bucket with a unique suffix, or an EFS volume we want mounting. 
	The bucket name, or the EFS volume ID needs to be passed to Puppet for Puppet to pass that to the application or to mount the volume.
		- AWS Paramater Store w/ hiera-ssm
		- Hashicorp: Consul/Vault? w/ a Hiera backend

* Service Discovery
	- Need a way for instances to find the puppetserver easily in our POC. 
		- AWS Route53 Private Zone
		- AWS Cloud Map
		- NLB In front of Puppet with a Route53 


## Todo 
* Document how a tag gets from Terraform into Hiera
