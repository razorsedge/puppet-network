# Definition: network::bridge::static
#
# Creates a normal interface with static IP address.
#
# Parameters:
#   $ipaddress    - required
#   $netmask      - required
#   $gateway      - optional
#   $peerdns      - optional
#   $dns1         - optional
#   $dns2         - optional
#   $domain       - optional
#   $ensure       - required - up|down
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  # normal interface - static (minimal)
#  network::bridge::static { "br0":
#    ipaddress  => "10.21.30.248",
#    netmask    => "255.255.255.128",
#    domain     => "is.domain.com domain.com",
#    ensure     => "up",
#  }
#
define network::bridge::static (
  $ipaddress,
  $netmask,
  $gateway = "",
  $bootproto = "static",
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
} # define network::bridge::static
