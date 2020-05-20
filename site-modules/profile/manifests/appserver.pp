# Class: profile::appserver
#
class profile::appserver (
  $colour = 'green'
){
  package { 'httpd':
    ensure => 'present'
  }

  service { 'httpd':
    ensure => running
  }

  file { '/var/www/html/index.html':
    ensure  => 'present',
    content => "<h1>${colour}</h1>"
  }
}
