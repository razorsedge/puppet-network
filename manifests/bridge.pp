# == Definition: network::bridge
#
# Creates a bridge interface with no IP information.
#
# === Parameters:
#
#   $ensure        - required - up|down
#   $userctl       - optional - defaults to false
#   $stp           - optional - defaults to false
#   $delay         - optional - defaults to 30
#   $bridging_opts - optional
#   $restart       - optional - defaults to true
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Sample Usage:
#
#   network::bridge { 'br3':
#     ensure        => 'up',
#     stp           => true,
#     delay         => '0',
#     bridging_opts => 'hello_time=200',
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
#
define network::bridge (
  $ensure,
  $userctl = false,
  $stp = false,
  $delay = '30',
  $bridging_opts = undef,
  $ipv6init = false,
  $restart = true,
) {
  # Validate our regular expressions
  $states = [ '^up$', '^down$' ]
  validate_re($ensure, $states, '$ensure must be either "up" or "down".')
  # Validate booleans
  validate_bool($userctl)
  validate_bool($stp)
  validate_bool($ipv6init)
  validate_bool($restart)

  ensure_packages(['bridge-utils'])

  include '::network'

  $interface = $name
  $bootproto = 'none'
  $ipaddress = undef
  $netmask = undef
  $gateway = undef
  $ipv6address = undef
  $ipv6gateway = undef

  $onboot = $ensure ? {
    'up'    => 'yes',
    'down'  => 'no',
    default => undef,
  }

  file { "ifcfg-${interface}":
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/sysconfig/network-scripts/ifcfg-${interface}",
    content => template('network/ifcfg-br.erb'),
    require => Package['bridge-utils'],
  }

  if $restart {
    File["ifcfg-${interface}"] {
      notify  => Service['network'],
    }
  }
} # define network::bridge
