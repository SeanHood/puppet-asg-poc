# Notes

* https://github.com/puppetlabs/best-practices

## Problems to Solve

* Puppetsever certs are stateful:
	- Rsync to s3
	- Mount EFS to store certs
	- Mount s3 for certs

* Service Discovery
	- Need a way for instances to find the puppetserver easily in our POC
