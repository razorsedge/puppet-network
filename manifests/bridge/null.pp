# == Definition: network::bridge::null
#
# Creates a bridge interface with no IP address.
#
# === Parameters:
#
#   $ensure        - required - up|down
#   $userctl       - optional - defaults to false
#   $stp           - optional - defaults to false
#   $delay         - optional - defaults to 30
#   $bridging_opts - optional
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Sample Usage:
#
#   network::bridge::null { 'br0':
#     ensure        => 'up',
#     stp           => true,
#     delay         => '0',
#     bridging_opts => 'priority=65535',
#   }
#
# === Authors:
# David Gibbons <dgibbons@peakhosting.com>
# David Cote
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2013 David Cote, unless otherwise noted.
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
#
define network::bridge::null (
  $ensure,
  $bootproto = 'none',
  $userctl = false,
  $stp = false,
  $delay = '30',
  $bridging_opts = ''
) {
  # Validate our regular expressions
  $states = [ '^up$', '^down$' ]
  validate_re($ensure, $states, '$ensure must be either "up" or "down".')
  # Validate booleans
  validate_bool($userctl)
  validate_bool($stp)

  include 'network'
  $ipaddress = ''
  $netmask = ''
  $gateway = ''
  $dns1_real = ''
  $dns2_real = ''
  $domain = ''
  $interface = $name

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
    notify  => Service['network'],
  }
} # define network::bridge::static
