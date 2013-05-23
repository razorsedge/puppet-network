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
  $ethtool_opts = '',
) {

  # Validate our regular expressions
  $states = [ '^up$', '^down$' ]
  validate_re($ensure, $states, '$ensure must be either "up" or "down".')

  if ! is_mac_address($macaddress) {
    $macaddy = getvar("::macaddress_${title}")
  } else {
    $macaddy = $macaddress
  }

  network::if::base { $title:
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
}
