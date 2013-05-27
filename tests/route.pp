include network

# interface routes
network::route { 'eth2':
  ipaddress => [ '192.168.2.0', '10.0.0.0', ],
  netmask   => [ '255.255.255.0', '255.0.0.0', ],
  gateway   => [ '192.168.1.1', '10.0.0.1', ],
}

network::if::dynamic { 'eth2':
  ensure     => 'down',
  macaddress => $::macaddress_eth2,
}
