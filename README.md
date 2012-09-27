Puppet Network Module
=====================

Introduction
------------

This module manages Red Hat/Fedora traditional network configuration.

It allows for static, dhcp, and bootp configuration of normal and bonded interfaces.  There is support for aliases on normal and bonded interfaces.  It can configure static routes.  It can configure MTU, ETHTOOL_OPTS, and BONDING_OPTS on a per-interface basis.

It can configure the following files:

* /etc/sysconfig/network
* /etc/sysconfig/networking-scripts/route-*
* /etc/sysconfig/networking-scripts/ifcfg-*

Class and Define documentation is available via puppetdoc.

Examples
--------

Global network settings:

    network::global { "default":
      gateway => "1.2.3.1",
    }

Normal interface - static (minimal):

    network::if::static { "eth0":
      ipaddress  => "1.2.3.248",
      netmask    => "255.255.255.128",
      ensure     => "up",
    }

Normal interface - static:

    network::if::static { "eth1":
      ipaddress    => "1.2.3.4",
      netmask      => "255.255.255.0",
      gateway      => "1.2.3.1",
      macaddress   => "fe:fe:fe:aa:aa:aa",
      mtu          => "9000",
      ethtool_opts => "speed 1000 duplex full autoneg off",
      ensure       => "up",
    }

Normal interface - dhcp (minimal):

    network::if::dynamic { "eth2":
      ensure     => "up",
    }

Normal interface - dhcp:

    network::if::dynamic { "eth3":
      macaddress   => "fe:fe:fe:ae:ae:ae",
      mtu          => "1500",
      ethtool_opts => "speed 100 duplex full autoneg off",
      ensure       => "up",
    }

Normal interface - bootp (minimal):

    network::if::dynamic { "eth2":
      macaddress => "fe:fe:fe:fe:fe:fe",
      bootproto  => "bootp",
      ensure     => "up",
    }

Aliased interface:

    network::if::alias { "eth0:1":
      ipaddress => "1.2.3.5",
      netmask   => "255.255.255.0",
      ensure    => "up",
    }

Bonded master interface - static:

    network::bond::static { "bond0":
      ipaddress    => "1.2.3.5",
      netmask      => "255.255.255.0",
      gateway      => "1.2.3.1",
      mtu          => "9000",
      bonding_opts => "mode=active-backup miimon=100",
      ensure       => "up",
    }

Bonded master interface - dhcp:

    network::bond::dynamic { "bond2":
      mtu          => "8000",
      bonding_opts => "mode=active-backup arp_interval=60 arp_ip_target=192.168.1.254",
      ensure       => "up",
    }

Bonded slave interface:

    network::bond::slave { "eth1":
      macaddress   => $macaddress_eth1,
      ethtool_opts => "speed 1000 duplex full autoneg off",
      master       => "bond0",
    }

Aliased bonded interface:

    network::bond::alias { "bond2:1":
      ipaddress => "1.2.3.6",
      netmask   => "255.255.255.0",
      ensure    => "up",
    }

Static interface routes:

    network::route { "eth0":
      address => [ "192.168.2.0", "10.0.0.0", ],
      netmask => [ "255.255.255.0", "255.0.0.0", ],
      gateway => [ "192.168.1.1", "10.0.0.1", ],
    }

Notes
-----

* Runs under Puppet 2.6 and later.
* Only works with RedHat-ish systems.
* Read /usr/share/doc/initscripts-*/sysconfig.txt for underlying details.
* Read /usr/share/doc/kernel-doc-*/Documentation/networking/bonding.txt for underlying details.
* Only tested on CentOS 5.5.
* There is an assumption that an aliased interface will never use DHCP.
* bootp support is unknown for bonded interfaces. Thus no bootp bond support in this module.
* It is assumed that if you create a bond that you also create the slave interface(s).
* It is assumed that if you create an alias that you also create the parent interface.
* There is currently no IPv6 support in this module.
* network::route requires the referenced device to also be defined via network::if or network::bond.

Issues
------

* Setting ETHTOOL_OPTS, MTU, or BONDING_OPTS and then unsetting will not revert the running config to defaults.
* Changes to /etc/sysconfig/network are global and will result in "service network restart".  This could cause network inaccessability for the host if the network configuration is incorrect.
* Modifying or creating a slave interface after the master has been created will not change the running config.
* There is no support for removing an interface.

TODO
----

* Support /etc/sysconfig/network-scripts/rule-\<interface-name\>
* Support IPv6.
* Support for more than Ethernet links.

Copyright
---------

Copyright (C) 2011 Mike Arnold <mike@razorsedge.org>

