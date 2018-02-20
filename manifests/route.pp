# == Definition: network::route
#
# Configures /etc/sysconfig/networking-scripts/route-$name.
#
# === Parameters:
#
#   $ipaddress - required
#   $netmask   - required
#   $gateway   - required
#   $restart   - optional - defaults to true
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/route-$name.
#
# === Requires:
#
#   File["ifcfg-$name"]
#   Service['network']
#
# === Sample Usage:
#
#   network::route { 'eth0':
#     ipaddress => [ '192.168.17.0', ],
#     netmask   => [ '255.255.255.0', ],
#     gateway   => [ '192.168.17.250', ],
#   }
#
#   network::route { 'bond2':
#     ipaddress => [ '192.168.2.0', '10.0.0.0', ],
#     netmask   => [ '255.255.255.0', '255.0.0.0', ],
#     gateway   => [ '192.168.1.1', '10.0.0.1', ],
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
define network::route (
  Array[IP::Address::V4::NoSubnet] $ipaddress,
  Array[IP::Address::V4::NoSubnet] $netmask,
  Array[IP::Address::V4::NoSubnet] $gateway,
  Boolean $restart = true,
) {

  include '::network'

  $interface = $name

  file { "route-${interface}":
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/sysconfig/network-scripts/route-${interface}",
    content => epp("${module_name}/route-eth.epp", {
      ipaddress => $ipaddress,
      netmask   => $netmask,
      gateway   => $gateway,
    }),
    before  => File["ifcfg-${interface}"],
  }

  if $restart {
    File["route-${interface}"] {
      notify  => Service['network'],
    }
  }
} # define network::route
