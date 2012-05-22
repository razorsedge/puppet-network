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
#   $peerdns      - optional
#   $dns1         - optional
#   $dns2         - optional
#   $domain       - optional
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
#    domain     => "is.domain.com domain.com",
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
  $peerdns = "",
  $dns1 = "",
  $dns2 = "",
  $domain = "",
  $ensure
) {
  network_if_base { "$title":
    ipaddress    => $ipaddress,
    netmask      => $netmask,
    gateway      => $gateway,
    macaddress   => $macaddress,
    bootproto    => "none",
    mtu          => $mtu,
    ethtool_opts => $ethtool_opts,
    bonding_opts => "",
    peerdns      => $peerdns,
    dns1         => $dns1,
    dns2         => $dns2,
    domain       => $domain,
    ensure       => $ensure,
  }
} # define network::if::static
