# == Definition: network::if::static
#
# Creates a normal interface with static IP address.
#
# === Parameters:
#
#   $ensure         - required - up|down
#   $ipaddress      - optional
#   $netmask        - optional
#   $gateway        - optional
#   $ipv6address    - optional
#   $ipv6init       - optional - defaults to false
#   $ipv6gateway    - optional
#   $manage_hwaddr  - optional - defaults to true
#   $macaddress     - optional - defaults to macaddress_$title
#   $ipv6autoconf   - optional - defaults to false
#   $userctl        - optional - defaults to false
#   $mtu            - optional
#   $ethtool_opts   - optional
#   $peerdns        - optional
#   $ipv6peerdns    - optional - defaults to false
#   $dns1           - optional
#   $dns2           - optional
#   $domain         - optional
#   $scope          - optional
#   $flush          - optional
#   $zone           - optional
#   $metric         - optional
#   $defroute       - optional
#   $restart        - optional - defaults to true
#   $arpcheck       - optional - defaults to true
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Sample Usage:
#
#   network::if::static { 'eth0':
#     ensure      => 'up',
#     ipaddress   => '10.21.30.248',
#     netmask     => '255.255.255.128',
#     macaddress  => $::macaddress_eth0,
#     domain      => 'is.domain.com domain.com',
#     ipv6init    => true,
#     ipv6address => '123:4567:89ab:cdef:123:4567:89ab:cdef',
#     ipv6gateway => '123:4567:89ab:cdef:123:4567:89ab:1',
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2011 Mike Arnold, unless otherwise noted.
#
define network::if::static (
  $ensure,
  $ipaddress = undef,
  $netmask = undef,
  $gateway = undef,
  $ipv6address = undef,
  $ipv6init = false,
  $ipv6gateway = undef,
  $macaddress = undef,
  $manage_hwaddr = true,
  $ipv6autoconf = false,
  $userctl = false,
  $mtu = undef,
  $ethtool_opts = undef,
  $peerdns = false,
  $ipv6peerdns = false,
  $dns1 = undef,
  $dns2 = undef,
  $domain = undef,
  $linkdelay = undef,
  $scope = undef,
  $flush = false,
  $zone = undef,
  $defroute = undef,
  $metric = undef,
  $restart = true,
  $arpcheck = true,
) {
  # Validate our data
  if $ipaddress {
    if ! is_ip_address($ipaddress) { fail("${ipaddress} is not an IP address.") }
  }
  if is_array($ipv6address) {
    if size($ipv6address) > 0 {
      validate_ip_address { $ipv6address: }
      $primary_ipv6address = $ipv6address[0]
      $secondary_ipv6addresses = delete_at($ipv6address, 0)
    }
  } elsif $ipv6address {
    if ! is_ip_address($ipv6address) { fail("${ipv6address} is not an IPv6 address.") }
    $primary_ipv6address = $ipv6address
    $secondary_ipv6addresses = undef
  } else {
    $primary_ipv6address = undef
    $secondary_ipv6addresses = undef
  }

  if ! is_mac_address($macaddress) {
    # Strip off any tailing VLAN (ie eth5.90 -> eth5).
    $title_clean = regsubst($title,'^(\w+)\.\d+$','\1')
    $macaddy = getvar("::macaddress_${title_clean}")
  } else {
    $macaddy = $macaddress
  }
  # Validate booleans
  validate_bool($userctl)
  validate_bool($ipv6init)
  validate_bool($ipv6autoconf)
  validate_bool($peerdns)
  validate_bool($ipv6peerdns)
  validate_bool($manage_hwaddr)
  validate_bool($flush)
  validate_bool($arpcheck)

  network_if_base { $title:
    ensure          => $ensure,
    ipv6init        => $ipv6init,
    ipaddress       => $ipaddress,
    ipv6address     => $primary_ipv6address,
    netmask         => $netmask,
    gateway         => $gateway,
    ipv6gateway     => $ipv6gateway,
    ipv6autoconf    => $ipv6autoconf,
    ipv6secondaries => $secondary_ipv6addresses,
    macaddress      => $macaddy,
    manage_hwaddr   => $manage_hwaddr,
    bootproto       => 'none',
    userctl         => $userctl,
    mtu             => $mtu,
    ethtool_opts    => $ethtool_opts,
    peerdns         => $peerdns,
    ipv6peerdns     => $ipv6peerdns,
    dns1            => $dns1,
    dns2            => $dns2,
    domain          => $domain,
    linkdelay       => $linkdelay,
    scope           => $scope,
    flush           => $flush,
    zone            => $zone,
    defroute        => $defroute,
    metric          => $metric,
    restart         => $restart,
    arpcheck        => $arpcheck,
  }
} # define network::if::static
