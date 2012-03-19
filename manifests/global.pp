# Definition: network::global
#
# Configures /etc/sysconfig/network
#
# Parameters:
#   $gateway    - optional - Sets the default gateway
#   $gatewaydev - optional - Determines the device to use as the default gateway.
#                            Overrides $gateway in network::global.  Must have
#                            $gateway defined in network::if or network::bond.
#   $vlan       - optional - yes|no to enable VLAN kernel module
#   $nozeroconf - optional
#
# Actions:
#   Performs 'service network restart' after any change to /etc/sysconfig/network.
#
# Requires:
#   $::nisdomainname - optional - configures the NIS domainname
#
# Sample Usage:
#   # global network settings
#   network::global { "default":
#    gateway    => "1.2.3.1",
#    gatewaydev => "eth0",
#    vlan       => "yes",
#    nozeroconf => "yes",
#   }
#
# TODO:
#   NETWORKING_IPV6=yes|no
#
define network::global (
  $gateway = "",
  $vlan = "",
  $nozeroconf = "",
  $gatewaydev = ""
) {
  $nisdomain = $::nisdomainname ? {
    ''      => "",
    default => "$::nisdomainname",
  }

  file { "network.sysconfig":
    mode    => "644",
    owner   => "root",
    group   => "root",
    ensure  => "present",
    path    => "/etc/sysconfig/network",
    content => template("network/network.erb"),
    notify  => Service["network"],
  }

  service { "network":
    name       => "network",
    ensure     => "running",
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }
} # define global
