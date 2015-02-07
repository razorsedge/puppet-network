include network

# normal interface - static
network::if::static { 'eth1':
  ensure       => 'up',
  ipaddress    => '1.2.3.4',
  netmask      => '255.255.255.0',
  gateway      => '1.2.3.1',
  macaddress   => 'fe:fe:fe:aa:aa:aa',
  ipv6init     => true,
  ipv6address  => '2002:b2c8:ad63:0:a6db:30ff:fe39:4a6/64',
  ipv6gateway  => '2002:b2c8:ad63:0:a6db:30ff:fe39:1',
  mtu          => '9000',
  ethtool_opts => 'speed 1000 duplex full autoneg off',
}
