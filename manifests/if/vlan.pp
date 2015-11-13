define network::if::vlan (
  $ensure,
  $vlanId,
  $ipaddress,
  $netmask,
  $macaddress      = undef,
  $gateway         = undef,
  $bootproto       = 'none',
  $userctl         = false,
  $mtu             = undef,
  $ethtool_opts    = undef,
  $peerdns         = false,
  $ipv6peerdns     = false,
  $dns1            = undef,
  $dns2            = undef,
  $domain          = undef,
  $linkdelay       = undef,
  $scope           = undef,
) {
# Validate data
  $states = [ '^up$', '^down$' ]
  validate_re($ensure, $states, '$ensure must be either "up" or "down".')

  if $ipaddress {
    if ! is_ip_address($ipaddress) { fail("${ipaddress} is not an IP address.") }
  }
  if $ipv6address {
    if ! is_ip_address($ipv6address) { fail("${ipv6address} is not an IPv6 address.") }
  }

  if is_mac_address($name){
    $interface = inline_template('<% interfaces.split(",").each do |ifn| %><% if name == scope.lookupvar("macaddress_#{ifn}") || name.downcase == scope.lookupvar("macaddress_#{ifn}") %><%= ifn %><% end %><% end %>')
    if !$interface {
      fail('Could not find the interface name for the given macaddress...')
    }
  } else {
    $interface = $name
  }

  $onboot = $ensure ? {
    'up'    => 'yes',
    'down'  => 'no',
    default => undef,
  }

  $numConfiguredInterfaces = inline_template('<% count = 0 %><% interfaces.split(",").each do |ifn| %><% if name == scope.lookupvar("macaddress_#{ifn}") || name.downcase == scope.lookupvar("macaddress_#{ifn}") %><% count += 1 %><% end %><% end %><%= count %>')

  if $numConfiguredInterfaces < 1 {
    file { "ifcfg-${interface}.${vlanId}}":
      ensure  => 'present',
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      path    => "/etc/sysconfig/network-scripts/ifcfg-${interface}.${vlanId}",
      content => template('network/ifcfg-eth.erb'),
    }
  }
} # define network::if::vlan