# == Class: network::hiera
#
# This module enables network configuration for defines out of hiera.
#
# === Parameters:
#
# None
#
# === Actions:
#
# Enables the use of hiera hashes via create_resources.
#
# === Requires:
#
#   Service['network']
#
# === Sample Usage:
#
#   include '::network::hiera'
#
# === Authors:
#
# Elyse Salberg <elyse_salberg@putnam.com>
#
# === Copyright:
#
# Copyright (C) 2015 Elyse Salberg, unless otherwise noted.
#
class network::hiera {
  # Merge hashes from multiple hiera layers
  $network_alias = lookup('network::alias', Optional[Hash], 'hash', undef)
  $network_alias_range = lookup(
    'network::alias_range', Optional[Hash], 'hash', undef)
  $network_bond = lookup('network::bond', Optional[Hash], 'hash', undef)
  $network_bond_bridge = lookup(
    'network::bond_bridge', Optional[Hash], 'hash', undef)
  $network_bond_dynamic = lookup(
    'network::bond_dynamic', Optional[Hash], 'hash', undef)
  $network_bond_slave = lookup(
    'network::bond_slave', Optional[Hash], 'hash', undef)
  $network_bond_static = lookup(
    'network::bond_static', Optional[Hash], 'hash', undef)
  $network_bridge = lookup('network::bridge', Optional[Hash], 'hash', undef)
  $network_bridge_dynamic = lookup(
    'network::bridge_dynamic', Optional[Hash], 'hash', undef)
  $network_bridge_static = lookup(
    'network::bridge_static', Optional[Hash], 'hash', undef)
  $network_if = lookup('network::if', Optional[Hash], 'hash', undef)
  $network_if_bridge = lookup(
    'network::if_bridge', Optional[Hash], 'hash', undef)
  $network_if_dynamic = lookup(
    'network::if_dynamic', Optional[Hash], 'hash', undef)
  $network_if_promisc = lookup(
    'network::if_promisc', Optional[Hash], 'hash', undef)
  $network_if_static = lookup(
    'network::if_static', Optional[Hash], 'hash', undef)
  $network_route = lookup('network::route', Optional[Hash], 'hash', undef)

  if $network_alias {
    create_resources('network::alias', $network_alias)
  }
  if $network_alias_range {
    create_resources('network::alias::range', $network_alias_range)
  }
  if $network_bond {
    create_resources('network::bond', $network_bond)
  }
  if $network_bond_bridge {
    create_resources('network::bond::bridge', $network_bond_bridge)
  }
  if $network_bond_dynamic {
    create_resources('network::bond::dynamic', $network_bond_dynamic)
  }
  if $network_bond_slave {
    create_resources('network::bond::slave', $network_bond_slave)
  }
  if $network_bond_static {
    create_resources('network::bond::static', $network_bond_static)
  }
  if $network_bridge {
    create_resources('network::bridge', $network_bridge)
  }
  if $network_bridge_dynamic {
    create_resources('network::bridge::dynamic', $network_bridge_dynamic)
  }
  if $network_bridge_static {
    create_resources('network::bridge::static', $network_bridge_static)
  }
  if $network_if {
    create_resources('network::if', $network_if)
  }
  if $network_if_bridge {
    create_resources('network::if::bridge', $network_if_bridge)
  }
  if $network_if_dynamic {
    create_resources('network::if::dynamic', $network_if_dynamic)
  }
  if $network_if_promisc {
    create_resources('network::if::promisc', $network_if_promisc)
  }
  if $network_if_static {
    create_resources('network::if::static', $network_if_static)
  }
  if $network_route {
    create_resources('network::route', $network_route)
  }
}
