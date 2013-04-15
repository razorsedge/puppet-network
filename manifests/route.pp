# Definition: network::route
#
# Configures /etc/sysconfig/networking-scripts/route-$name
#
# Parameters:
#   $address - required
#   $netmask - required
#   $gateway - required
#
# Actions:
#
# Requires:
#   File["ifcfg-$name"]
#
# Sample Usage:
#   # interface routes
#   network::route { 'eth0':
#     address => [ '192.168.2.0', '10.0.0.0', ],
#     netmask => [ '255.255.255.0', '255.0.0.0', ],
#     gateway => [ '192.168.1.1', '10.0.0.1', ],
#   }
#
define network::route (
  $address,
  $netmask,
  $gateway
) {
  include 'network'

  $interface = $name

  file { "route-${interface}":
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/sysconfig/network-scripts/route-${interface}",
    content => template('network/route-eth.erb'),
    before  => File["ifcfg-${interface}"],
    notify  => Service['network'],
  }
} # define network::route
