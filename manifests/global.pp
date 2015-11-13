# == Class: network::global
#
# Configures /etc/sysconfig/network
#
# === Parameters:
#
#   $hostname       - optional - Changes the hostname (be aware that it will break
#                                something)
#                                Note: When you reboot/restart puppet, it will
#                                generate a new certificate and a new certificate
#                                request, based on the new hostname; you will have to
#                                sign it (if autosign is off).  You will also have to
#                                provide a new node definition in the manifest based
#                                on the new hostname.
#   $gateway        - optional - Sets the default gateway
#   $gatewaydev     - optional - Determines the device to use as the default gateway
#                                Overrides $gateway in network::global.  Must have
#                                $gateway defined in network::if or network::bond.
#   $ipv6gateway    - optional - Sets the default gateway for the IPv6 address - IPv6 must be enabled
#   $ipv6defaultdev - optional - Determines the device to use as the default gateway
#                                for IPV6 traffic.
#   $nisdomain      - optional - Configures the NIS domainname.
#   $vlan           - optional - yes|no to enable VLAN kernel module
#   $ipv6networking - optional - enables / disables IPv6 globally
#   $nozeroconf     - optional
#
# === Actions:
#
#   Deploys the file /etc/sysconfig/network.
#
# === Requires:
#
#   Service['network']
#
# === Sample Usage:
#
#   class { 'network::global':
#     hostname       => 'host.domain.tld',
#     gateway        => '1.2.3.1',
#     gatewaydev     => 'eth0',
#     ipv6gateway    => '123:4567:89ab:cdef:123:4567:89ab:1',
#     ipv6defaultdev => 'eth0',
#     nisdomain      => 'domain.tld',
#     vlan           => 'yes',
#     ipv6networking => true,
#     nozeroconf     => 'yes',
#   }
#
# === TODO:
#
#
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2011 Mike Arnold, unless otherwise noted.
#
class network::global (
  $hostname              = undef,
  $gateway               = undef,
  $gatewaydev            = undef,
  $gatewaydev_macaddress = undef,
  $ipv6gateway           = undef,
  $ipv6defaultdev        = undef,
  $nisdomain             = undef,
  $vlan                  = undef,
  $ipv6networking        = false,
  $nozeroconf            = undef
) {
  # Validate our data
  if $gateway {
    if ! is_ip_address($gateway) { fail("${gateway} is not an IP address.") }
  }
  if $ipv6gateway {
    if ! is_ip_address($ipv6gateway) { fail("${ipv6gateway} is not an IPv6 address.") }
  }
  if $gatewaydev_macaddress {
    if ! is_mac_address($gatewaydev_macaddress) { fail("${gatewaydev_macaddress} is not a valid mac address.") }
  }

  validate_bool($ipv6networking)

  # Validate our regular expressions
  if $vlan {
    $states = [ '^yes$', '^no$' ]
    validate_re($vlan, $states, '$vlan must be either "yes" or "no".')
  }

  # Set the gateway device if its mac address is given instead
  if is_mac_address($gatewaydev_macaddress){
    $gatewaydev_from_mac = inline_template('<% interfaces.split(",").each do |ifn| %><% if gatewaydev_macaddress == scope.lookupvar("macaddress_#{ifn}") || gatewaydev_macaddress.downcase == scope.lookupvar("macaddress_#{ifn}") %><%= ifn %><% end %><% end %>')
    if !$gatewaydev_from_mac {
      fail('Could not find the gateway device name for the given macaddress...')
    }
  }

  validate_bool($ipv6networking)

  include '::network'

  file { 'network.sysconfig':
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => '/etc/sysconfig/network',
    content => template('network/network.erb'),
    notify  => Service['network'],
  }
} # class global
