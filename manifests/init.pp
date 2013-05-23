# Class: network
#
# This module manages Red Hat/Fedora network configuration.
#
class network (
  $hostname     = $::fqdn,
  $gateway      = undef,
  $gatewaydev   = undef,
  $vlan         = undef,
  $nozeroconf   = undef,
  $ipv6_support = 'no',
  $peerdns      = 'no',
  $peerntp      = 'no',
) {

  # Only run on RedHat derived systems.
  case $::osfamily {
    'RedHat': {

      # interface static
      $network_if_statics = hiera_hash('network::if::static',undef)
      if $network_if_statics != undef {
        create_resources('network::if::static', $network_if_statics)
      }

      # interface dhcp
      $network_if_dynamics = hiera_hash('network::if::dynamic',undef)
      if $network_if_dynamics != undef {
        create_resources('network::if::dynamic', $network_if_dynamics)
      }

      # interface aliases
      $network_if_aliases = hiera_hash('network::if::alias',undef)
      if $network_if_aliases != undef {
        create_resources('network::if::alias', $network_if_aliases)
      }

      # bond static
      $network_bond_statics = hiera_hash('network::bond::static',undef)
      if $network_bond_statics != undef {
        create_resources('network::bond::static', $network_bond_statics)
      }

      # bond dhcp
      $network_bond_dynamics = hiera_hash('network::bond::dynamic',undef)
      if $network_bond_dynamics != undef {
        create_resources('network::bond::dynamic', $network_bond_dynamics)
      }

      # bond slaves
      $network_bond_slaves = hiera_hash('network::bond::slave',undef)
      if $network_bond_slaves != undef {
        create_resources('network::bond::slave', $network_bond_slaves)
      }

      # bond aliases
      $network_bond_aliases = hiera_hash('network::bond::alias',undef)
      if $network_bond_aliases != undef {
        create_resources('network::bond::alias', $network_bond_aliases)
      }

      # routes
      $network_routes = hiera_hash('network::route',undef)
      if $network_routes != undef {
        create_resources('network::route', $network_routes)
      }

      $nisdomain = $::nisdomainname ? {
        ''      => undef,
        default => $::nisdomainname,
      }

      file { 'network_sysconfig':
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
    }
    default: {
      fail("osfamily is <${::osfamily}> and network module only supports RedHat based systems.")
    }
  }
}
