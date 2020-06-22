# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.box = 'centos/7'
  config.vm.hostname = 'local-node'

  # config.vm.synced_folder "./", "/tmp/puppet"

  config.vm.provider 'virtualbox' do |vb|
    vb.memory = '4096'
  end

  config.vm.provision 'shell', name: 'Install Puppet', inline: <<-SHELL
    puppet --version ||
    (rpm -Uvh https://yum.puppet.com/puppet6-release-el-7.noarch.rpm && \
    yum install puppet-agent -y)
  SHELL

  config.vm.provision 'shell', name: 'Run Puppet', inline: <<-SHELL
    # Need git
    yum install git awscli -y

    # Fetch our
    aws ssm get-parameter --name "/puppet-asg-poc/ssh-key" --output text --query Parameter.Value --with-decryption >> /root/.ssh/id_rsa
    chmod 0600 /root/.ssh/id_rsa

    # Need r10k to pull down the needed modules
    /opt/puppetlabs/puppet/bin/gem install r10k

    # Prepare a dir for out code
    mkdir -p /etc/puppetlabs/code/environments/
    cd /etc/puppetlabs/code/environments/

    # Trust Github.com
    if ! grep github.com /etc/ssh/ssh_known_hosts > /dev/null
    then
      echo "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==" >> /etc/ssh/ssh_known_hosts
    fi

    # Clone into /etc/puppetlabs/code/environments/bootstrap
    git clone ssh://git@github.com/SeanHood/puppet-asg-poc.git bootstrap || true

    # Jump into our dir
    cd /etc/puppetlabs/code/environments/bootstrap

    # Fetch latest
    git pull

    # Install all our puppet modules
    /opt/puppetlabs/puppet/bin/r10k puppetfile install -v

    # Run Puppet!
    puppet apply -e "include role::puppetserver" -v --environment bootstrap
  SHELL
end
