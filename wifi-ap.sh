# Copyright (c) 2016 Joseph D Poirier
# Distributable under the terms of The New BSD License
# that can be found in the LICENSE file.

#### files created and/or modified
# /etc/default/isc-dhcp-server
# /etc/hostapd/hostapd.conf
# /etc/network/interfaces
# /usr/sbin/stratux-wifi.sh


if [ $(whoami) != 'root' ]; then
    echo "${RED}This script must be executed as root, exiting...${WHITE}"
    exit
fi

rm -f /etc/rc*.d/*hostapd
rm -f /etc/network/if-pre-up.d/hostapd
rm -f /etc/network/if-post-down.d/hostapd
rm -f /etc/init.d/hostapd
rm -f /etc/default/hostapd

# what wifi interface, e.g. wlan0, wlan1..., uses the first one found
#wifi_interface=$(lshw -quiet -c network | sed -n -e '/Wireless interface/,+12 p' | sed -n -e '/logical name:/p' | cut -d: -f2 | sed -e 's/ //g')
wifi_interface=wlan0

echo "${MAGENTA}Configuring $wifi_interface interface...${WHITE}"


##############################################################
## Setup DHCP server for IP address management
##############################################################
echo
echo "${YELLOW}**** Setup DHCP server for IP address management *****${WHITE}"

### set /etc/default/isc-dhcp-server
cp -n /etc/default/isc-dhcp-server{,.bak}
cat <<EOT > /etc/default/isc-dhcp-server
INTERFACES="$wifi_interface"
EOT

### set /etc/dhcp/dhcpd.conf
cp -n /etc/dhcp/dhcpd.conf{,.bak}
cp -f ${SCRIPTDIR}/files/dhcpd.conf /etc/dhcp/dhcpd.conf

echo "${GREEN}...done${WHITE}"


##############################################################
## Copy hostapd-edimax.conf and hostapd.conf
##############################################################
echo
echo "${YELLOW}**** Copy hostapd-edimax.conf and hostapd.conf *****${WHITE}"

cp -f ${SCRIPTDIR}/files/hostapd-edimax.conf /etc/hostapd/hostapd-edimax.conf
cp -f ${SCRIPTDIR}/files/hostapd.conf /etc/hostapd/hostapd.conf

echo "${GREEN}...done${WHITE}"


##############################################################
## Setup /etc/network/interfaces
##############################################################
echo
echo "${YELLOW}**** Setup /etc/network/interfaces *****${WHITE}"

cp -n /etc/network/interfaces{,.bak}

cat <<EOT > /etc/network/interfaces
auto lo

iface lo inet loopback
iface eth0 inet dhcp

allow-hotplug wlan0

iface wlan0 inet static
  address 192.168.10.1
  netmask 255.255.255.0
  post-up /usr/sbin/stratux-wifi.sh
EOT

echo "${GREEN}...done${WHITE}"


#################################################
## Setup /usr/sbin/stratux-wifi.sh
#################################################
echo
echo "${YELLOW}**** Setup /usr/sbin/stratux-wifi.sh *****${WHITE}"

# we use a slightly modified version to handle more hardware scenarios
chmod 755 ${SCRIPTDIR}/files/stratux-wifi.sh
cp ${SCRIPTDIR}/files/stratux-wifi.sh /usr/sbin/stratux-wifi.sh

echo "${GREEN}...done${WHITE}"
