# aliased interface
network::alias { 'eth99:1':
  ensure    => 'up',
  ipaddress => '1.2.3.99',
  netmask   => '255.255.255.0',
}
