# Cisco VPN for nerds on MacOS

This is a package containing an OpenConnect configuration script for MacOS
that allows you to fully control how the VPN connection is made, which routes
are added, and how the DNS are configured.

If you are tired of having all your private traffic go through the corporate
VPN, but you need it always up, this script is for you. It is MacOS and brew
centric, but if you know your way you can of course make it work with your
installation from source.

Enjoy!

## Setup

 * Create `/usr/local/etc/vpnc` and enter into it

        mkdir /usr/local/etc/vpnc
        cd /usr/local/etc/vpnc

 * Clone the sources into the `.source` directory

        git clone https://github.com/vjt/openconnect-macos .source

 * Install OpenConnect

        brew install openconnect

 * Install either the TUN driver via `brew install tuntap` or use the one bundled in [Tunnelblick](https://code.google.com/p/tunnelblick/)

    * Brew provides you instructions on how to set up the tuntap driver. Follow them and then:

             ln -s /Library/Extensions/tun.kext .

    * For TunnelBlick bundled driver:

             ln -s /Applications/Tunnelblick.app/Contents/Resources/tun.kext .

 * Copy the configuration file and set your username in it:

        cp .source/vpn.conf myvpn.conf
        vi myvpn.conf

 * Copy the network configuration script:

        cp .source/vpn.sh myvpn.sh

 * Grant yourself rights to start the VPN without password: run `sudo visudo` and add

        %admin ALL=(ALL) NOPASSWD: /usr/local/bin/openconnect

   at the end of the file.

 * Done!

## Connect the VPN

    openconnect --config /usr/local/etc/vpnc/myvpn.conf concentrator.example.com

## Disconnect the VPN

    Ctrl+C

## Advantages

 * Start the VPN straight from the Command Line
 * Only DNS requests for the corporate domain are routed through the VPN
 * Only corporate traffic is routed through the VPN, for more privacy, security, and reliability.

## License

    ----------------------------------------------------------------------------
    "THE BEER-WARE LICENSE" (Revision 42):
    <vjt@openssl.it> wrote this file. As long as you retain this notice you
    can do whatever you want with this stuff. If we meet some day, and you think
    this stuff is worth it, you can buy me a beer in return.

    - Marcello Barnaba
    ----------------------------------------------------------------------------
