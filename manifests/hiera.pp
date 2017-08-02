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
  $network_alias = hiera_hash('network::alias', undef)
  $network_alias_range = hiera_hash('network::alias_range', undef)
  $network_bond = hiera_hash('network::bond', undef)
  $network_bond_bridge = hiera_hash('network::bond_bridge', undef)
  $network_bond_dynamic = hiera_hash('network::bond_dynamic', undef)
  $network_bond_slave = hiera_hash('network::bond_slave', undef)
  $network_bond_static = hiera_hash('network::bond_static', undef)
  $network_bridge = hiera_hash('network::bridge', undef)
  $network_bridge_dynamic = hiera_hash('network::bridge_dynamic', undef)
  $network_bridge_static = hiera_hash('network::bridge_static', undef)
  $network_if = hiera_hash('network::if', undef)
  $network_if_bridge = hiera_hash('network::if_bridge', undef)
  $network_if_dynamic = hiera_hash('network::if_dynamic', undef)
  $network_if_promisc = hiera_hash('network::if_promisc', undef)
  $network_if_static = hiera_hash('network::if_static', undef)
  $network_route = hiera_hash('network::route', undef)

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
