# == Definition: network::bond::alias
#
# Creates an alias on a bonded interface with static IP address.
# There is an assumption that an aliased interface will never use DHCP.
#
# === Parameters:
#
#   $ensure    - required - up|down
#   $ipaddress - required
#   $netmask   - required
#   $gateway   - optional
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Sample Usage:
#
#   network::bond::alias { 'bond2:1':
#     ensure    => 'up',
#     ipaddress => '1.2.3.6',
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
define network::bond::alias (
  $ensure,
  $ipaddress,
  $netmask,
  $gateway = ''
) {
  # Validate our data
  if ! is_ip_address($ipaddress) { fail("${ipaddress} is not an IP address.") }

  network_if_base { $title:
    ensure       => $ensure,
    ipaddress    => $ipaddress,
    netmask      => $netmask,
    gateway      => $gateway,
    macaddress   => '',
    bootproto    => 'none',
    mtu          => '',
    ethtool_opts => '',
    isalias      => true,
  }
} # define network::bond::alias
