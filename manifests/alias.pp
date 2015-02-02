# == Definition: network::alias
#
# Creates an alias on an interface with a static IP address.
# There is an assumption that an aliased interface will never use DHCP.
#
# === Parameters:
#
#   $ensure    - required - up|down
#   $ipaddress - required
#   $netmask   - required
#   $gateway   - optional
#   $userctl   - optional - defaults to false
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Sample Usage:
#
#   network::alias { 'eth0:1':
#     ensure    => 'up',
#     ipaddress => '1.2.3.5',
#     netmask   => '255.255.255.0',
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
define network::alias (
  $ensure,
  $ipaddress,
  $netmask,
  $gateway = '',
  $ipv6address = '',
  $ipv6gateway = '',
  $userctl = false
) {
  # Validate our data
  if ! is_ip_address($ipaddress) { fail("${ipaddress} is not an IP address.") }
  # Validate our booleans
  validate_bool($userctl)

  network_if_base { $title:
    ensure       => $ensure,
    ipaddress    => $ipaddress,
    netmask      => $netmask,
    gateway      => $gateway,
    ipv6address  => $ipv6address,
    ipv6gateway  => $ipv6gateway,
    macaddress   => '',
    bootproto    => 'none',
    userctl      => $userctl,
    mtu          => '',
    ethtool_opts => '',
    isalias      => true
  }
} # define network::alias
