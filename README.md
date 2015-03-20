Puppet Network Module
=====================

master branch [![Build Status](https://secure.travis-ci.org/razorsedge/puppet-network.png?branch=master)](http://travis-ci.org/razorsedge/puppet-network)
develop branch [![Build Status](https://secure.travis-ci.org/razorsedge/puppet-network.png?branch=develop)](http://travis-ci.org/razorsedge/puppet-network)

Introduction
------------

This module manages Red Hat/Fedora traditional network configuration.

It allows for static, dhcp, and bootp configuration of normal and bonded interfaces as well as bridges and VLANs.  There is support for aliases on interfaces as well as alias ranges.  It can configure static routes.  It can configure MTU, DHCP_HOSTNAME, ETHTOOL_OPTS, and BONDING_OPTS on a per-interface basis.

It can configure the following files:

* /etc/sysconfig/network
* /etc/sysconfig/networking-scripts/route-*
* /etc/sysconfig/networking-scripts/ifcfg-*

Class and Define documentation is available via puppetdoc.

Examples
--------

Please note that the following examples do not depict all of the parameters supported by each class or define.

Global network settings:

    class { 'network::global':
      gateway => '1.2.3.1',
    }

Global network setting (IPv6 enabled):

    class { 'network::global':
      ipv6gateway    => '123:4567:89ab:cdef:123:4567:89ab:1',
      ipv6networking => true,
    }

Global network setting with IPv6 enabled with optional default device for IPv6 traffic:

    class { 'network::global':
      ipv6gateway    => '123:4567:89ab:cdef:123:4567:89ab:1',
      ipv6networking => true,
      ipv6defaultdev => 'eth1',
    }


Normal interface - static (minimal):

    network::if::static { 'eth0':
      ensure    => 'up',
      ipaddress => '1.2.3.248',
      netmask   => '255.255.255.128',
    }

Normal interface - static:

    network::if::static { 'eth1':
      ensure       => 'up',
      ipaddress    => '1.2.3.4',
      netmask      => '255.255.255.0',
      gateway      => '1.2.3.1',
      macaddress   => 'fe:fe:fe:aa:aa:aa',
      ipv6init     => true,
      ipv6address  => '123:4567:89ab:cdef:123:4567:89ab:cdef/64',
      ipv6gateway  => '123:4567:89ab:cdef:123:4567:89ab:1',
      mtu          => '9000',
      ethtool_opts => 'autoneg off speed 1000 duplex full',
    }

Normal interface - dhcp (minimal):

    network::if::dynamic { 'eth2':
      ensure => 'up',
    }

Normal interface - dhcp:

    network::if::dynamic { 'eth3':
      ensure        => 'up',
      macaddress    => 'fe:fe:fe:ae:ae:ae',
      mtu           => '1500',
      dhcp_hostname => $::hostname,
      ethtool_opts  => 'autoneg off speed 100 duplex full',
    }

Normal interface - bootp (minimal):

    network::if::dynamic { 'eth2':
      ensure     => 'up',
      macaddress => 'fe:fe:fe:fe:fe:fe',
      bootproto  => 'bootp',
    }

Normal interface - bridged (the corresponding network::bridge::* may also have to be defined):

    network::if::bridge { 'eth0':
      ensure => 'up',
      bridge => 'br0'
    }

Aliased interface:

    network::alias { 'eth0:1':
      ensure    => 'up',
      ipaddress => '1.2.3.5',
      netmask   => '255.255.255.0',
    }

Aliased interface (allow non-root user to manage):

    network::alias { 'em2:1':
      ensure    => 'up',
      ipaddress => '10.22.33.45',
      netmask   => '255.255.254.0',
      userctl   => true,
    }

Aliased interface (range):

    network::alias::range { 'eth1':
      ensure          => 'up',
      ipaddress_start => '1.2.3.5',
      ipaddress_end   => '1.2.3.20',
      clonenum_start  => '0',
      noaliasrouting  => true,
    }

Bonded master interface - static:

    network::bond::static { 'bond0':
      ensure       => 'up',
      ipaddress    => '1.2.3.5',
      netmask      => '255.255.255.0',
      gateway      => '1.2.3.1',
      ipv6init     => true,
      ipv6address  => '123:4567:89ab:cdef:123:4567:89ab:cdef',
      ipv6gateway  => '123:4567:89ab:cdef:123:4567:89ab:1',
      mtu          => '9000',
      bonding_opts => 'mode=active-backup miimon=100',
    }

Bonded master interface - dhcp:

    network::bond::dynamic { 'bond2':
      ensure       => 'up',
      mtu          => '8000',
      bonding_opts => 'mode=active-backup arp_interval=60 arp_ip_target=192.168.1.254',
    }

Bonded master interface - bridged (the corresponding network::bridge::* may also have to be defined):

    network::bond::bridge { 'bond2':
      ensure       => 'up',
      bridge       => 'br3',
      bonding_opts => 'mode=802.3ad lacp_rate=fast miimon=100',
    }

Bonded slave interface:

    network::bond::slave { 'eth1':
      macaddress   => $macaddress_eth1,
      ethtool_opts => 'autoneg off speed 1000 duplex full',
      master       => 'bond0',
    }

Bridge interface - no IP:

    network::bridge { 'br0':
      ensure        => 'up',
      stp           => true,
      delay         => '0',
      bridging_opts => 'priority=65535',
    }

Bridge interface - static (minimal):

    network::bridge::static { 'br1':
      ensure    => 'up',
      ipaddress => '10.21.30.248',
      netmask   => '255.255.255.128',
    }

Bridge interface - static:

    network::bridge::static { 'br2':
      ensure        => 'up',
      ipaddress     => '1.2.3.8',
      netmask       => '255.255.0.0',
      stp           => true,
      delay         => '0',
      ipv6init      => true,
      ipv6address   => '123:4567:89ab:cdef:123:4567:89ab:cdef',
      ipv6gateway   => '123:4567:89ab:cdef:123:4567:89ab:1',
      bridging_opts => 'priority=65535',
    }

Bridge interface - dhcp (minimal):

    network::bridge::dynamic { 'br3':
      ensure => 'up',
    }

Static interface routes:

    network::route { 'eth0':
      ipaddress => [ '192.168.2.0', '10.0.0.0', ],
      netmask   => [ '255.255.255.0', '255.0.0.0', ],
      gateway   => [ '192.168.1.1', '10.0.0.1', ],
    }

Normal interface - VLAN - static (minimal):

    class { 'network::global':
      vlan => 'yes',
    }

    network::if::static { 'eth0.330':
      ensure    => 'up',
      ipaddress => '10.2.3.248',
      netmask   => '255.255.255.0',
    }

Notes
-----

* Runs under Puppet 2.7 and later.
* Only works with RedHat-ish systems.
* Read /usr/share/doc/initscripts-*/sysconfig.txt for underlying details.
* Read /usr/share/doc/kernel-doc-*/Documentation/networking/bonding.txt for underlying details.
* Read /etc/sysconfig/network-scripts/ifup-aliases for underlying details.
* Only tested on CentOS 5.5 and CentOS 6.3.
* There is an assumption that an aliased interface will never use DHCP.
* bootp support is unknown for bonded interfaces. Thus no bootp bond support in this module.
* It is assumed that if you create a bond that you also create the slave interface(s).
* It is assumed that if you create an alias that you also create the parent interface.
* There is currently no IPv6 support in this module.
* network::route requires the referenced device to also be defined via network::if or network::bond.
* For VLANs to work, `Class['network::global']` must have parameter `vlan` set to `yes`.
* To enable IPv6 you have to set both `ipv6networking` in `Class['network::global']` to `true` and `ipv6init` in `network::if::static` to `true`.

Issues
------

* Setting ETHTOOL_OPTS, MTU, or BONDING_OPTS and then unsetting will not revert the running config to defaults.
* Changes to any configuration will result in "service network restart".  This could cause network inaccessability for the host if the network configuration is incorrect.
* Modifying or creating a slave interface after the master has been created will not change the running config.
* There is presently no support for removing an interface.

TODO
----

* Support /etc/sysconfig/network-scripts/rule-\<interface-name\>
* Expand support for IPv6.
* Support for more than Ethernet links.
* Testing of VLAN support (it should Just Work(TM)).

See TODO.md for more items.

Deprecation Warning
-------------------

The define `network::global` will be replaced by a paramterized class in version 3.0.0 of this module.  Please be aware that your manifests may need to change to account for the new syntax.

This:

    network::global { 'default':
      # blah
    }

would become this:

    class { 'network::global':
      # blah
    }

The define `network::if::alias` and `network::bond::alias` will be merged into `network::alias` in version 3.0.0 of this module.  Please be aware that your manifests may need to change to account for the new syntax.

This:

    network::if::alias { 'eth0:1':
      # blah
    }

would become this:

    network::alias { 'eth0:1':
      # blah
    }

The define `network::route` will have parameter `address` renamed to `ipaddress` in version 3.0.0 of this module.  This is for the purpose of consistency with all the other defines in the `network` class.  Please be aware that your manifests may need to change to account for the new syntax.

This:

    network::route { 'eth0':
      address => '192.168.17.0',
      # blah
    }

would become this:

    network::route { 'eth0':
      ipaddress => '192.168.17.0',
      # blah
    }

Contributing
------------

Please see DEVELOP.md for contribution information.

License
-------

Please see LICENSE file.

Copyright
---------

Copyright (C) 2011 Mike Arnold <mike@razorsedge.org>

[razorsedge/puppet-network on GitHub](https://github.com/razorsedge/puppet-network)

[razorsedge/network on Puppet Forge](http://forge.puppetlabs.com/razorsedge/network)

