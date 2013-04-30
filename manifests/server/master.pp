# == Class: ldap::master
#
# Puppet module to manage server configuration for
# **OpenLdap**.
#
#
# === Parameters
#
#  [suffix]
#    
#    **Required**
#
#  [rootpw]
#    
#    **Required**
#
#  [rootdn]
#    
#    *Optional* (defaults to 'cn=admin,${suffix}')
#
#  [schema_inc]
#    
#    *Optional* (defaults to [])
#    
#  [modules_inc]
#    
#    *Optional* (defaults to [])
#
#  [index_inc]
#    
#    *Optional* (defaults to [])
#    
#  [log_level]
#    
#    *Optional* (defaults to 0)
#    
#  [bind_anon]
#    
#    *Optional* (defaults to true)
#    
#  [ssl]
#    
#    *Requires*: ssl_{cert,ca,key} parameter
#    *Optional* (defaults to false)
#    
#  [ssl_cert]
#    
#    *Optional* (defaults to false)
#    
#  [ssl_ca]
#    
#    *Optional* (defaults to false)
#    
#  [ssl_key]
#    
#    *Optional* (defaults to false)
#    
#  [syncprov]
#    
#    *Optional* (defaults to false)
#    
#  [syncprov_checkpoint]
#    
#    *Optional* (defaults to '100 10')
#    
#  [syncprov_sessionlog]
#    
#    *Optional* (defaults to *'100'*)
#    
#  [sync_binddn]
#    
#    *Optional* (defaults to *'false'*)
#    
#  [enable_motd]
#    Use motd to report the usage of this module.
#    *Requires*: https://github.com/torian/puppet-motd.git
#    *Optional* (defaults to false)
#    
#  [ensure]
#    *Optional* (defaults to 'present')
#
#
# == Tested/Works on:
#   - Debian: 5.0   / 6.0   /
#   - RHEL    5.2   / 5.4   / 5.5   / 6.1   / 6.2 
#   - OVS:    2.1.1 / 2.1.5 / 2.2.0 / 3.0.2 /
#
#
# === Examples
#
# class { 'ldap::server::master':
#	suffix      => 'dc=foo,dc=bar',
#	rootpw      => '{SHA}iEPX+SQWIR3p67lj/0zigSWTKHg=',
#	syncprov    => true,
#	sync_binddn => 'cn=sync,dc=foo,dc=bar',
#	modules_inc => [ 'syncprov' ],
#	schema_inc  => [ 'gosa/samba3', 'gosa/gosystem' ],
#	index_inc   => [
#		'index memberUid            eq',
#		'index mail                 eq',
#		'index givenName            eq,subinitial',
#		],
#	}
#
# === Authors
#
# Emiliano Castagnari ecastag@gmail.com (a.k.a. Torian)
#
#
# === Copyleft
#
# Copyleft (C) 2012 Emiliano Castagnari ecastag@gmail.com (a.k.a. Torian)
#
#
class ldap::server::master(
  $suffix,
  $rootpw,
  $rootdn              = "cn=admin,${suffix}",
  $schema_inc          = [],
  $modules_inc         = [],
  $index_inc           = [],
  $log_level           = '0',
  $bind_anon           = true,
  $ssl                 = false,
  $ssl_cert            = false,
  $ssl_ca              = false,
  $ssl_key             = false,
  $syncprov            = false,
  $syncprov_checkpoint = '100 10',
  $syncprov_sessionlog = '100',
  $sync_binddn         = false,
  $enable_motd         = false,
  $ensure              = present) {

  include ldap::params
    
  if($enable_motd) { 
    motd::register { 'ldap::server::master': } 
  }
    
  package { $ldap::params::server_package:
    ensure => $ensure
  }

  service { $ldap::params::service:
    ensure     => $ensure ? {
                    present => running,
                    absent  => stopped,
                  },
    enable     => $ensure ? {
                    present => true,
                    absent  => false,
                  },
    name       => $ldap::params::server_script,
    pattern    => $ldap::params::server_pattern,
    hasstatus  => true,
    hasrestart => true,
    require    => [
      Package[$ldap::params::server_package],
      File["${ldap::params::prefix}/${ldap::params::server_config}"],
      ]
  }
    
  file { "${ldap::params::prefix}/${ldap::params::server_config}":
    ensure  => $ensure,
    mode    => 0640,
    owner   => $ldap::params::server_owner,
    group   => $ldap::params::server_group,
    content => template("ldap/${ldap::params::server_config}.erb"),
    notify  => Service[$ldap::params::service],
    require => Package[$ldap::params::server_package],
  }

  #if($ssl == true) {
  #	file { "${ssl_prefix}/${ssl_ca}":
  #		ensure  => $ensure,
  #		mode    => 0640,
  #		owner   => $ldap::params::server_owner,
  #		group   => $ldap::params::server_group,
  #		source  => "puppet://${mod_prefix}"
  #	}
  #}
}

