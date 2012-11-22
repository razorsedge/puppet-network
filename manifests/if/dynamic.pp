# Definition: network::if::dynamic
#
# Creates a normal interface with dynamic IP information.
#
# Parameters:
#   $ensure       - required - up|down
#   $macaddress   - optional - defaults to macaddress_$title
#   $bootproto    - optional - defaults to "dhcp"
#   $mtu          - optional
#   $ethtool_opts - optional
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  # normal interface - dhcp (minimal)
#  network::if::dynamic { 'eth2':
#    ensure     => 'up',
#    macaddress => $::macaddress_eth2,
#  }
#
#  # normal interface - bootp (minimal)
#  network::if::dynamic { 'eth2':
#    ensure     => 'up',
#    macaddress => 'fe:fe:fe:fe:fe:fe',
#    bootproto  => 'bootp',
#  }
#
define network::if::dynamic (
  $ensure,
  $macaddress = '',
  $bootproto = 'dhcp',
  $mtu = '',
  $ethtool_opts = ''
) {

  if ! is_mac_address($macaddress) {
    $macaddy = getvar("::macaddress_${title}")
  } else {
    $macaddy = $macaddress
  }

  network_if_base { $title:
    ensure       => $ensure,
    ipaddress    => '',
    netmask      => '',
    gateway      => '',
    macaddress   => $macaddy,
    bootproto    => $bootproto,
    mtu          => $mtu,
    ethtool_opts => $ethtool_opts,
    bonding_opts => '',
  }
} # define network::if::dynamic
