#!/bin/sh

# Full path to your VPN configuration
VPN_CONF=/full/path/to/your/vpn.conf

# FQDN of your VPN concentrator
VPN_CONCENTRATOR=concentrator.example.org

sudo openconnect -U `whoami` --config "$VPN_CONF" "$@" "$VPN_CONCENTRATOR"
