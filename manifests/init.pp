# Class: network
#
# This module manages Red Hat/Fedora network configuration.
#
class network {
  # Only run on RedHat derived systems.
  case $operatingsystem {
    centos, redhat, fedora, oel: {
      import '*.pp'

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
      #   $nisdomainname - optional - configures the NIS domainname
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
      define global ( $gateway = "", $vlan = "", $nozeroconf = "", $gatewaydev = "" ) {
        $nisdomain = $nisdomainname ? {
          ''      => "",
          default => "$nisdomainname",
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
          name       => $operatingsystem ? {
            default => "network",
          },
          ensure     => "running",
          enable     => "true",
          hasrestart => "true",
          hasstatus  => "true",
        }
      } # define global

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
      define route ( $address, $netmask, $gateway ) {
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

    }
    default: { }
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
#   $ipaddress    - required
#   $netmask      - required
#   $gateway      - optional
#   $macaddress   - required
#   $bootproto    - optional
#   $mtu          - optional
#   $ethtool_opts - optional
#   $bonding_opts - optional
#   $isalias      - optional
#   $ensure       - required - up|down
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
#   PEERDNS=yes|no
#   DNS{1,2}=<ip address>
#   SCOPE=
#   SRCADDR=
#   NOZEROCONF=yes
#   PERSISTENT_DHCLIENT=yes|no|1|0
#   DHCPRELEASE=yes|no|1|0
#   DHCLIENT_IGNORE_GATEWAY=yes|no|1|0
#   LINKDELAY=
#   REORDER_HDR=yes|no
#
define network_if_base ( $ipaddress, $netmask, $gateway = "", $macaddress, $bootproto = "none", $mtu = "", $ethtool_opts = "", $bonding_opts = "", $isalias = false, $ensure ) {
  $interface = $name

  if $isalias {
    $onparent = $ensure ? {
      up   => "yes",
      down => "no",
    }
  } else {
    $onboot = $ensure ? {
      up   => "yes",
      down => "no",
    }
  }

  file { "ifcfg-$interface":
    mode    => "644",
    owner   => "root",
    group   => "root",
    ensure  => "present",
    path    => "/etc/sysconfig/network-scripts/ifcfg-$interface",
    content => $isalias ? {
      false => template("network/ifcfg-eth.erb"),
      true  => template("network/ifcfg-alias.erb"),
    } 
  } 

  case $ensure {
    up: {
      exec { "ifup-$interface":
        command     => "/sbin/ifdown $interface; /sbin/ifup $interface",
        subscribe   => File["ifcfg-$interface"],
        refreshonly => "true",
      }
    }

    down: {
      exec { "ifdown-$interface":
        command     => "/sbin/ifdown $interface",
        subscribe   => File["ifcfg-$interface"],
        refreshonly => "true",
      }
    }
  }

} # define network_if_base

