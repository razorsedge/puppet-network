# == Definition: network::if::dynamic
#
# Creates a normal interface with dynamic IP information.
#
# === Parameters:
#
#   $ensure       - required - up|down
#   $macaddress   - optional - defaults to macaddress_$title
#   $bootproto    - optional - defaults to "dhcp"
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
#   network::if::dynamic { 'eth2':
#     ensure     => 'up',
#     macaddress => $::macaddress_eth2,
#   }
#
#   network::if::dynamic { 'eth3':
#     ensure     => 'up',
#     macaddress => 'fe:fe:fe:fe:fe:fe',
#     bootproto  => 'bootp',
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
define network::if::dynamic (
  $ensure,
  $macaddress = '',
  $bootproto = 'dhcp',
  $userctl = false,
  $mtu = '',
  $ethtool_opts = ''
) {
  # Validate our regular expressions
  $states = [ '^up$', '^down$' ]
  validate_re($ensure, $states, '$ensure must be either "up" or "down".')

  if ! is_mac_address($macaddress) {
    $macaddy = getvar("::macaddress_${title}")
  } else {
    $macaddy = $macaddress
  }
  # Validate booleans
  validate_bool($userctl)

  network_if_base { $title:
    ensure       => $ensure,
    ipaddress    => '',
    netmask      => '',
    gateway      => '',
    macaddress   => $macaddy,
    bootproto    => $bootproto,
    userctl      => $userctl,
    mtu          => $mtu,
    ethtool_opts => $ethtool_opts,
  }
} # define network::if::dynamic
