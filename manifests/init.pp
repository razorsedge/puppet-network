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
#   include '::network'
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
  # Only run on RedHat derived systems.
  case $::osfamily {
    'RedHat': { }
    default: {
      fail('This network module only supports RedHat-based systems.')
    }
  }

  service { 'network':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    provider   => 'redhat',
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
#   $ensure              - required - up|down
#   $ipaddress           - required
#   $netmask             - required
#   $macaddress          - required
#   $manage_hwaddr       - optional - defaults to true
#   $gateway             - optional
#   $bootproto           - optional
#   $userctl             - optional - defaults to false
#   $mtu                 - optional
#   $dhcp_hostname       - optional
#   $persistent_dhclient - optional - defaults to false
#   $ethtool_opts        - optional
#   $bonding_opts        - optional
#   $isalias             - optional
#   $peerdns             - optional
#   $dns1                - optional
#   $dns2                - optional
#   $domain              - optional
#   $bridge              - optional
#   $scope               - optional
#   $linkdelay           - optional
#   $check_link_down     - optional
#   $flush               - optional
#   $zone                - optional
#   $metric              - optional
#   $defroute            - optional
#
# === Actions:
#
# Performs 'service network restart' after any changes to the ifcfg file.
#
# === TODO:
#
#   HOTPLUG=yes|no
#   WINDOW=
#   SCOPE=
#   SRCADDR=
#   NOZEROCONF=yes
#   DHCPRELEASE=yes|no|1|0
#   DHCLIENT_IGNORE_GATEWAY=yes|no|1|0
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
  $manage_hwaddr       = true,
  $gateway             = undef,
  $ipv6address         = undef,
  $ipv6gateway         = undef,
  $ipv6init            = false,
  $ipv6autoconf        = false,
  $bootproto           = 'none',
  $userctl             = false,
  $mtu                 = undef,
  $dhcp_hostname       = undef,
  $persistent_dhclient = false,
  $ethtool_opts        = undef,
  $bonding_opts        = undef,
  $isalias             = false,
  $peerdns             = false,
  $ipv6peerdns         = false,
  $dns1                = undef,
  $dns2                = undef,
  $domain              = undef,
  $bridge              = undef,
  $linkdelay           = undef,
  $scope               = undef,
  $check_link_down     = false,
  $flush               = false,
  $defroute            = undef,
  $zone                = undef,
  $metric              = undef
) {
  # Validate our booleans
  validate_bool($userctl)
  validate_bool($isalias)
  validate_bool($peerdns)
  validate_bool($ipv6init)
  validate_bool($ipv6autoconf)
  validate_bool($ipv6peerdns)
  validate_bool($check_link_down)
  validate_bool($manage_hwaddr)
  validate_bool($flush)
  # Validate our regular expressions
  $states = [ '^up$', '^down$' ]
  validate_re($ensure, $states, '$ensure must be either "up" or "down".')

  include '::network'

  $interface = $name

  # Properly format $persistent_dhclient
  $persistent_dhclient_real = bool2num($persistent_dhclient)

  # Deal with the case where $dns2 is non-empty and $dns1 is empty.
  if $dns2 {
    if !$dns1 {
      $dns1_real = $dns2
      $dns2_real = undef
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

  if $flush {
    exec { 'network-flush':
      user        => 'root',
      command     => "ip addr flush dev ${interface}",
      refreshonly => true,
      subscribe   => File["ifcfg-${interface}"],
      before      => Service['network'],
      path        => '/sbin:/usr/sbin',
    }
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
