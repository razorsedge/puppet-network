# Class: network::if
#
# This module manages normal network interface configuration.
#
class network::if {
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
  define network::if::static ( $ipaddress, $netmask, $gateway = "", $macaddress, $mtu = "", $ethtool_opts = "", $ensure ) {
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

  # Definition: network::if::dynamic
  #
  # Creates a normal interface with dynamic IP information.
  #
  # Parameters:
  #   $macaddress   - required
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
  define network::if::dynamic ( $macaddress, $bootproto = "dhcp", $mtu = "", $ethtool_opts = "", $ensure ) {
    network::if_base { "$title":
      ipaddress    => "",
      netmask      => "",
      gateway      => "",
      macaddress   => $macaddress,
      bootproto    => $bootproto,
      mtu          => $mtu,
      ethtool_opts => $ethtool_opts,
      bonding_opts => "",
      ensure       => $ensure,
    }
  } # define network::if::dynamic

  # Definition: network::if::alias
  #
  # Creates an alias on a normal interface with static IP address.
  # There is an assumption that an aliased interface will never use DHCP.
  #
  # Parameters:
  #   $ipaddress    - required
  #   $netmask      - required
  #   $gateway      - optional
  #   $ensure       - required - up|down
  #
  # Actions:
  #
  # Requires:
  #
  # Sample Usage:
  #  # aliased interface
  #  network::if::alias { "eth0:1":
  #    ipaddress => "1.2.3.5",
  #    netmask   => "255.255.255.0",
  #    ensure    => "up",
  #  }
  #
  define network::if::alias ( $ipaddress, $netmask, $gateway = "", $ensure ) {
    network::if_base { "$title":
      ipaddress    => $ipaddress,
      netmask      => $netmask,
      gateway      => $gateway,
      macaddress   => "",
      bootproto    => "none",
      mtu          => "",
      ethtool_opts => "",
      bonding_opts => "",
      isalias      => true,
      ensure       => $ensure,
    }
  } # define network::if::alias

} # class network::if

