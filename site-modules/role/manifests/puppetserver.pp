# Class: role::puppetserver
#
#
class role::puppetserver {
  # resources

  include profile::puppetserver
  # For the puppet master roll we need:
  # TODO: profile::r10k

  # Stretch Goals:
  # puppetdb and puppetboard but these may end up in their own role, you'd tend
  # to not have these on the same server as the puppet master
  # skx/puppet-summary might be a quick alternative to show the status of things
}
