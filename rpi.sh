# Copyright (c) 2016 Joseph D Poirier
# Distributable under the terms of The New BSD License
# that can be found in the LICENSE file.

echo "${MAGENTA}"
echo "************************************"
echo "****** Raspberry Pi setup... *******"
echo "************************************"
echo "${WHITE}"


rpi_02_boards=("$RPI2BxREV" "$RPI2ByREV" "$RPI0xREV" "$RPI0yREV" "$RPI0wREV")

##############################################################
##  Boot config settings
##############################################################
echo
echo "${YELLOW}**** Boot config settings... *****${WHITE}"

if ! grep -q "dtparam=audio=on" "/boot/config.txt"; then
    echo "dtparam=audio=on" >>/boot/config.txt
fi

if [[ "rpi_02_boards" =~ "${REVISION}" ]]; then
    if ! grep -q "max_usb_current=1" "/boot/config.txt"; then
        echo "max_usb_current=1" >>/boot/config.txt
    fi
fi

if ! grep -q "dtparam=i2c1=on" "/boot/config.txt"; then
    echo "dtparam=i2c1=on" >>/boot/config.txt
fi

if ! grep -q "dtparam=i2c1_baudrate=400000" "/boot/config.txt"; then
    echo "dtparam=i2c1_baudrate=400000" >>/boot/config.txt
fi

if ! grep -q "dtparam=i2c_arm_baudrate=400000" "/boot/config.txt"; then
    echo "dtparam=i2c_arm_baudrate=400000" >>/boot/config.txt
fi

if ! grep -q "dtparam=act_led_trigger=none" "/boot/config.txt"; then
    echo "dtparam=act_led_trigger=none" >>/boot/config.txt
fi

if ! grep -q "dtparam=act_led_activelow=off" "/boot/config.txt"; then
    echo "dtparam=act_led_activelow=off" >>/boot/config.txt
fi

if [ "$REVISION" == "$RPI3BxREV" ] || [ "$REVISION" == "$RPI3ByREV" ]; then
    # move RPi3 Bluetooth off of hardware UART to free up connection for GPS
    if ! grep -q "dtoverlay=pi3-miniuart-bt" "/boot/config.txt"; then
        echo "dtoverlay=pi3-miniuart-bt" >>/boot/config.txt
    fi
    
    if ! grep -q "arm_freq=900" "/boot/config.txt"; then
        echo "arm_freq=900" >>/boot/config.txt
    fi

    if ! grep -q "sdram_freq=450" "/boot/config.txt"; then
        echo "sdram_freq=450" >>/boot/config.txt
    fi

    if ! grep -q "core_freq=450" "/boot/config.txt"; then
        echo "core_freq=450" >>/boot/config.txt
    fi
fi

echo "${GREEN}...done${WHITE}"


##############################################################
##  Disable serial console
##############################################################
echo
echo "${YELLOW}**** Disable serial console... *****${WHITE}"

sed -i /boot/cmdline.txt -e "s/console=ttyAMA0,[0-9]\+ //"

echo "${GREEN}...done${WHITE}"


##############################################################
##  Install hostapd-edimax binary
##############################################################
echo
echo "${YELLOW}**** Install hostapd-edimax binary... *****${WHITE}"

rm -f /usr/sbin/hostapd-edimax
cd ${SCRIPTDIR}/files

# gunzip -k hostapd.gz
gunzip -c hostapd.gz >hostapd
if [ ! -f ./hostapd ]; then
    echo "${BOLD}${RED}ERROR - hostapd doesn't exist, exiting...${WHITE}${NORMAL}"
    exit
fi

# install the binary
chmod 755 /usr/sbin/hostapd-edimax
mv ./hostapd /usr/sbin/hostapd-edimax

if [[ "rpi_02_boards" =~ "${REVISION}" ]]; then
    if ! grep -q "options 8192cu rtw_power_mgnt=0 rtw_enusbss=0" "/etc/modprobe.d/8192cu.conf"; then
        echo "options 8192cu rtw_power_mgnt=0 rtw_enusbss=0" >>/etc/modprobe.d/8192cu.conf
    fi
fi

echo "${GREEN}...done${WHITE}"


##############################################################
##  I2C setup
##############################################################
echo
echo "${YELLOW}**** I2C setup... *****${WHITE}"

if ! grep -q "i2c-bcm2708" "/etc/modules"; then
    echo "i2c-bcm2708" >>/etc/modules
fi

if ! grep -q "i2c-dev" "/etc/modules"; then
    echo "i2c-dev" >>/etc/modules
fi

echo "${GREEN}...done${WHITE}"
