# Puppet & AWS AutoScalingGroup Proof of concept

This repo is a proof of concept on knitting together the following technologies, which intends see "services", rather than "servers", in an automated fashion. 

* Puppet 6 & Hiera 5
* Puppet control-repo w/ roles & profiles
* puppetlabs/r10k
* AWS AutoScaling Groups
* Terraform (0.12.x)

## Deployment Procedure

1. Create an ssh key pair for puppet to access Github, see ssh-key.md

1. Ensure you have aws creds in your `~/.aws/credentials` file. We'll be using the `default` credentials

1. Deploy puppet server
    1. `cd terraform/05-puppetserver`
    2. `terraform plan`
    3. `terraform apply`

1. Deploy the sample app
    1. `cd terraform/10-appserver`
    2. `terraform plan`
    3. `terraform apply`


## Credits

* govuk/aws
* govuk/puppet
* puppetlabs/control-repo