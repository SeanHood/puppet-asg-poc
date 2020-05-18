# Class: profile::appserver
#
class profile::appserver (
  $colour = 'green'
){
  package { 'httpd':
    ensure => 'present'
  }

  file { '/var/www/html/index.html':
    ensure  => 'present',
    content => "<h1>${colour}</h1>"
  }
}
