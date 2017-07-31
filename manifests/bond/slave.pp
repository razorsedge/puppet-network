# == Definition: network::bond::slave
#
# Creates a bonded slave interface.
#
# === Parameters:
#
#   $master       - required
#   $macaddress   - optional
#   $ethtool_opts - optional
#   $restart      - optional, defaults to true
#   $zone         - optional
#   $defroute     - optional
#   $metric       - optional
#   $userctl      - optional - defaults to false
#   $bootproto    - optional
#   $onboot       - optional
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
#   network::bond::slave { 'eth1':
#     macaddress => $::macaddress_eth1,
#     master     => 'bond0',
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
define network::bond::slave (
  $master,
  $macaddress = undef,
  $ethtool_opts = undef,
  $zone = undef,
  $defroute = undef,
  $metric = undef,
  $restart = true,
  $userctl = false,
  $bootproto = undef,
  $onboot = undef,
) {
  # Validate our data
  if $macaddress and ! is_mac_address($macaddress) {
    fail("${macaddress} is not a MAC address.")
  }
  # Validate our booleans
  validate_bool($restart)
  validate_bool($userctl)

  include '::network'

  $interface = $name

  file { "ifcfg-${interface}":
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/sysconfig/network-scripts/ifcfg-${interface}",
    content => template('network/ifcfg-bond.erb'),
    before  => File["ifcfg-${master}"],
  }

  if $restart {
    File["ifcfg-${interface}"] {
      notify  => Service['network'],
    }
  }
} # define network::bond::slave
