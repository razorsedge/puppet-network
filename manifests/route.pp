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
  $ipaddress   = [],
  $netmask     = [],
  $gateway     = [],
  $ipv4_routes = [],
  $ipv6_routes = [],
  $restart     = true,
) {
  # Validate our arrays
  validate_array($ipaddress)
  validate_array($netmask)
  validate_array($gateway)
  validate_array($ipv4_routes)
  validate_array($ipv6_routes)
  # Validate our booleans
  validate_bool($restart)

  include '::network'

  $interface = $name

  if $restart {
    $notify = Service['network']
  } else {
    $notify = undef
  }

  if empty($ipaddress) and (!empty($ipv4_routes) or !empty($ipv6_routes)) {
    if ! empty($ipv4_routes) {
      file { "route-${interface}":
        ensure  => 'present',
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        path    => "/etc/sysconfig/network-scripts/route-${interface}",
        content => template('network/route-eth-v4.erb'),
        before  => File["ifcfg-${interface}"],
        notify  => $notify,
      }
    }
    if ! empty($ipv6_routes) {
      file { "route6-${interface}":
        ensure  => 'present',
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        path    => "/etc/sysconfig/network-scripts/route6-${interface}",
        content => template('network/route-eth-v6.erb'),
        before  => File["ifcfg-${interface}"],
        notify  => $notify,
      }
    }
  } else {
    file { "route-${interface}":
      ensure  => 'present',
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      path    => "/etc/sysconfig/network-scripts/route-${interface}",
      content => template('network/route-eth.erb'),
      before  => File["ifcfg-${interface}"],
      notify  => $notify,
    }
  }
} # define network::route
