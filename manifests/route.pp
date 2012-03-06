# Definition: network::route
#
# Configures /etc/sysconfig/networking-scripts/route-$name
#
# Parameters:
#   $address - required
#   $netmask - required
#   $gateway - required
#
# Actions:
#
# Requires:
#   File["ifcfg-$name"]
#
# Sample Usage:
#   # interface routes
#   network::route { "eth0":
#     address => [ "192.168.2.0", "10.0.0.0", ],
#     netmask => [ "255.255.255.0", "255.0.0.0", ],
#     gateway => [ "192.168.1.1", "10.0.0.1", ],
#   }
#
define network::route (
  $address,
  $netmask,
  $gateway
) {
  $interface = $name

  file { "route-$interface":
    mode    => "644",
    owner   => "root",
    group   => "root",
    ensure  => "present",
    path    => "/etc/sysconfig/network-scripts/route-$interface",
    content => template("network/route-eth.erb"),
    before  => File["ifcfg-$interface"],
    # need to know $ensure of $interface since one of these execs is not defined.
    #notify  => [ Exec["ifup-$interface"], Exec["ifdown-$interface"], ],
  }

  # mja: use "if defined(File['/tmp/myfile']) { ... }" ?
  # check if interface is up and if so then add routes
  #exec { "ifup-routes-$interface":
  #  command => "/etc/sysconfig/network-scripts/ifup-routes $interface",
  #}
} # define network::route
