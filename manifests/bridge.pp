# == Definition: network::bridge
#
# Creates a bridge interface with no IP information.
#
# === Parameters:
#
#   $ensure        - required - up|down
#   $ipaddress     - optional
#   $netmask       - optional
#   $gateway       - optional
#   $ipv6address   - optional
#   $ipv6gateway   - optional
#   $bootproto     - optional - defaults to 'none'
#   $userctl       - optional - defaults to false
#   $stp           - optional - defaults to false
#   $delay         - optional - defaults to 30
#   $bridging_opts - optional
#   $scope         - optional
#   $peerdns       - optional - dedaults to false
#   $ipv6init      - optional - defaults to false
#   $ipv6peerdns   - optional - defaults to false
#   $dns1          - optional
#   $dns2          - optional
#   $domain        - optional
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
  Enum['up', 'down'] $ensure,
  Optional[IP::Address::V4::NoSubnet] $ipaddress = undef,
  Optional[IP::Address::V4::NoSubnet] $netmask = undef,
  Optional[IP::Address::V4::NoSubnet] $gateway = undef,
  Optional[IP::Address::V6] $ipv6address = undef,
  Optional[IP::Address::V6::NoSubnet] $ipv6gateway = undef,
  Network::If::Bootproto $bootproto = 'none',
  Boolean $userctl = false,
  Boolean $stp = false,
  String $delay = '30',
  Optional[String] $bridging_opts = undef,
  Optional[String] $scope = undef,
  Boolean $peerdns = false,
  Boolean $ipv6init = false,
  Boolean $ipv6peerdns = false,
  Optional[IP::Address::NoSubnet] $dns1 = undef,
  Optional[IP::Address::NoSubnet] $dns2 = undef,
  Optional[String] $domain = undef,
  Boolean $restart = true,
) {

  ensure_packages(['bridge-utils'])

  include '::network'

  $interface = $name
  $onboot = $ensure ? {
    'up'    => 'yes',
    'down'  => 'no',
    default => undef,
  }

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

  file { "ifcfg-${interface}":
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/sysconfig/network-scripts/ifcfg-${interface}",
    content => epp("${module_name}/ifcfg-br.epp", {
      interface     => $interface,
      bootproto     => $bootproto,
      onboot        => $onboot,
      ipv6init      => $ipv6init,
      userctl       => $userctl,
      delay         => $delay,
      stp           => $stp,
      bridging_opts => $bridging_opts,
      ipaddress     => $ipaddress,
      netmask       => $netmask,
      gateway       => $gateway,
      ipv6address   => $ipv6address,
      ipv6gateway   => $ipv6gateway,
      scope         => $scope,
      peerdns       => $peerdns,
      ipv6peerdns   => $ipv6peerdns,
      dns1          => $dns1_real,
      dns2          => $dns2_real,
      domain        => $domain,
    }),
    require => Package['bridge-utils'],
  }

  if $restart {
    File["ifcfg-${interface}"] {
      notify  => Service['network'],
    }
  }
} # define network::bridge
