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
#   $restart      - optional - defaults to $::network::restart_default (true)
#   $sched        - optional - defaults to $::network::sched_default (undef)
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
  $ensure,
  $bridge,
  $mtu = undef,
  $ethtool_opts = undef,
  $macaddress = undef,
  $restart = $::network::restart_default,
  $sched = $::network::sched_default,
) {
  # Validate our regular expressions
  $states = [ '^up$', '^down$' ]
  validate_re($ensure, $states, '$ensure must be either "up" or "down".')

  if $macaddress == undef {
    $macaddy = '' # lint:ignore:empty_string_assignment
  }
  else {
    $macaddy = $macaddress
  }

  include '::network'

  network_if_base { $title:
    ensure       => $ensure,
    ipaddress    => '',
    netmask      => '',
    gateway      => '',
    macaddress   => $macaddy,
    bootproto    => 'none',
    ipv6address  => '',
    ipv6gateway  => '',
    mtu          => $mtu,
    ethtool_opts => $ethtool_opts,
    bridge       => $bridge,
    restart      => $restart,
    sched        => $sched,
  }
} # define network::if::bridge
