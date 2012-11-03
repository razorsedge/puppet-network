# Definition: network::if::alias
#
# Creates an alias on a normal interface with static IP address.
# There is an assumption that an aliased interface will never use DHCP.
#
# Parameters:
#   $ipaddress    - required
#   $netmask      - required
#   $gateway      - optional
#   $peerdns      - optional
#   $dns1         - optional
#   $dns2         - optional
#   $ensure       - required - up|down
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  # aliased interface
#  network::if::alias { 'eth0:1':
#    ipaddress => '1.2.3.5',
#    netmask   => '255.255.255.0',
#    ensure    => 'up',
#  }
#
define network::if::alias (
  $ensure,
  $ipaddress,
  $netmask,
  $gateway = '',
  $peerdns = '',
  $dns1    = '',
  $dns2    = ''
) {
  network::if::base { $title:
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
    peerdns      => $peerdns,
    dns1         => $dns1,
    dns2         => $dns2,
  }
} # define network::if::alias
