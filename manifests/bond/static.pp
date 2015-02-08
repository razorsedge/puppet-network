# == Definition: network::bond::static
#
# Creates a bonded interface with static IP address and enables the bonding
# driver.
#
# === Parameters:
#
#   $ensure       - required - up|down
#   $ipaddress    - required
#   $netmask      - required
#   $gateway      - optional
#   $mtu          - optional
#   $ethtool_opts - optional
#   $bonding_opts - optional
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
# Updates /etc/modprobe.conf with bonding driver parameters.
#
# === Sample Usage:
#
#   network::bond::static { 'bond0':
#     ensure       => 'up',
#     ipaddress    => '1.2.3.5',
#     netmask      => '255.255.255.0',
#     bonding_opts => 'mode=active-backup miimon=100',
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2011 Mike Arnold, unless otherwise noted.
#
define network::bond::static (
  $ensure,
  $ipaddress,
  $netmask,
  $gateway = '',
  $mtu = '',
  $ethtool_opts = '',
  $bonding_opts = 'miimon=100',
  $peerdns = false,
  $ipv6init = false,
  $ipv6address = '',
  $ipv6gateway = '',
  $ipv6peerdns = false,
  $dns1 = '',
  $dns2 = '',
  $domain = ''
) {
  # Validate our regular expressions
  $states = [ '^up$', '^down$' ]
  validate_re($ensure, $states, '$ensure must be either "up" or "down".')
  # Validate our data
  if ! is_ip_address($ipaddress) { fail("${ipaddress} is not an IP address.") }
  if $ipv6address != '' {
    if ! is_ip_address($ipv6address) { fail("${ipv6address} is not an IPv6 address.") }
  }
  # Validate booleans
  validate_bool($ipv6init)
  validate_bool($ipv6peerdns)


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
    ipv6init     => $ipv6init,
    ipv6address  => $ipv6address,
    ipv6peerdns  => $ipv6peerdns,
    ipv6gateway  => $ipv6gateway,
    dns1         => $dns1,
    dns2         => $dns2,
    domain       => $domain,
  }

  # Only install "alias bondN bonding" on old OSs that support
  # /etc/modprobe.conf.
  case $::operatingsystem {
    /^(RedHat|CentOS|OEL|OracleLinux|SLC|Scientific)$/: {
      case $::operatingsystemrelease {
        /^[45]/: {
          augeas { "modprobe.conf_${title}":
            context => '/files/etc/modprobe.conf',
            changes => [
              "set alias[last()+1] ${title}",
              'set alias[last()]/modulename bonding',
            ],
            onlyif  => "match alias[*][. = '${title}'] size == 0",
            before  => Network_if_base[$title],
          }
        }
        default: {}
      }
    }
    'Fedora': {
      case $::operatingsystemrelease {
        /^(1|2|3|4|5|6|7|8|9|10|11)$/: {
          augeas { "modprobe.conf_${title}":
            context => '/files/etc/modprobe.conf',
            changes => [
              "set alias[last()+1] ${title}",
              'set alias[last()]/modulename bonding',
            ],
            onlyif  => "match alias[*][. = '${title}'] size == 0",
            before  => Network_if_base[$title],
          }
        }
        default: {}
      }
    }
    default: {}
  }
} # define network::bond::static
