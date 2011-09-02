include network

# normal interface - dhcp
network::if::dynamic { "eth99":
  macaddress   => "ff:aa:ff:aa:ff:aa",
  mtu          => "1500",
  ethtool_opts => "speed 100 duplex full autoneg off",
  ensure       => "up",
}

