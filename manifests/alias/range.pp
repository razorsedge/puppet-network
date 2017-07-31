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
  $ensure,
  $ipaddress_start,
  $ipaddress_end,
  $clonenum_start,
  $noaliasrouting = false,
  $restart = true,
  $netmask = false,
  $broadcast = false,
  $arpcheck = true,
) {
  # Validate our data
  if ! is_ip_address($ipaddress_start) { fail("${ipaddress_start} is not an IP address.") }
  if ! is_ip_address($ipaddress_end) { fail("${ipaddress_end} is not an IP address.") }
  if $netmask and !is_ip_address($netmask) { fail("${netmask} is not an IP address.") }
  if $broadcast and !is_ip_address($broadcast) { fail("${broadcast} is not an IP address.") }
  # Validate our booleans
  validate_bool($noaliasrouting)
  validate_bool($restart)
  validate_bool($arpcheck)
  # Validate our regular expressions
  $states = [ '^up$', '^down$', '^absent$' ]
  validate_re($ensure, $states, '$ensure must be either "up", "down", or "absent".')

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
    content => template('network/ifcfg-alias-range.erb'),
    before  => File["ifcfg-${interface}"],
  }

  if $restart {
    File["ifcfg-${interface}-range${clonenum_start}"] {
      notify  => Service['network'],
    }
  }

} # define network::alias::range
