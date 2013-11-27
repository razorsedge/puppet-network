# == Class: network
#
# This module manages Red Hat/Fedora network configuration.
#
# === Parameters:
#
# None
#
# === Actions:
#
# Defines the network service so that other resources can notify it to restart.
#
# === Sample Usage:
#
#   include 'network'
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2011 Mike Arnold, unless otherwise noted.
#
class network {
  $use_hiera = true
  # Only run on RedHat derived systems.
  case $::osfamily {
    'RedHat': { }
    default: {
      fail('This network module only supports RedHat-based systems.')
    }
  }

  if $use_hiera {
    $network = hiera_hash('network')
    if ! $network {
      fail('hiera network configuration missing')
    }
    if $network['global'] {
      create_resources( 'network::global', $network['global'] )
    }
    if $network['route'] {
      create_resources( 'network::route',  $network['route'] )
    }
    if $network['if'] {
      if $network['if']['static'] {
        create_resources( 'network::if::static',  $network['if']['static'],  { ensure => 'up' } )
      }
      if $network['if']['dynamic'] {
        create_resources( 'network::if::dynamic', $network['if']['dynamic'], { ensure => 'up' } )
      }
      if $network['if']['alias'] {
        create_resources( 'network::if::alias',   $network['if']['alias'],   { ensure => 'up' } )
      }
    }
    if $network['bond'] {
      if $network['bond']['alias'] {
        create_resources( 'network::bond::alias',   $network['bond']['alias'] )
      }
      if $network['bond']['dynamic'] {
        create_resources( 'network::bond::dynamic', $network['bond']['dynamic'] )
      }
      if $network['bond']['slave'] {
        create_resources( 'network::bond::slave',   $network['bond']['slave'] )
      }
      if $network['bond']['static'] {
        create_resources( 'network::bond::static',  $network['bond']['static'] )
      }
    }
    if $network['alias'] {
      create_resources( 'network::alias', $network['alias'], { ensure => 'up' }  )
    }
  }
  service { 'network':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }
} # class network

# == Definition: network_if_base
#
# This definition is private, i.e. it is not intended to be called directly
# by users.  It can be used to write out the following device files:
#  /etc/sysconfig/networking-scripts/ifcfg-eth
#  /etc/sysconfig/networking-scripts/ifcfg-eth:alias
#  /etc/sysconfig/networking-scripts/ifcfg-bond(master)
#
# === Parameters:
#
#   $ensure       - required - up|down
#   $ipaddress    - required
#   $netmask      - required
#   $macaddress   - required
#   $gateway      - optional
#   $bootproto    - optional
#   $userctl      - optional - defaults to false
#   $mtu          - optional
#   $ethtool_opts - optional
#   $bonding_opts - optional
#   $isalias      - optional
#   $peerdns      - optional
#   $dns1         - optional
#   $dns2         - optional
#   $domain       - optional
#   $bridge       - optional
#
# === Actions:
#
# Performs 'service network restart' after any changes to the ifcfg file.
#
# === TODO:
#
#   METRIC=
#   HOTPLUG=yes|no
#   WINDOW=
#   SCOPE=
#   SRCADDR=
#   NOZEROCONF=yes
#   PERSISTENT_DHCLIENT=yes|no|1|0
#   DHCPRELEASE=yes|no|1|0
#   DHCLIENT_IGNORE_GATEWAY=yes|no|1|0
#   LINKDELAY=
#   REORDER_HDR=yes|no
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2011 Mike Arnold, unless otherwise noted.
#
define network_if_base (
  $ensure,
  $ipaddress,
  $netmask,
  $macaddress,
  $gateway = '',
  $bootproto = 'none',
  $userctl = false,
  $mtu = '',
  $ethtool_opts = '',
  $bonding_opts = undef,
  $isalias = false,
  $peerdns = false,
  $dns1 = '',
  $dns2 = '',
  $domain = '',
  $bridge = ''
) {
  # Validate our booleans
  validate_bool($userctl)
  validate_bool($isalias)
  validate_bool($peerdns)
  # Validate our regular expressions
  $states = [ '^up$', '^down$' ]
  validate_re($ensure, $states, '$ensure must be either "up" or "down".')

  include 'network'

  $interface = $name

  # Deal with the case where $dns2 is non-empty and $dns1 is empty.
  if $dns2 != '' {
    if $dns1 == '' {
      $dns1_real = $dns2
      $dns2_real = ''
    } else {
      $dns1_real = $dns1
      $dns2_real = $dns2
    }
  } else {
    $dns1_real = $dns1
    $dns2_real = $dns2
  }

  if $isalias {
    $onparent = $ensure ? {
      'up'    => 'yes',
      'down'  => 'no',
      default => undef,
    }
    $iftemplate = template('network/ifcfg-alias.erb')
  } else {
    $onboot = $ensure ? {
      'up'    => 'yes',
      'down'  => 'no',
      default => undef,
    }
    $iftemplate = template('network/ifcfg-eth.erb')
  }

  file { "ifcfg-${interface}":
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/sysconfig/network-scripts/ifcfg-${interface}",
    content => $iftemplate,
    notify  => Service['network'],
  }
} # define network_if_base
