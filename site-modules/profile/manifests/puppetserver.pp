# Class: profile::puppetserver
#
#
class profile::puppetserver {
  # resources
  class { 'puppetserver::repository': }
  -> class { 'puppetserver': }

  # This is a demo, let's keep things small
  puppetserver::config::java_arg { '-Xms':
    value   => '512m',
  }
  puppetserver::config::java_arg { '-Xmx':
    value   => '512m',
  }


  # Puppetserver wouldn't function without r10k so it's in this profile, rather than it's own
  class { 'r10k':
    sources => {
      'puppet' => {
        'remote'  => 'ssh://git@github.com/SeanHood/puppet-asg-poc.git',
        'basedir' => "${::settings::confdir}/environments",
        'prefix'  => false,
      }
    },
  }

  # TODO: Need git deploy key. Need creds to pull the repo.
  # TODO: Webhook?

}
