# == Definition: network::bridge::dynamic
#
# Creates a bridge interface with dynamic IP information.
#
# === Parameters:
#
#   $ensure       - required - up|down
#   $bootproto    - optional - defaults to "dhcp"
#   $userctl      - optional - defaults to false
#   $mtu          - optional
#   $ethtool_opts - optional
#   $delay        - optional - defaults to 0
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Sample Usage:
#
#   # normal interface - dhcp (minimal)
#   network::bridge::dynamic { 'br0':
#     ensure => 'up',
#   }
#
#   # normal interface - bootp (minimal)
#   network::bridge::dynamic { 'br3':
#     ensure     => 'up',
#     bootproto  => 'dhcp',
#   }
#
# === Authors:
#
# David Cote
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2013 David Cote, unless otherwise noted.
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
#
define network::bridge::dynamic (
  $ensure,
  $userctl = false,
  $bootproto = 'dhcp',
  $onboot = 'yes',
  $peerdns = false,
  $dns1 = '',
  $dns2 = '',
  $domain = '',
  $delay = '0'
) {
  # Validate our regular expressions
  $states = [ '^up$', '^down$' ]
  validate_re($ensure, $states, '$ensure must be either "up" or "down".')
  # Validate booleans
  validate_bool($userctl)

  include 'network'

  $interface = $name

  file { "ifcfg-${interface}":
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/sysconfig/network-scripts/ifcfg-${interface}",
    content => template('network/ifcfg-br.erb'),
    notify  => Service['network'],
  }
} # define network::bridge::dynamic
