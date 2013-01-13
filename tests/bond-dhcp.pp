include network

## bonded interface - dhcp
#network::bond::dynamic { 'bond2':
#  ensure       => 'up',
#  slaves       => [ 'eth4', 'eth7', ],
# #bonding_opts => 'mode=active-backup',
# #mtu          => '1500',
# #ethtool_opts => 'speed 100 duplex full autoneg off',
#}

# bonded master interface - dhcp
network::bond::dynamic { 'bond2':
  ensure       => 'up',
  mtu          => '9000',
  ethtool_opts => 'speed 1000 duplex full autoneg off',
  bonding_opts => 'mode=active-backup arp_interval=60 arp_ip_target=192.168.1.254',
}
