# == Definition: network::if::promisc
#
# Creates a promiscuous interface.
#
# === Parameters:
#
#   $ensure        - required - up|down
#   $macaddress    - optional, defaults to macaddress_$title
#   $manage_hwaddr - optional - defaults to true
#   $bootproto     - optional, defaults to undef ('none')
#   $userctl       - optional
#   $mtu           - optional
#   $ethtool_opts  - optional
#   $promisc       - defaults to true
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Requires:
#
#   Service['network']
#
# === Sample Usage:
#
#   network::if::promisc { 'eth1':
#     ensure => 'up',
#   }
#
#   network::if::promisc { 'eth1':
#     ensure => 'up',
#     macaddress => aa:bb:cc:dd:ee:ff,
#   }
#
# === Authors:
#
# Elyse Salberg <elyse_salberg@putnam.com>
#
# === Copyright:
#
# Copyright (C) 2015 Elyse Salberg, unless otherwise noted.
#
define network::if::promisc (
  $ensure,
  $macaddress    = undef,
  $manage_hwaddr = true,
  $bootproto     = undef,
  $userctl       = false,
  $mtu           = undef,
  $ethtool_opts  = undef,
  $restart       = true,
  $promisc       = true,
) {
  include '::network'

  $interface = $name

  if ! is_mac_address($macaddress) {
    # Strip off any tailing VLAN (ie eth5.90 -> eth5).
    $title_clean = regsubst($title,'^(\w+)\.\d+$','\1')
    $macaddy = getvar("::macaddress_${title_clean}")
  } else {
    $macaddy = $macaddress
  }

  # Validate our regular expressions
  $states = [ '^up$', '^down$' ]
  validate_re($ensure, $states, '$ensure must be either "up" or "down".')

  # Validate booleans
  validate_bool($userctl)
  validate_bool($manage_hwaddr)
  validate_bool($restart)
  validate_bool($promisc)

  # Validate our data
  if ! is_mac_address($macaddy) {
    fail("${macaddy} is not a MAC address.")
  }

  $onboot = $ensure ? {
    'up'    => 'yes',
    'down'  => 'no',
    default => undef,
  }

  if $promisc {
    case $::operatingsystem {
      /^(RedHat|CentOS|OEL|OracleLinux|SLC|Scientific)$/: {
        case $::operatingsystemmajrelease {
          '5': {
            $ifup_source   = "puppet:///modules/${module_name}/promisc/ifup-local-promisc_5"
            $ifdown_source = "puppet:///modules/${module_name}/promisc/ifdown-local-promisc_5"
          }
          '6','7': {
            $ifup_source   = "puppet:///modules/${module_name}/promisc/ifup-local-promisc_6"
            $ifdown_source = "puppet:///modules/${module_name}/promisc/ifdown-local-promisc_6"
          }
          default: {
            fail('Promiscuous network setup is currently only available for EL 5, 6, and 7.')
          }
        }

        file { [ '/sbin/ifup-local', '/sbin/ifdown-local' ]:
          ensure  => 'present',
          owner   => 'root',
          group   => 'root',
          mode    => '0755',
          content => '#!/bin/bash',
          replace => false,
        }
        file {'ifup-local-promisc':
          ensure => 'file',
          path   => '/sbin/ifup-local-promisc',
          owner  => 'root',
          group  => 'root',
          mode   => '0755',
          source => $ifup_source,
        }
        file {'ifdown-local-promisc':
          ensure => 'file',
          path   => '/sbin/ifdown-local-promisc',
          owner  => 'root',
          group  => 'root',
          mode   => '0755',
          source => $ifdown_source,
        }
        file_line { 'ifup-local-promisc':
          path    => '/sbin/ifup-local',
          line    => '/sbin/ifup-local-promisc',
          require => [ File['/sbin/ifup-local'],File['/sbin/ifup-local-promisc'] ],
        }
        file_line { 'ifdown-local-promisc':
          path    => '/sbin/ifdown-local',
          line    => '/sbin/ifdown-local-promisc',
          require => [ File['/sbin/ifdown-local'],File['/sbin/ifdown-local-promisc'] ],
        }
      }
      default: {
        notice('Promiscuous network setup currently is only available for RedHat.')
      }
    }
  }

  network_if_base { $title:
    ensure        => $ensure,
    ipaddress     => '',
    netmask       => '',
    gateway       => '',
    macaddress    => $macaddy,
    manage_hwaddr => $manage_hwaddr,
    bootproto     => 'none',
    ipv6address   => '',
    ipv6gateway   => '',
    mtu           => $mtu,
    ethtool_opts  => $ethtool_opts,
    promisc       => $promisc,
  }
} # define network::if::promisc
