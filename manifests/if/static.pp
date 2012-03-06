# Definition: network::if::static
#
# Creates a normal interface with static IP address.
#
# Parameters:
#   $ipaddress    - required
#   $netmask      - required
#   $gateway      - optional
#   $macaddress   - required
#   $mtu          - optional
#   $ethtool_opts - optional
#   $ensure       - required - up|down
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  # normal interface - static (minimal)
#  network::if::static { "eth0":
#    ipaddress  => "10.21.30.248",
#    netmask    => "255.255.255.128",
#    macaddress => $macaddress_eth0,
#    ensure     => "up",
#  }
#
define network::if::static (
  $ipaddress,
  $netmask,
  $gateway = "",
  $macaddress,
  $mtu = "",
  $ethtool_opts = "",
  $ensure
) {
  network::if_base { "$title":
    ipaddress    => $ipaddress,
    netmask      => $netmask,
    gateway      => $gateway,
    macaddress   => $macaddress,
    bootproto    => "none",
    mtu          => $mtu,
    ethtool_opts => $ethtool_opts,
    bonding_opts => "",
    ensure       => $ensure,
  }
} # define network::if::static
