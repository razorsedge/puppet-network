# Definition: network::bond::static
#
# Creates a bonded interface with static IP address and enables the bonding
# driver.
#
# Parameters:
#   $ensure       - required - up|down
#   $ipaddress    - required
#   $netmask      - required
#   $gateway      - optional
#   $mtu          - optional
#   $ethtool_opts - optional
#   $bonding_opts - optional
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  # bonded master interface - static
#  network::bond::static { 'bond0':
#    ensure       => 'up',
#    ipaddress    => '1.2.3.5',
#    netmask      => '255.255.255.0',
#    bonding_opts => 'mode=active-backup miimon=100',
#  }
#
define network::bond::static (
  $ensure,
  $ipaddress,
  $netmask,
  $gateway = '',
  $mtu = '',
  $ethtool_opts = '',
  $bonding_opts = '',
  $peerdns = false,
  $dns1 = '',
  $dns2 = '',
  $domain = ''
) {
  network_if_base { $title:
    ensure       => $ensure,
    ipaddress    => $ipaddress,
    netmask      => $netmask,
    gateway      => $gateway,
    macaddress   => '',
    bootproto    => 'none',
    mtu          => $mtu,
    ethtool_opts => $ethtool_opts,
    bonding_opts => $bonding_opts,
    peerdns      => $peerdns,
    dns1         => $dns1,
    dns2         => $dns2,
    domain       => $domain,
  }

  $ifstate = $ensure ? {
    'up'    => Exec["ifup-${title}"],
    'down'  => Exec["ifdown-${title}"],
    default => undef,
  }

  augeas { "modprobe.conf_${title}":
    context => '/files/etc/modprobe.conf',
    changes => [
      "set alias[last()+1] ${title}",
      'set alias[last()]/modulename bonding',
    ],
    onlyif  => "match alias[*][. = '${title}'] size == 0",
    #onlyif  => 'match */modulename[. = 'bonding'] size == 0',
    before  => $ifstate
  }
} # define network::bond::static
