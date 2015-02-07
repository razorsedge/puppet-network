# == Definition: network::bridge::static
#
# Creates a bridge interface with static IP address.
#
# === Parameters:
#
#   $ensure        - required - up|down
#   $ipaddress     - required
#   $netmask       - required
#   $gateway       - optional
#   $ipv6address   - optional
#   $ipv6gateway   - optional
#   $userctl       - optional - defaults to false
#   $peerdns       - optional
#   $ipv6init      - optional - defaults to false
#   $ipv6peerdns   - optional - defaults to false
#   $dns1          - optional
#   $dns2          - optional
#   $domain        - optional
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
#   network::bridge::static { 'br0':
#     ensure        => 'up',
#     ipaddress     => '10.21.30.248',
#     netmask       => '255.255.255.128',
#     domain        => 'is.domain.com domain.com',
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
define network::bridge::static (
  $ensure,
  $ipaddress,
  $netmask,
  $gateway = '',
  $ipv6address = '',
  $ipv6gateway = '',
  $bootproto = 'static',
  $userctl = false,
  $peerdns = false,
  $ipv6init = false,
  $ipv6peerdns = false,
  $dns1 = '',
  $dns2 = '',
  $domain = '',
  $stp = false,
  $delay = '30',
  $bridging_opts = ''
) {
  # Validate our regular expressions
  $states = [ '^up$', '^down$' ]
  validate_re($ensure, $states, '$ensure must be either "up" or "down".')
  # Validate our data
  if ! is_ip_address($ipaddress) { fail("${ipaddress} is not an IP address.") }
  if $ipv6address != '' {
    if ! is_ip_address($ipv6address) { fail("${ipv6address} is not an IPv6 address.") }
  }
  # Validate booleans
  validate_bool($userctl)
  validate_bool($stp)
  validate_bool($ipv6init)
  validate_bool($ipv6peerdns)

  include 'network'

  $interface = $name

  # Deal with the case where $dns2 is non-empty and $dns1 is empty.
  if $dns2 != '' {
    if $dns1 == '' {
      $dns1_real = $dns2
      $dns2_real = ''
    } else {
      $dns1_real = $dns1
      $dns2_real = $dns2
    }
  } else {
    $dns1_real = $dns1
    $dns2_real = $dns2
  }

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
