TODO
====

1. Change definition network_if_base $ensure to also take "absent" as a
parameter.  This should remove all traces of the ifconfig file from the system
and remove the interface.

        $ensure - required - up|down|absent

2. Consolidate the bonding config master and slave into one definition.

    Examples
    --------

    Bonded interface - static:

        network::bond::static { "bond0":
          ipaddress    => "1.2.3.5",
          netmask      => "255.255.255.0",
          gateway      => "1.2.3.1",
          slaves       => [ "eth0", "eth1", ],
          macaddress   => [ "fe:fe:fe:ae:ae:ae", "ae:ae:ae:fe:fe:fe", ],
          bonding_opts => "mode=active-backup",
          mtu          => "1500",
          ethtool_opts => "speed 100 duplex full autoneg off",
          ensure       => "up",
        }

    Bonded interface - dhcp:

        network::bond::dynamic { "bond2":
          slaves       => [ "eth4", "eth7", ],
          macaddress   => [ $macaddress_eth4, $macaddress_eth7, ],
          bonding_opts => "mode=active-backup",
          mtu          => "1500",
          ethtool_opts => "speed 100 duplex full autoneg off",
          ensure       => "up",
        }

3. Make sure bridge-utils package is installed when using bridging configs.

4. Test out the netcf package.

