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
#   $vlan       - optional - yes|no to enable VLAN kernel module
#   $nozeroconf - optional
#
# Actions:
#   Performs 'service network restart' after any change to
#   /etc/sysconfig/network.
#
# Requires:
#   $::nisdomainname - optional - configures the NIS domainname
#
# Sample Usage:
#   # global network settings
#   class { 'network::global':
#    hostname   => 'host.domain.tld',
#    gateway    => '1.2.3.1',
#    gatewaydev => 'eth0',
#    vlan       => 'yes',
#    nozeroconf => 'yes',
#   }
#
# TODO:
#   NETWORKING_IPV6=yes|no
#
class network::global (
  $hostname = '',
  $gateway = '',
  $vlan = '',
  $nozeroconf = '',
  $gatewaydev = ''
) {
  $nisdomain = $::nisdomainname ? {
    ''      => '',
    default => $::nisdomainname,
  }

  file { 'network.sysconfig':
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => '/etc/sysconfig/network',
    content => template('network/network.erb'),
    notify  => Service['network'],
  }

  service { 'network':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }
} # class global
