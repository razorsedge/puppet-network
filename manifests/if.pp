# == Definition: network::if
#
# Creates a normal interface with no IP information.
#
# === Parameters:
#
#   $ensure        - required - up|down
#   $manage_hwaddr - optional - defaults to true
#   $macaddress    - optional - defaults to macaddress_$title
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
  $ensure,
  $manage_hwaddr = true,
  $macaddress = undef,
  $userctl = false,
  $mtu = undef,
  $ethtool_opts = undef,
  $scope = undef,
  $flush = false,
  $zone = undef,
  $restart = true,
) {
  # Validate our regular expressions
  $states = [ '^up$', '^down$' ]
  validate_re($ensure, $states, '$ensure must be either "up" or "down".')

  if ! is_mac_address($macaddress) {
    # Strip off any tailing VLAN (ie eth5.90 -> eth5).
    $title_clean = regsubst($title,'^(\w+)\.\d+$','\1')
    $macaddy = getvar("::macaddress_${title_clean}")
  } else {
    $macaddy = $macaddress
  }

  # Validate booleans
  validate_bool($userctl)
  validate_bool($manage_hwaddr)
  validate_bool($flush)
  validate_bool($restart)

  network_if_base { $title:
    ensure        => $ensure,
    ipaddress     => '',
    netmask       => '',
    gateway       => '',
    macaddress    => $macaddy,
    manage_hwaddr => $manage_hwaddr,
    bootproto     => 'none',
    ipv6address   => '',
    ipv6gateway   => '',
    userctl       => $userctl,
    mtu           => $mtu,
    ethtool_opts  => $ethtool_opts,
    scope         => $scope,
    flush         => $flush,
    zone          => $zone,
    restart       => $restart,
  }
} # define network::if
