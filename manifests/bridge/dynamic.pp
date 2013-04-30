# Definition: network::bridge::dynamic
#
# Creates a normal interface with dynamic IP information.
#
# Parameters:
#   $macaddress   - required
#   $bootproto    - optional - defaults to "dhcp"
#   $mtu          - optional
#   $ethtool_opts - optional
#   $ensure       - required - up|down
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  # normal interface - dhcp (minimal)
#  network::bridge::dynamic { "br0":
#    ensure     => "up",
#  }
#
#  # normal interface - bootp (minimal)
#  network::bridge::dynamic { "br0":
#    bootproto  => "dhcp",
#    ensure     => "up",
#  }
#
define network::bridge::dynamic (
  $gateway = "",
  $ipaddress = "",
  $netmask = "",
  $gateway = "",
  $bootproto = "dhcp",
  $onboot = "yes",
  $peerdns = "",
  $dns1 = "",
  $dns2 = "",
  $domain = "",
  $ensure
) {

  $interface = $name

  file { "ifcfg-$interface":
    mode    => "644",
    owner   => "root",
    group   => "root",
    ensure  => "present",
    path    => "/etc/sysconfig/network-scripts/ifcfg-$interface",
    content => template("network/ifcfg-br.erb"),
  }

} # define network::bridge::dynamic
