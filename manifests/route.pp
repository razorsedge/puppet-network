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
#   network::route { 'ens192':
#     ipaddress => [
#                   '192.168.2.0/24 via 192.168.1.1',
#                   '10.0.0.0/8 via 10.0.0.1'
#                  ]
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
  Array[String] $ipaddress,
  Optional[Array[String]] $netmask = undef,
  Optional[Array[String]] $gateway = undef,
  Boolean $restart = true,
) {

  include '::network'

  $interface = $name

  if $ipaddress != undef and $netmask != undef and $gateway != undef {
    if length($ipaddress) == length($netmask) and length($netmask) == length($gateway) {
      $template = 'network/route-eth.erb';
    else {
      fail { 'All arrays must be the same length': }
    }
  }
  elsif $netmask == undef and $gateway == undef {
    $template = 'network/route-eth-ip.erb';
  }
  else {
    fail { 'Either use just ipaddress, or use all three array parameters': }
  }

  file { "route-${interface}":
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/sysconfig/network-scripts/route-${interface}",
    content => template($template),
    before  => File["ifcfg-${interface}"],
  }

  if $restart {
    File["route-${interface}"] {
      notify  => Service['network'],
    }
  }
} # define network::route
