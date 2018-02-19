# == Definition: network::bridge::dynamic
#
# Creates a bridge interface with dynamic IP information.
#
# === Parameters:
#
#   $ensure        - required - up|down
#   $bootproto     - optional - defaults to "dhcp"
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
#   network::bridge::dynamic { 'br1':
#     ensure        => 'up',
#     stp           => true,
#     delay         => '0',
#     bridging_opts => 'priority=65535',
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
  Enum['up', 'down'] $ensure,
  Network::If::Bootproto $bootproto = 'dhcp',
  Boolean $userctl = false,
  Boolean $stp = false,
  String $delay = '30',
  Optional[String] $bridging_opts = undef,
  Boolean $restart = true,
) {

  ensure_packages(['bridge-utils'])

  include '::network'

  $interface = $name
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
} # define network::bridge::dynamic
