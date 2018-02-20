# == Definition: network::alias::range
#
# Creates a range of aliases on an interface with static IP addresses.
# There is an assumption that an aliased interface will never use DHCP.
#
# === Parameters:
#
#   $ensure          - required - up|down|absent
#   $ipaddress_start - required
#   $ipaddress_start - required
#   $clonenum_start  - required
#   $noaliasrouting  - optional - false|true
#   $restart         - optional - defaults to true
#   $netmask         - optional - an IP address (CIDR not supported)
#   $broadcast       - optional - an IP address
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name-range*.
#
# === Sample Usage:
#
#   network::alias::range { 'eth1':
#     ensure          => 'up',
#     ipaddress_start => '1.2.3.5',
#     ipaddress_end   => '1.2.3.20',
#     clonenum_start  => '0',
#     noaliasrouting  => true,
#     arpcheck        => false,
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
#
define network::alias::range (
  Enum['up', 'down', 'absent'] $ensure,
  IP::Address::V4::NoSubnet $ipaddress_start,
  IP::Address::V4::NoSubnet $ipaddress_end,
  String $clonenum_start,
  Boolean $noaliasrouting = false,
  Boolean $restart = true,
  Optional[IP::Address::V4::NoSubnet] $netmask = undef,
  Optional[IP::Address::V4::NoSubnet] $broadcast = undef,
  Boolean $arpcheck = true,
) {

  include '::network'

  $interface = $name
  $onparent = $ensure ? {
    'up'    => 'yes',
    'down'  => 'no',
    default => undef,
  }
  $file_ensure = $ensure ? {
    'up'     => 'present',
    'down'   => 'present',
    'absent' => 'absent',
    default  => undef,
  }

  file { "ifcfg-${interface}-range${clonenum_start}":
    ensure  => $file_ensure,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/sysconfig/network-scripts/ifcfg-${interface}-range${clonenum_start}",
    content => epp("${module_name}/ifcfg-alias-range.epp", {
      ipaddress_start => $ipaddress_start,
      ipaddress_end   => $ipaddress_end,
      clonenum_start  => $clonenum_start,
      noaliasrouting  => $noaliasrouting,
      netmask         => $netmask,
      broadcast       => $broadcast,
      arpcheck        => $arpcheck,
      onparent        => $onparent,
    }),
    before  => File["ifcfg-${interface}"],
  }

  if $restart {
    File["ifcfg-${interface}-range${clonenum_start}"] {
      notify  => Service['network'],
    }
  }

} # define network::alias::range
