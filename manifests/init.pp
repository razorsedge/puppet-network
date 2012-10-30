# Class: network
#
# This module manages Red Hat/Fedora network configuration.
#
class network {
  # Only run on RedHat derived systems.
  case $::osfamily {
    RedHat: { }
    default: {
      fail("This network module only supports Red Hat-based systems.")
    }
  }
} # class network
