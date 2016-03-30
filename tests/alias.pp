# aliased interface
network::alias { 'eth99:1':
  ensure      => 'up',
  ipaddress   => '1.2.3.99',
  netmask     => '255.255.255.0',
  ipv6address => '123:4567:89ab:cdef:123:4567:89ab:cdef/128',
}
