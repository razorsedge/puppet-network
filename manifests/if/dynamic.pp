# Definition: network::if::dynamic
#
# Creates a normal interface with dynamic IP information.
#
# Parameters:
#   $macaddress   - optional - defaults to macaddress_$title
#   $bootproto    - optional - defaults to "dhcp"
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
#  network::if::dynamic { "eth2":
#    macaddress => $macaddress_eth2,
#    ensure     => "up",
#  }
#
#  # normal interface - bootp (minimal)
#  network::if::dynamic { "eth2":
#    macaddress => "fe:fe:fe:fe:fe:fe",
#    bootproto  => "bootp",
#    ensure     => "up",
#  }
#
define network::if::dynamic (
  $macaddress = "",
  $bootproto = "dhcp",
  $mtu = "",
  $ethtool_opts = "",
  $ensure
) {

  if ! $macaddress {
    $mac = getvar("macaddress_$title")
  } else {
    $mac = $macaddress
  }

  network_if_base { "$title":
    ipaddress    => "",
    netmask      => "",
    gateway      => "",
    macaddress   => $mac,
    bootproto    => $bootproto,
    mtu          => $mtu,
    ethtool_opts => $ethtool_opts,
    bonding_opts => "",
    peerdns      => "",
    ensure       => $ensure,
  }
} # define network::if::dynamic
