include network

# aliased interface
network::if::alias { "eth99:1":
  ipaddress => "1.2.3.99",
  netmask   => "255.255.255.0",
 #gateway   => "1.2.3.1",
  ensure    => "up",
}

