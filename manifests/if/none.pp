# == Definition: network::if::none
#
# Creates a normal interface without any ip
#
# === Parameters:
#
#   $ensure       - required - up|down
#   $macaddress   - optional - defaults to macaddress_$title
#   $userctl      - optional - defaults to false
#   $mtu          - optional
#   $ethtool_opts - optional
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Sample Usage:
#
#   network::if::none { 'eth1':
#     ensure      => 'up',
#     macaddress  => $::macaddress_eth0,
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2011 Mike Arnold, unless otherwise noted.
#
define network::if::none (
  Enum['up', 'down'] $ensure,
  Optional[Stdlib::MAC] $macaddress = undef,
  Boolean $userctl = false,
  Optional[String] $mtu = undef,
  Optional[String] $ethtool_opts = undef,
  Optional[String] $linkdelay = undef
) {
  if ! is_mac_address($macaddress) and ($macaddress != 'unmanaged') {
    # Strip off any tailing VLAN (ie eth5.90 -> eth5).
    $title_clean = regsubst($title,'^(\w+)\.\d+$','\1')
    $macaddy = getvar("::macaddress_${title_clean}")
  } elsif $macaddress == 'unmanaged' {
    $macaddy = undef
  } else {
    $macaddy = $macaddress
  }
  # Validate booleans
  validate_bool($userctl)

  network_if_base { $title:
    ensure       => $ensure,
    ipv6init     => false,
    macaddress   => $macaddy,
    bootproto    => 'none',
    userctl      => $userctl,
    mtu          => $mtu,
    ethtool_opts => $ethtool_opts,
    linkdelay    => $linkdelay,
    ipaddress    => undef,
    netmask      => undef,
    gateway      => undef,
  }
} # define network::if::none
