# == Definition: network::route
#
# Configures /etc/sysconfig/networking-scripts/route-$name.
#
# === Parameters:
#
#   $ipaddress - required
#   $netmask   - required
#   $gateway   - required
#   $restart   - optional - defaults to $::network::restart_default (true)
#   $sched     - optional - defaults to $::network::sched_default (undef)
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
  $ipaddress,
  $netmask,
  $gateway,
  $restart = $::network::restart_default,
  $sched   = $::network::sched_default,
) {
  # Validate our arrays
  validate_array($ipaddress)
  validate_array($netmask)
  validate_array($gateway)
  # Validate our booleans
  validate_bool($restart)

  include '::network'

  $interface = $name

  file { "route-${interface}":
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/sysconfig/network-scripts/route-${interface}",
    content => template('network/route-eth.erb'),
    before  => File["ifcfg-${interface}"],
  }

  if $restart {
    File["route-${interface}"] {
      notify   => Service['network'],
      schedule => $sched,
    }
  }
} # define network::route
