class { 'network::global':
  gateway    => '1.2.3.1',
  gatewaydev => 'eth0',
  vlan       => 'yes',
  nozeroconf => 'yes',
}
