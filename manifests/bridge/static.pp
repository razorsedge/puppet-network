# == Definition: network::bridge::static
#
# Creates a bridge interface with static IP address.
#
# === Parameters:
#
#   $ensure        - required - up|down
#   $ipaddress     - optional
#   $netmask       - optional
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
#   $scope         - optional
#   $restart       - optional - defaults to $::network::restart_default (true)
#   $sched         - optional - defaults to $::network::sched_default (undef)
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
  $ipaddress = undef,
  $netmask = undef,
  $gateway = undef,
  $ipv6address = undef,
  $ipv6gateway = undef,
  $bootproto = 'static',
  $userctl = false,
  $peerdns = false,
  $ipv6init = false,
  $ipv6peerdns = false,
  $dns1 = undef,
  $dns2 = undef,
  $domain = undef,
  $stp = false,
  $delay = '30',
  $bridging_opts = undef,
  $scope = undef,
  $restart = $::network::restart_default,
  $sched = $::network::sched_default,
) {
  # Validate our regular expressions
  $states = [ '^up$', '^down$' ]
  validate_re($ensure, $states, '$ensure must be either "up" or "down".')
  # Validate our data
  if $ipaddress {
    if ! is_ip_address($ipaddress) { fail("${ipaddress} is not an IP address.") }
  }
  if $ipv6address {
    if ! is_ip_address($ipv6address) { fail("${ipv6address} is not an IPv6 address.") }
  }
  # Validate booleans
  validate_bool($userctl)
  validate_bool($stp)
  validate_bool($ipv6init)
  validate_bool($ipv6peerdns)
  validate_bool($restart)

  ensure_packages(['bridge-utils'])

  include '::network'

  $interface = $name

  # Deal with the case where $dns2 is non-empty and $dns1 is empty.
  if $dns2 {
    if !$dns1 {
      $dns1_real = $dns2
      $dns2_real = undef
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
    require => Package['bridge-utils'],
  }

  if $restart {
    File["ifcfg-${interface}"] {
      notify   => Service['network'],
      schedule => $sched,
    }
  }
} # define network::bridge::static
