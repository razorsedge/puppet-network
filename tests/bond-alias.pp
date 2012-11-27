include network

# aliased bonded interface
network::bond::alias { 'bond2:1':
  ensure    => 'up',
  ipaddress => '1.2.3.6',
  netmask   => '255.255.255.0',
  #gateway   => '1.2.3.1',
}

