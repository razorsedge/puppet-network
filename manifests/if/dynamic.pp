# Definition: network::if::dynamic
#
# Creates a normal interface with dynamic IP information.
#
# Parameters:
#   $macaddress   - required
#   $bootproto    - optional - defaults to 'dhcp'
#   $mtu          - optional
#   $ethtool_opts - optional
#   $ensure       - required - up|down
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  # normal interface - dhcp (minimal)
#  network::if::dynamic { 'eth2':
#    macaddress => $macaddress_eth2,
#    ensure     => 'up',
#  }
#
#  # normal interface - bootp (minimal)
#  network::if::dynamic { 'eth2':
#    macaddress => 'fe:fe:fe:fe:fe:fe',
#    bootproto  => 'bootp',
#    ensure     => 'up',
#  }
#
define network::if::dynamic (
  $ensure,
  $macaddress,
  $bootproto = 'dhcp',
  $mtu = '',
  $ethtool_opts = ''
) {
  network::if::base { $title:
    ensure       => $ensure,
    ipaddress    => '',
    netmask      => '',
    gateway      => '',
    macaddress   => $macaddress,
    bootproto    => $bootproto,
    mtu          => $mtu,
    ethtool_opts => $ethtool_opts,
    bonding_opts => '',
  }
} # define network::if::dynamic
