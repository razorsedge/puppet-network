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
#   $restart       - optional - defaults to true
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
  Enum['up', 'down'] $ensure,
  Optional[IP::Address::V4::NoSubnet] $ipaddress = undef,
  Optional[IP::Address::V4::NoSubnet] $netmask = undef,
  Optional[IP::Address::V4::NoSubnet] $gateway = undef,
  Optional[IP::Address::V6] $ipv6address = undef,
  Optional[IP::Address::V6::NoSubnet] $ipv6gateway = undef,
  String $bootproto = 'static',
  Boolean $userctl = false,
  Boolean $peerdns = false,
  Boolean $ipv6init = false,
  Boolean $ipv6peerdns = false,
  Optional[IP::Address::NoSubnet] $dns1 = undef,
  Optional[IP::Address::NoSubnet] $dns2 = undef,
  Optional[String] $domain = undef,
  Boolean $stp = false,
  String $delay = '30',
  Optional[String] $bridging_opts = undef,
  Optional[String] $scope = undef,
  Boolean $restart = true,
) {

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
      notify  => Service['network'],
    }
  }
} # define network::bridge::static
