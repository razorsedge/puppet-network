# Class: network
#
# This module manages Red Hat/Fedora network configuration.
#
class network {
  # Only run on RedHat derived systems.
  case $::osfamily {
    RedHat: { }
    default: {
      fail('This network module only supports RedHat-based systems.')
    }
  }
} # class network

# Definition: network_if_base
#
# This definition is private, i.e. it is not intended to be called directly
# by users.  It can be used to write out the following device files:
#  /etc/sysconfig/networking-scripts/ifcfg-eth
#  /etc/sysconfig/networking-scripts/ifcfg-eth:alias
#  /etc/sysconfig/networking-scripts/ifcfg-bond(master)
#
# Parameters:
#   $ensure       - required - up|down
#   $ipaddress    - required
#   $netmask      - required
#   $gateway      - optional
#   $macaddress   - required
#   $bootproto    - optional
#   $mtu          - optional
#   $ethtool_opts - optional
#   $bonding_opts - optional
#   $isalias      - optional
#   $peerdns      - optional
#   $dns1         - optional
#   $dns2         - optional
#   $domain       - optional
#
# Actions:
#   Performs 'ifup/ifdown $name' after any changes to the ifcfg file.
#
# Requires:
#
# Sample Usage:
#
# TODO:
#   METRIC=
#   HOTPLUG=yes|no
#   USERCTL=yes|no
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
define network_if_base (
  $ensure,
  $ipaddress,
  $netmask,
  $macaddress,
  $gateway = '',
  $bootproto = 'none',
  $mtu = '',
  $ethtool_opts = '',
  $bonding_opts = '',
  $isalias = false,
  $peerdns = '',
  $dns1 = '',
  $dns2 = '',
  $domain = ''
) {
  $interface = $name

  if $isalias {
    $onparent = $ensure ? {
      up   => 'yes',
      down => 'no',
    }
  } else {
    $onboot = $ensure ? {
      up   => 'yes',
      down => 'no',
    }
  }

  file { "ifcfg-${interface}":
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/sysconfig/network-scripts/ifcfg-${interface}",
    content => $isalias ? {
      false => template('network/ifcfg-eth.erb'),
      true  => template('network/ifcfg-alias.erb'),
    }
  }

  case $ensure {
    up: {
      exec { "ifup-${interface}":
        command     => "/sbin/ifdown ${interface}; /sbin/ifup ${interface}",
        subscribe   => File["ifcfg-${interface}"],
        refreshonly => true,
      }
    }

    down: {
      exec { "ifdown-${interface}":
        command     => "/sbin/ifdown ${interface}",
        subscribe   => File["ifcfg-${interface}"],
        refreshonly => true,
      }
    }
  }

} # define network_if_base
