# == Definition: network::if::dynamic
#
# Creates a normal interface with dynamic IP information.
#
# === Parameters:
#
#   $ensure          - required - up|down
#   $macaddress      - optional - defaults to macaddress_$title
#   $manage_hwaddr   - optional - defaults to true
#   $bootproto       - optional - defaults to "dhcp"
#   $userctl         - optional - defaults to false
#   $mtu             - optional
#   $dhcp_hostname   - optional
#   $ethtool_opts    - optional
#   $peerdns         - optional
#   $linkdelay       - optional
#   $check_link_down - optional
#   $zone            - optional
#   $metric          - optional
#   $defroute        - optional
#   $restart         - optional - defaults to true
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
  Enum['up', 'down'] $ensure,
  Optional[Stdlib::MAC] $macaddress = undef,
  Boolean $manage_hwaddr = true,
  String $bootproto = 'dhcp',
  Boolean $userctl = false,
  Optional[String] $mtu = undef,
  Optional[String] $dhcp_hostname = undef,
  Optional[String] $ethtool_opts = undef,
  Boolean $peerdns = false,
  Optional[String] $linkdelay = undef,
  Boolean $check_link_down = false,
  Optional[String] $defroute = undef,
  Optional[String] $zone = undef,
  Optional[String] $metric = undef,
  Boolean $restart = true,
) {

  if $macaddress {
    $macaddy = $macaddress
  } else {
    # Strip off any tailing VLAN (ie eth5.90 -> eth5).
    $title_clean = regsubst($title,'^(\w+)\.\d+$','\1')
    $macaddy = getvar("::macaddress_${title_clean}")
  }

  network_if_base { $title:
    ensure          => $ensure,
    macaddress      => $macaddy,
    manage_hwaddr   => $manage_hwaddr,
    bootproto       => $bootproto,
    userctl         => $userctl,
    mtu             => $mtu,
    dhcp_hostname   => $dhcp_hostname,
    ethtool_opts    => $ethtool_opts,
    peerdns         => $peerdns,
    linkdelay       => $linkdelay,
    check_link_down => $check_link_down,
    defroute        => $defroute,
    zone            => $zone,
    metric          => $metric,
    restart         => $restart,
  }
} # define network::if::dynamic
