# == Definition: network::rule
#
# Configures /etc/sysconfig/networking-scripts/rule-$name.
#
# === Parameters:
#
#   $ipv4_rules
#   $ipv6_rules
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/rule-$name.
#
# === Requires:
#
#   File["ifcfg-$name"]
#   Service['network']
#
# === Sample Usage:
#
#   network::route { 'eth0':
#     ipv4_rules => [{
#       iif   => 'eth0',
#       table => 1,
#     },{
#       from  => '192.168.200.100',
#       table => 1,
#     },]
#   }
#
# === Authors:
#
# Manfred Pusch <manfred@pusch.cc>
#
# === Copyright:
#
# Copyright (C) 2016 Manfred Pusch, unless otherwise noted.
#
define network::rule (
  $ipv4_rules = [],
  $ipv6_rules = [],
) {
  # Validate our arrays
  validate_array($ipv4_rules)
  validate_array($ipv6_rules)

  include '::network'

  $interface = $name

  if ! empty($ipv4_rules) {
    file { "rule-${interface}":
      ensure  => 'present',
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      path    => "/etc/sysconfig/network-scripts/rule-${interface}",
      content => template('network/rule-eth-v4.erb'),
      before  => File["ifcfg-${interface}"],
      notify  => Service['network'],
    }
  }
  if ! empty($ipv6_rules) {
    file { "rule6-${interface}":
      ensure  => 'present',
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      path    => "/etc/sysconfig/network-scripts/rule6-${interface}",
      content => template('network/rule-eth-v6.erb'),
      before  => File["ifcfg-${interface}"],
      notify  => Service['network'],
    }
  }
} # define network::rule
