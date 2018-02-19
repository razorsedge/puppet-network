# == Definition: network::if::bridge
#
# Creates a normal, bridge interface.
#
# === Parameters:
#
#   $ensure       - required - up|down
#   $bridge       - required - bridge interface name
#   $mtu          - optional
#   $ethtool_opts - optional
#   $macaddress   - optional
#   $restart      - optional - defaults to true
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Sample Usage:
#
#   network::if::bridge { 'eth0':
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
define network::if::bridge (
  Enum['up', 'down'] $ensure,
  String $bridge,
  Optional[String] $mtu = undef,
  Optional[String] $ethtool_opts = undef,
  Optional[Stdlib::MAC] $macaddress = undef,
  Boolean $restart = true,
) {

  network_if_base { $title:
    ensure       => $ensure,
    macaddress   => $macaddress,
    bootproto    => 'none',
    mtu          => $mtu,
    ethtool_opts => $ethtool_opts,
    bridge       => $bridge,
    restart      => $restart,
  }
} # define network::if::bridge
