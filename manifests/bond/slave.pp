# Definition: network::bond::slave
#
# Creates a bonded slave interface.
#
# Parameters:
#   $macaddress   - required
#   $master       - required
#   $ethtool_opts - optional
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  # bonded slave interface
#  network::bond::slave { 'eth1':
#    macaddress => $::macaddress_eth1,
#    master     => 'bond0',
#  }
#
define network::bond::slave (
  $macaddress,
  $master,
  $ethtool_opts = ''
) {
  # Validate our data
  if ! is_mac_address($macaddress) {
    fail("${macaddress} is not a MAC address.")
  }

  include 'network'

  $interface = $name

  file { "ifcfg-${interface}":
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/sysconfig/network-scripts/ifcfg-${interface}",
    content => template('network/ifcfg-bond.erb'),
    before  => File["ifcfg-${master}"],
    notify  => Service['network'],
  }
} # define network::bond::slave
