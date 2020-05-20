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
        'basedir' => $::settings::environmentpath,
        'prefix'  => false,
      }
    },
  }

  cron {'r10k':
    command => '/bin/r10k deploy environment -p',
    # user    => 'puppet', # TODO: Need to sort file perms for /etc/puppetlabs
    minute  => '*/15' # Deploy fresh code every 15 minutes
  }

  # TODO: Remove this hack.
  # DNS/LB's/Service discovery add a little much to the PoC for now.
  host {'puppet':
    ip => '127.0.0.1'
  }

  # TODO: Need git deploy key. Need creds to pull the repo.
  # TODO: Webhook?

}
