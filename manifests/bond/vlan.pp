# == Definition: network::bond::vlan
#
define network::bond::vlan (
  $ensure,
  $bootproto = 'none',
  $ipaddress,
  $netmask,
  $vlanId,
  $gateway,
  $macaddress = '',
  $mtu = undef,
  $ethtool_opts = undef,
  $bonding_opts = 'miimon=100',
  $peerdns = false,
  $ipv6init = false,
  $ipv6address = undef,
  $ipv6gateway = undef,
  $ipv6peerdns = false,
  $dns1 = undef,
  $dns2 = undef,
  $domain = undef
) {

  $states = [ '^up$', '^down$' ]
  validate_re($ensure, $states, '$ensure must be either "up" or "down".')

  if ! $vlanId { fail("vlanId must be passed for this resource type!") }
  if ! is_ip_address($ipaddress) { fail("${ipaddress} is not an IP address.") }
  if $ipv6address {
    if ! is_ip_address($ipv6address) { fail("${ipv6address} is not an IPv6 address.") }
  }
  validate_bool($ipv6init)
  validate_bool($ipv6peerdns)

  $onboot = $ensure ? {
    'up'    => 'yes',
    'down'  => 'no',
    default => undef,
  }

  $interface = $name

  #include '::network'

  $alreadyConfigured = $name in split($::interfaces, ',')

  if !$alreadyConfigured {
    exec { "/bin/echo 'alias ifcfg-${interface} bonding' >> /etc/modprobe.d/bonding.conf":
    }->
    exec { "reload modprobe after ${interface} is added to bonding module config":
      command => '/sbin/modprobe -r bonding; /sbin/modprobe bonding',
    }->
    file { "ifcfg-${interface}.${vlanId}}":
      ensure  => 'present',
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      path    => "/etc/sysconfig/network-scripts/ifcfg-${interface}.${vlanId}",
      content => template('network/ifcfg-eth.erb'),
      notify => Service['network'],
    }
  }


} # define network::bond::vlan
