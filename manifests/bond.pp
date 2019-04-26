# == Definition: network::bond
#
# Creates a bonded interface with no IP information and enables the
# bonding driver.
#
# === Parameters:
#
#   $ensure       - required - up|down
#   $mtu          - optional
#   $ethtool_opts - optional
#   $bonding_opts - optional
#   $zone         - optional
#   $restart      - optional - defaults to true
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
# Updates /etc/modprobe.conf with bonding driver parameters.
#
# === Sample Usage:
#
#   network::bond { 'bond2':
#     ensure => 'up',
#   }
#
# === Authors:
#
# Jason Vervlied <jvervlied@3cinteractive.com>
#
# === Copyright:
#
# Copyright (C) 2015 Jason Vervlied, unless otherwise noted.
#
define network::bond (
  Enum['up', 'down'] $ensure,
  Optional[String] $mtu = undef,
  Optional[String] $ethtool_opts = undef,
  String $bonding_opts = 'miimon=100',
  Optional[String] $zone = undef,
  Boolean $restart = true,
) {

  network_if_base { $title:
    ensure       => $ensure,
    bootproto    => 'none',
    mtu          => $mtu,
    ethtool_opts => $ethtool_opts,
    bonding_opts => $bonding_opts,
    zone         => $zone,
    restart      => $restart,
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
} # define network::bond
