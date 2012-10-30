# Class: network
#
# This module manages Red Hat/Fedora network configuration.
#
class network (
  $use_hiera = true
) {
  # Only run on RedHat derived systems.
  case $::osfamily {
    RedHat: { }
    default: {
      fail('This network module only supports Red Hat-based systems.')
    }
  }
  if $use_hiera {
    $network = hiera_hash('network')
    if ! $network {
      fail('hiera network configuration missing')
    }
    if $network['global'] {
      create_resources( 'network::global', $network['global'] )
    }
    if $network['route'] {
      create_resources( 'network::route',  $network['route'] )
    }
    if $network['if'] {
      if $network['if']['static'] {
        create_resources( 'network::if::static',  $network['if']['static'],  { ensure => 'up' } )
      }
      if $network['if']['dynamic'] {
        create_resources( 'network::if::dynamic', $network['if']['dynamic'], { ensure => 'up' } )
      }
      if $network['if']['alias'] {
        create_resources( 'network::if::alias',   $network['if']['alias'],   { ensure => 'up' } )
      }
    }
    if $network['bond'] {
      if $network['bond']['alias'] {
        create_resources( 'network::bond::alias',   $network['bond']['alias'] )
      }
      if $network['bond']['dynamic'] {
        create_resources( 'network::bond::dynamic', $network['bond']['dynamic'] )
      }
      if $network['bond']['slave'] {
        create_resources( 'network::bond::slave',   $network['bond']['slave'] )
      }
      if $network['bond']['static'] {
        create_resources( 'network::bond::static',  $network['bond']['static'] )
      }
    }
  }
} # class network
