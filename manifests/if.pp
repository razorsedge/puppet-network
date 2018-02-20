# == Definition: network::if
#
# Creates a normal interface with no IP information.
#
# === Parameters:
#
#   $ensure        - required - up|down
#   $manage_hwaddr - optional - defaults to true
#   $macaddress    - optional - defaults to $::networking['interfaces'][$title]['mac']
#   $userctl       - optional - defaults to false
#   $mtu           - optional
#   $ethtool_opts  - optional
#   $scope         - optional
#   $flush         - optional - defaults to false
#   $zone          - optional
#   $restart       - optional - defaults to true
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Sample Usage:
#
#   network::if { 'eth2':
#     ensure => 'up',
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2017 Mike Arnold, unless otherwise noted.
#
define network::if (
  Enum['up', 'down'] $ensure,
  Boolean $manage_hwaddr = true,
  Optional[Stdlib::MAC] $macaddress = undef,
  Boolean $userctl = false,
  Variant[Integer, String, Undef] $mtu = undef,
  Optional[String] $ethtool_opts = undef,
  Optional[String] $scope = undef,
  Boolean $flush = false,
  Optional[String] $zone = undef,
  Boolean $restart = true,
) {

  if $macaddress {
    $macaddy = $macaddress
  } else {
    # Strip off any tailing VLAN (ie eth5.90 -> eth5).
    $title_clean = regsubst($title,'^(\w+)\.\d+$','\1')
    $macaddy = $::networking['interfaces'][$title_clean]['mac']
  }

  network_if_base { $title:
    ensure        => $ensure,
    macaddress    => $macaddy,
    manage_hwaddr => $manage_hwaddr,
    bootproto     => 'none',
    userctl       => $userctl,
    mtu           => $mtu,
    ethtool_opts  => $ethtool_opts,
    scope         => $scope,
    flush         => $flush,
    zone          => $zone,
    restart       => $restart,
  }
} # define network::if
