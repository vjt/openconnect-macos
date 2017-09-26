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
INTERNAL_ROUTES="10.42.0.0/24 172.31.33.0/24"

# Specify here the service name, if you want to run multiple VPNs at the same time.
SERVICE_NAME="org.foobar.myvpn"

configure_iface () {
  ifconfig "$TUNDEV" inet "$INTERNAL_IP4_ADDRESS" "$INTERNAL_IP4_ADDRESS" \
    netmask 255.255.255.255 mtu ${INTERNAL_IP4_MTU:-1412} up
}

set_routes() {
  for route in $INTERNAL_ROUTES; do
    route add "$route" -iface "$TUNDEV" >/dev/null
  done
}

set_dns() {
  sudo scutil <<EOF
    d.init
    d.add Addresses * $INTERNAL_IP4_ADDRESS
    d.add DestAddresses * $INTERNAL_IP4_ADDRESS
    d.add InterfaceName $TUNDEV
    set State:/Network/Service/$SERVICE_NAME/IPv4

    d.init
    d.add SupplementalMatchDomains * $CISCO_DEF_DOMAIN
    d.add ServerAddresses * $INTERNAL_IP4_DNS
    set State:/Network/Service/$SERVICE_NAME/DNS
EOF
}

unset_dns() {
  sudo scutil <<EOF
    remove State:/Network/Service/$SERVICE_NAME/DNS
    remove State:/Network/Service/$SERVICE_NAME/IPv4
EOF
}

case "$reason" in
  pre-init)
    ;;
  connect)
    mkdir -p /var/run/vpnc
    configure_iface
    set_dns
    set_routes
    ;;
  disconnect)
    unset_dns
    ;;
  *)
    exit 0
    ;;
esac

exit 0
