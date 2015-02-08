# == Definition: network::if::static
#
# Creates a normal interface with static IP address.
#
# === Parameters:
#
#   $ensure       - required - up|down
#   $ipaddress    - required
#   $netmask      - required
#   $gateway      - optional
#   $ipv6address  - optional
#   $ipv6init     - optional - defaults to false
#   $ipv6gateway  - optional
#   $macaddress   - optional - defaults to macaddress_$title
#   $ipv6autoconf - optional - defaults to false
#   $userctl      - optional - defaults to false
#   $mtu          - optional
#   $ethtool_opts - optional
#   $peerdns      - optional
#   $ipv6peerdns  - optional - defaults to false
#   $dns1         - optional
#   $dns2         - optional
#   $domain       - optional
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Sample Usage:
#
#   network::if::static { 'eth0':
#     ensure      => 'up',
#     ipaddress   => '10.21.30.248',
#     netmask     => '255.255.255.128',
#     macaddress  => $::macaddress_eth0,
#     domain      => 'is.domain.com domain.com',
#     ipv6init    => true,
#     ipv6address => '123:4567:89ab:cdef:123:4567:89ab:cdef'
#     ipv6gateway => '123:4567:89ab:cdef:123:4567:89ab:1' 
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
define network::if::static (
  $ensure,
  $ipaddress,
  $netmask,
  $gateway = '',
  $ipv6address = '',
  $ipv6init = false,
  $ipv6gateway = '',
  $macaddress = '',
  $ipv6autoconf = false,
  $userctl = false,
  $mtu = '',
  $ethtool_opts = '',
  $peerdns = false,
  $ipv6peerdns = false,
  $dns1 = '',
  $dns2 = '',
  $domain = '',
  $linkdelay = ''
) {
  # Validate our data
  if ! is_ip_address($ipaddress) { fail("${ipaddress} is not an IP address.") }
  if $ipv6address != '' {
    if ! is_ip_address($ipv6address) { fail("${ipv6address} is not an IPv6 address.") }
  }

  if ! is_mac_address($macaddress) {
    # Strip off any tailing VLAN (ie eth5.90 -> eth5).
    $title_clean = regsubst($title,'^(\w+)\.\d+$','\1')
    $macaddy = getvar("::macaddress_${title_clean}")
  } else {
    $macaddy = $macaddress
  }
  # Validate booleans
  validate_bool($userctl)
  validate_bool($ipv6init)
  validate_bool($ipv6autoconf)
  validate_bool($peerdns)
  validate_bool($ipv6peerdns)

  network_if_base { $title:
    ensure       => $ensure,
    ipv6init     => $ipv6init,
    ipaddress    => $ipaddress,
    ipv6address  => $ipv6address,
    netmask      => $netmask,
    gateway      => $gateway,
    ipv6gateway  => $ipv6gateway,
    ipv6autoconf => $ipv6autoconf,
    macaddress   => $macaddy,
    bootproto    => 'none',
    userctl      => $userctl,
    mtu          => $mtu,
    ethtool_opts => $ethtool_opts,
    peerdns      => $peerdns,
    ipv6peerdns  => $ipv6peerdns,
    dns1         => $dns1,
    dns2         => $dns2,
    domain       => $domain,
    linkdelay    => $linkdelay,
  }
} # define network::if::static
