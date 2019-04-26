# Acceptable values for BOOTPROTO
#
# Only "dhcp" and "bootp" are used in /etc/sysconfig/network-scripts
#
# "static" and "none" are used in some parts of the module,
# and those values have no side effects, so we accept them too.
#
type Network::If::Bootproto = Enum['none', 'static', 'dhcp', 'bootp']
