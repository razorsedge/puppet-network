# Class: network::bond
#
# This module manages bonded network interface configurations.
#
class network::bond {
  # Definition: network::bond::static
  #
  # Creates a bonded interface with static IP address and enables the bonding
  # driver.
  #
  # Parameters:
  #   $ipaddress    - required
  #   $netmask      - required
  #   $gateway      - optional
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
  #  # bonded master interface - static
  #  network::bond::static { "bond0":
  #    ipaddress    => "1.2.3.5",
  #    netmask      => "255.255.255.0",
  #    bonding_opts => "mode=active-backup miimon=100",
  #    ensure       => "up",
  #  }
  #
  define static ( $ipaddress, $netmask, $gateway = "", $mtu = "", $ethtool_opts = "", $bonding_opts = "", $ensure ) {
    network_if_base { "$title":
      ipaddress    => $ipaddress,
      netmask      => $netmask,
      gateway      => $gateway,
      macaddress   => "",
      bootproto    => "none",
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
  } # define network::bond::static

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
  define dynamic ( $mtu = "", $ethtool_opts = "", $bonding_opts = "", $ensure ) {
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

  # Definition: network::bond::alias
  #
  # Creates an alias on a bonded interface with static IP address.
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
  #  # aliased bonded interface
  #  network::bond::alias { "bond2:1":
  #    ipaddress => "1.2.3.6",
  #    netmask   => "255.255.255.0",
  #    ensure    => "up",
  #  }
  #
  define alias ( $ipaddress, $netmask, $gateway = "", $ensure ) {
    network_if_base { "$title":
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
  } # define network::bond::alias

  # Definition: network::bond::slave
  #
  # Creates a bonded slave interface.
  #
  # Parameters:
  #   $macaddress   - required
  #   $master       - required
  #   $ethtool_opts - optional
  #
  # Actions:
  #
  # Requires:
  #
  # Sample Usage:
  #  # bonded slave interface
  #  network::bond::slave { "eth1":
  #    macaddress => $macaddress_eth1,
  #    master     => "bond0",
  #  }
  #
  define slave ( $macaddress, $master, $ethtool_opts = "" ) {
    $interface = $name

    file { "ifcfg-$interface":
      mode    => "644",
      owner   => "root",
      group   => "root",
      ensure  => "present",
      path    => "/etc/sysconfig/network-scripts/ifcfg-$interface",
      content => template("network/ifcfg-bond.erb"),
      before  => File["ifcfg-$master"],
      # need to know $ensure since one of these execs is not defined.
      #notify  => [ Exec["ifup-$master"], Exec["ifdown-$master"], ],
    }
  } # define network::bond::slave

} # class network::bond

