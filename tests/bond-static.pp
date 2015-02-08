include network

## bonded interface - static
#network::bond::static { 'bond0':
#  ensure       => 'up',
#  ipaddress    => '1.2.3.5',
#  netmask      => '255.255.255.0',
#  gateway      => '1.2.3.1',
#  slaves       => [ 'eth1', 'eth2', ],
#  bonding_opts => 'mode=active-backup',
#  mtu          => '8000',
#  ethtool_opts => 'speed 100 duplex full autoneg off',
#}

# bonded master interface - static
network::bond::static { 'bond0':
  ensure       => 'up',
  ipaddress    => '1.2.3.5',
  netmask      => '255.255.255.0',
  gateway      => '1.2.3.1',
  ipv6init     => true,
  ipv6address  => '123:4567:89ab:cdef:123:4567:89ab:cdef/64',
  ipv6gateway  => '123:4567:89ab:cdef:123:4567:89ab:1',
  mtu          => '9000',
  bonding_opts => 'mode=active-backup miimon=100',
}

# bonded slave interface - static
network::bond::slave { 'eth1':
  macaddress   => $::macaddress_eth1,
  ethtool_opts => 'speed 1000 duplex full autoneg off',
  master       => 'bond0',
}

# bonded slave interface - static
network::bond::slave { 'eth3':
  macaddress   => $::macaddress_eth3,
  ethtool_opts => 'speed 100 duplex half autoneg off',
  master       => 'bond0',
}
