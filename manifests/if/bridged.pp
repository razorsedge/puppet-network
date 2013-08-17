# == Definition: network::if::static
#
# Creates a bridged interface.
#
# === Parameters:
#
#   $ensure       - required - up|down
#   $bridge       - required - bridge interface name
#   $macaddress   - optional - defaults to macaddress_$title
#   $mtu          - optional
#   $ethtool_opts - optional
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Sample Usage:
#
#   network::if::static { 'eth0':
#     ensure => 'up',
#     bridge => 'br0'
#   }
#
# === Authors:
#
# Alex Barbur <alex@babrur.net>
#
# === Copyright:
#
# Copyright (C) 2013 Alex Barbur, unless otherwise noted.
#
define network::if::bridged (
  $ensure,
  $bridge,
  $macaddress = '',
  $mtu = '',
  $ethtool_opts = '',
) {
  # Validate our data
  if ! is_mac_address($macaddress) {
    $macaddy = getvar("::macaddress_${title}")
  } else {
    $macaddy = $macaddress
  }

  network_if_base { $title:
    ensure       => $ensure,
    ipaddress    => '',
    netmask      => '',
    bridge       => $bridge,
    macaddress   => $macaddy,
    bootproto    => 'none',
    mtu          => $mtu,
    ethtool_opts => $ethtool_opts,
  }
} # define network::if::bridged
