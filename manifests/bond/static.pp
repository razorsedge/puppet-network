# == Definition: network::bond::static
#
# Creates a bonded interface with static IP address and enables the bonding
# driver.
#
# === Parameters:
#
#   $ensure       - required - up|down
#   $ipaddress    - optional
#   $netmask      - optional
#   $gateway      - optional
#   $mtu          - optional
#   $ethtool_opts - optional
#   $bonding_opts - optional
#   $zone         - optional
#   $defroute     - optional
#   $restart      - optional - defaults to true
#   $metric       - optional
#   $userctl      - optional
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
  Enum['up', 'down'] $ensure,
  Optional[Stdlib::IP::Address::V4::Nosubnet] $ipaddress = undef,
  Optional[Stdlib::IP::Address::V4::Nosubnet] $netmask = undef,
  Optional[Stdlib::IP::Address::V4::Nosubnet] $gateway = undef,
  Optional[String] $mtu = undef,
  Optional[String] $ethtool_opts = undef,
  String $bonding_opts = 'miimon=100',
  Boolean $peerdns = false,
  Boolean $ipv6init = false,
  Optional[Stdlib::IP::Address::V6] $ipv6address = undef,
  Optional[Stdlib::IP::Address::V6::Nosubnet] $ipv6gateway = undef,
  Boolean $ipv6peerdns = false,
  Optional[Stdlib::IP::Address::Nosubnet] $dns1 = undef,
  Optional[Stdlib::IP::Address::Nosubnet] $dns2 = undef,
  Optional[String] $domain = undef,
  Optional[String] $zone = undef,
  Optional[String] $defroute = undef,
  Optional[String] $metric = undef,
  Boolean $restart = true,
  Boolean $userctl = false,
) {

  network_if_base { $title:
    ensure       => $ensure,
    ipaddress    => $ipaddress,
    netmask      => $netmask,
    gateway      => $gateway,
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
    zone         => $zone,
    defroute     => $defroute,
    metric       => $metric,
    restart      => $restart,
    userctl      => $userctl,
  }

  # Only install "alias bondN bonding" on old OSs that support
  # /etc/modprobe.conf.
  case $::os['name'] {
    /^(RedHat|CentOS|OEL|OracleLinux|SLC|Scientific)$/: {
      case $::os['release']['major'] {
        /^[45]$/: {
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
      case $::os['release']['major'] {
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
