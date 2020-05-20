# SSH Deploy Key Steps

We need an SSH key on the puppet server to fetch our repo's from Github.com. We can use AWS System Manager Parameter Store for this.
We can also set an IAM policy which allows the machine to fetch the secret in the bootstrapping script

1. Create an ssh key (I put this into ssh-key/puppet-deploykey)
```
ssh-keygen
```

1. Push this key into AWS SSM
```
aws ssm put-parameter --name "/puppet-asg-poc/ssh-key" --value "$(cat ssh-key/puppet-deploykey)" --type SecureString
```

3. Retriving the key from AWS SSM
```
aws ssm get-parameter --name "/puppet-asg-poc/ssh-key" --output text --query Parameter.Value --with-decryption
```
