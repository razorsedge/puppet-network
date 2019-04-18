# == Definition: validate_ip_address
#
# This definition can be used to call is_ip_address on an array of ip addresses.
#
# === Parameters:
#
# None
#
# === Actions:
#
# Runs is_ip_address on the name of the define and fails if it is not a valid IP address.
#
# === Sample Usage:
#
# $ips = [ '10.21.30.248', '123:4567:89ab:cdef:123:4567:89ab:cdef' ]
# validate_ip_address { $ips: }
#
define network::validate_ip_address {
  if ! is_ip_address($name) { fail("${name} is not an IP(v6) address.") }
}
