# == Definition: network::bridge::dynamic
#
# Creates a bridge interface with dynamic IP information.
#
# === Parameters:
#
#   $ensure        - required - up|down
#   $bootproto     - optional - defaults to "dhcp"
#   $userctl       - optional - defaults to false
#   $stp           - optional - defaults to false
#   $delay         - optional - defaults to 30
#   $bridging_opts - optional
#   $restart       - optional - defaults to true
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Sample Usage:
#
#   network::bridge::dynamic { 'br1':
#     ensure        => 'up',
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
define network::bridge::dynamic (
  Enum['up', 'down'] $ensure,
  Network::If::Bootproto $bootproto = 'dhcp',
  Boolean $userctl = false,
  Boolean $stp = false,
  String $delay = '30',
  Optional[String] $bridging_opts = undef,
  Boolean $restart = true,
) {

  network::bridge { $title:
    ensure        => $ensure,
    bootproto     => $bootproto,
    userctl       => $userctl,
    stp           => $stp,
    delay         => $delay,
    bridging_opts => $bridging_opts,
    restart       => $restart,
  }

} # define network::bridge::dynamic
