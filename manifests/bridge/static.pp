# == Definition: network::bridge::static
#
# Creates a bridge interface with static IP address.
#
# === Parameters:
#
#   $ensure        - required - up|down
#   $ipaddress     - optional
#   $netmask       - optional
#   $gateway       - optional
#   $ipv6address   - optional
#   $ipv6gateway   - optional
#   $userctl       - optional - defaults to false
#   $peerdns       - optional - defaults to false
#   $ipv6init      - optional - defaults to false
#   $ipv6peerdns   - optional - defaults to false
#   $dns1          - optional
#   $dns2          - optional
#   $domain        - optional
#   $stp           - optional - defaults to false
#   $delay         - optional - defaults to 30
#   $bridging_opts - optional
#   $scope         - optional
#   $restart       - optional - defaults to true
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Sample Usage:
#
#   network::bridge::static { 'br0':
#     ensure        => 'up',
#     ipaddress     => '10.21.30.248',
#     netmask       => '255.255.255.128',
#     domain        => 'is.domain.com domain.com',
#     stp           => true,
#     delay         => '0',
#     bridging_opts => 'priority=65535',
#   }
#
# === Authors:
#
# David Cote
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2013 David Cote, unless otherwise noted.
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
#
define network::bridge::static (
  Enum['up', 'down'] $ensure,
  Optional[Stdlib::IP::Address::V4::Nosubnet] $ipaddress = undef,
  Optional[Stdlib::IP::Address::V4::Nosubnet] $netmask = undef,
  Optional[Stdlib::IP::Address::V4::Nosubnet] $gateway = undef,
  Optional[Stdlib::IP::Address::V6] $ipv6address = undef,
  Optional[Stdlib::IP::Address::V6::Nosubnet] $ipv6gateway = undef,
  Network::If::Bootproto $bootproto = 'static',
  Boolean $userctl = false,
  Boolean $peerdns = false,
  Boolean $ipv6init = false,
  Boolean $ipv6peerdns = false,
  Optional[Stdlib::IP::Address::Nosubnet] $dns1 = undef,
  Optional[Stdlib::IP::Address::Nosubnet] $dns2 = undef,
  Optional[String] $domain = undef,
  Boolean $stp = false,
  String $delay = '30',
  Optional[String] $bridging_opts = undef,
  Optional[String] $scope = undef,
  Boolean $restart = true,
) {

  network::bridge { $title:
    ensure        => $ensure,
    ipaddress     => $ipaddress,
    netmask       => $netmask,
    gateway       => $gateway,
    ipv6address   => $ipv6address,
    ipv6gateway   => $ipv6gateway,
    bootproto     => $bootproto,
    userctl       => $userctl,
    peerdns       => $peerdns,
    ipv6init      => $ipv6init,
    ipv6peerdns   => $ipv6peerdns,
    dns1          => $dns1,
    dns2          => $dns2,
    domain        => $domain,
    stp           => $stp,
    delay         => $delay,
    bridging_opts => $bridging_opts,
    scope         => $scope,
    restart       => $restart,
  }

} # define network::bridge::static
