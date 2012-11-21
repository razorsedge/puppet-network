# Definition: network::bond::alias
#
# Creates an alias on a bonded interface with static IP address.
# There is an assumption that an aliased interface will never use DHCP.
#
# Parameters:
#   $ensure       - required - up|down
#   $ipaddress    - required
#   $netmask      - required
#   $gateway      - optional
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  # aliased bonded interface
#  network::bond::alias { 'bond2:1':
#    ensure    => 'up',
#    ipaddress => '1.2.3.6',
#    netmask   => '255.255.255.0',
#  }
#
define network::bond::alias (
  $ensure,
  $ipaddress,
  $netmask,
  $gateway = ''
) {
  network_if_base { $title:
    ensure       => $ensure,
    ipaddress    => $ipaddress,
    netmask      => $netmask,
    gateway      => $gateway,
    macaddress   => '',
    bootproto    => 'none',
    mtu          => '',
    ethtool_opts => '',
    bonding_opts => '',
    isalias      => true,
  }
} # define network::bond::alias
