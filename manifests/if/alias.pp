# Definition: network::if::alias
#
# Creates an alias on a normal interface with static IP address.
# There is an assumption that an aliased interface will never use DHCP.
#
# Parameters:
#   $ensure       - required - up|down
#   $ipaddress    - required
#   $netmask      - required
#   $gateway      - optional
#   $peerdns      - optional
#   $dns1         - optional
#   $dns2         - optional
#   $domain       - optional
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  # aliased interface
#  network::if::alias { 'eth0:1':
#    ensure    => 'up',
#    ipaddress => '1.2.3.5',
#    netmask   => '255.255.255.0',
#  }
#
define network::if::alias (
  $ensure,
  $ipaddress,
  $netmask,
  $gateway = '',
  $peerdns = false,  # TODO: strip this out like in network::bond::alias?
  $dns1 = '',
  $dns2 = '',
  $domain = ''
) {
  # Validate our data
  if ! is_ip_address($ipaddress) { fail("${ipaddress} is not an IP address.") }

  network_if_base { $title:
    ensure       => $ensure,
    ipaddress    => $ipaddress,
    netmask      => $netmask,
    gateway      => $gateway,
    macaddress   => '',
    bootproto    => 'none',
    mtu          => '',
    ethtool_opts => '',
    isalias      => true,
    peerdns      => $peerdns,
    dns1         => $dns1,
    dns2         => $dns2,
    domain       => $domain,
  }
} # define network::if::alias
