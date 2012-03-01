# Class: network
#
# This module manages Red Hat/Fedora network configuration.
#
class network {
  # Only run on RedHat derived systems.
  case $operatingsystem {
    centos, redhat, fedora, oel: {
      notify { "Configuring network for ${operatingsystem}.":; }
    }
    default: {
      fail("The puppet-network module only supports Red Hat-style systems.")
    }
  }

} # class network
