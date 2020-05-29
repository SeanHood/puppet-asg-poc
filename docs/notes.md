# Notes

* https://github.com/puppetlabs/best-practices
* https://www.devopsgroup.com/blog/setting-up-and-using-puppet/
* https://github.com/dogjarek/puppet-hiera/blob/production/nodes/puppetmaster.puppet.aws.yaml
* https://www.1strategy.com/blog/2018/09/18/monitoring-serverless-microservices-2/

## Problems to Solve

* Puppetsever certs are stateful:
	- Rsync to s3
	- Mount EFS to store certs
	- Mount s3 for certs

* Service Discovery
	- Need a way for instances to find the puppetserver easily in our POC

* Document how a tag gets from Terraform into Hiera
