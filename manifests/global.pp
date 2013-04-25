# Class: network::global
#
# Configures /etc/sysconfig/network
#
# Parameters:
#   $hostname   - optional - Changes the hostname (be aware that it will break
#                            something)
#                            Note: when you'll reboot/restart puppet, it will
#                            generate a new certificate and a new certificate
#                            request, based on the new hostname; you'll have to
#                            sign it (if autosign is off).  You'll also have to
#                            provide a new node definition in the manifest based
#                            on the new hostname.
#   $gateway    - optional - Sets the default gateway
#   $gatewaydev - optional - Determines the device to use as the default gateway
#                            Overrides $gateway in network::global.  Must have
#                            $gateway defined in network::if or network::bond.
#   $nisdomain  - optional - Configures the NIS domainname.
#   $vlan       - optional - yes|no to enable VLAN kernel module
#   $nozeroconf - optional
#
# Actions:
#   Deploys the file /etc/sysconfig/network.
#
# Sample Usage:
#   # global network settings
#  class { 'network::global':
#    hostname   => 'host.domain.tld',
#    gateway    => '1.2.3.1',
#    gatewaydev => 'eth0',
#    nisdomain  => 'domain.tld',
#    vlan       => 'yes',
#    nozeroconf => 'yes',
#  }
#
# TODO:
#   NETWORKING_IPV6=yes|no
#
class network::global (
  $hostname   = '',
  $gateway    = '',
  $gatewaydev = '',
  $nisdomain  = '',
  $vlan       = '',
  $nozeroconf = ''
) {
  # Validate our data
  if $gateway != '' {
    if ! is_ip_address($gateway) { fail("${gateway} is not an IP address.") }
  }
  # Validate our regular expressions
  if $vlan != '' {
    $states = [ '^yes$', '^no$' ]
    validate_re($vlan, $states, '$vlan must be either "yes" or "no".')
  }

  include 'network'

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
