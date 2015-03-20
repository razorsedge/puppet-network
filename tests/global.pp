class { 'network::global':
  gateway        => '1.2.3.1',
  gatewaydev     => 'eth0',
  vlan           => 'yes',
  nozeroconf     => 'yes',
  ipv6networking => true,
  ipv6gateway    => '123:4567:89ab:cdef:123:4567:89ab:1',
  ipv6defaultdev => 'eth1',
}
