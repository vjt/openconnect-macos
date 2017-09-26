#!/bin/sh
#* reason                       -- why this script was called, one of: pre-init connect disconnect
#* VPNGATEWAY                   -- vpn gateway address (always present)
#* TUNDEV                       -- tunnel device (always present)
#* INTERNAL_IP4_ADDRESS         -- address (always present)
#* INTERNAL_IP4_NETMASK         -- netmask (often unset)
#* INTERNAL_IP4_NETMASKLEN      -- netmask length (often unset)
#* INTERNAL_IP4_NETADDR         -- address of network (only present if netmask is set)
#* INTERNAL_IP4_DNS             -- list of dns serverss
#* INTERNAL_IP4_NBNS            -- list of wins servers
#* CISCO_DEF_DOMAIN             -- default domain name
#* CISCO_BANNER                 -- banner from server
#* CISCO_SPLIT_INC              -- number of networks in split-network-list
#* CISCO_SPLIT_INC_%d_ADDR      -- network address
#* CISCO_SPLIT_INC_%d_MASK      -- subnet mask (for example: 255.255.255.0)
#* CISCO_SPLIT_INC_%d_MASKLEN   -- subnet masklen (for example: 24)
#* CISCO_SPLIT_INC_%d_PROTOCOL  -- protocol (often just 0)
#* CISCO_SPLIT_INC_%d_SPORT     -- source port (often just 0)
#* CISCO_SPLIT_INC_%d_DPORT     -- destination port (often just 0)

PATH=/sbin:/usr/sbin:/bin:/usr/bin

# Override DNS servers, if needed
#INTERNAL_IP4_DNS="10.0.0.1 10.0.0.2"

# Specify here the routes you want to add
INTERNAL_ROUTES="10.3.0.0/16"

configure_iface () {
  ip link set dev "$TUNDEV" up mtu ${INTERNAL_IP4_MTU:-1412}
  ip addr add "$INTERNAL_IP4_ADDRESS/32" peer "$INTERNAL_IP4_ADDRESS" dev "$TUNDEV"
}

set_routes() {
  for route in $INTERNAL_ROUTES; do
    ip route replace "$route" dev "$TUNDEV"
  done
}

unset_routes() {
  for route in $INTERNAL_ROUTES; do
    ip route delete "$route" dev "$TUNDEV"
  done
}

case "$reason" in
  pre-init)
    ;;
  connect)
    mkdir -p /var/run/vpnc
    configure_iface
    set_routes
    ;;
  disconnect)
    unset_routes
    ;;
  *)
    exit 0
    ;;
esac

exit 0
