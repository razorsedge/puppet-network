# == Definition: network::if::base
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
#   $macaddress   - required
#   $gateway      - optional
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
define network::if::base (
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
  $peerdns = false,
  $dns1 = '',
  $dns2 = '',
  $domain = '',
) {

  # Validate our booleans
  validate_bool($isalias)
  validate_bool($peerdns)
  # Validate our regular expressions
  $states = [ '^up$', '^down$' ]
  validate_re($ensure, $states, '$ensure must be either "up" or "down".')

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
  }

  case $ensure {
    'up': {
      exec { "ifup-${interface}":
        command     => "/sbin/ifdown ${interface}; /sbin/ifup ${interface}",
        subscribe   => File["ifcfg-${interface}"],
        refreshonly => true,
      }
    }

    'down': {
      exec { "ifdown-${interface}":
        command     => "/sbin/ifdown ${interface}",
        subscribe   => File["ifcfg-${interface}"],
        refreshonly => true,
      }
    }
    default: {
      fail("network::if::base::${name}::ensure is <${ensure}> and must be \'up\' or \'down\'.")
    }
  }
}
