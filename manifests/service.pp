# == Class: network::service
#
# Restarts the network if notified
#
# === Authors:
#
# Manfred Pusch <manfred@pusch.cc>
#
# === Copyright:
#
# Copyright (C) 2020 Manfred Pusch, unless otherwise noted.
#
class network::service (
  $restart = true,
) {
  # Validate our data
  validate_bool($restart)

  if $restart {
    if versioncmp($::operatingsystemrelease, '8') >= 0 {
      exec { 'restart_network':
        command     => '/usr/bin/nmcli networking off ; /usr/bin/systemctl restart NetworkManager ; /usr/bin/nmcli networking on',
        group       => 'root',
        user        => 'root',
        refreshonly => true,
      }
    } else {
      service { 'network':
        ensure     => 'running',
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
        provider   => 'redhat',
      }
    }
  }
} # Class: network::service
