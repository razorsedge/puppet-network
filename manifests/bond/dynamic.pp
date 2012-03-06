# Definition: network::bond::dynamic
#
# Creates a bonded interface with static IP address and enables the bonding
# driver.  bootp support is unknown for bonded interfaces.  Thus no bootp
# bond support in this module.
#
# Parameters:
#   $mtu          - optional
#   $ethtool_opts - optional
#   $bonding_opts - optional
#   $ensure       - required - up|down
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  # bonded master interface - dhcp
#  network::bond::dynamic { "bond2":
#    ensure => "up",
#  }
#
define network::bond::dynamic (
  $mtu = "",
  $ethtool_opts = "",
  $bonding_opts = "",
  $ensure
) {
  network_if_base { "$title":
    ipaddress    => "",
    netmask      => "",
    gateway      => "",
    macaddress   => "",
    bootproto    => "dhcp",
    mtu          => $mtu,
    ethtool_opts => $ethtool_opts,
    bonding_opts => $bonding_opts,
    ensure       => $ensure,
  }

  augeas { "modprobe.conf_$title":
    context => "/files/etc/modprobe.conf",
    changes => [ "set alias[last()+1] $title", "set alias[last()]/modulename bonding", ],
    onlyif  => "match alias[*][. = '$title'] size == 0",
   #onlyif  => "match */modulename[. = 'bonding'] size == 0",
    before  => $ensure ? {
      up   => Exec["ifup-$title"],
      down => Exec["ifdown-$title"],
    }
  }
} # define network::bond::dynamic
