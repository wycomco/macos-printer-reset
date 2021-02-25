#!/bin/bash

# This script will reset the printing system.
# It was inspired by http://www.cnet.com/news/what-does-the-reset-print-system-routine-in-os-x-do/
# This script should work for OS X 10.10 Yosemite and later. Pleas be aware that it has not been
# tested on macOS versions before 10.14 "Mojave".
#
# For macOS 10.15 "Catalina" and later the integrated printtool reset command will be used.

# Get macOS Version
majorVersion=$(sw_vers -productVersion | awk -F. '{ print $1; }')
minorVersion=$(sw_vers -productVersion | awk -F. '{ print $2; }')

# Use the appropriate reset method.
if [[ $majorVersion -ge 11 || $minorVersion -ge 15 ]]; then
  echo "Catalina or higher, using integrated command"
  /System/Library/Frameworks/ApplicationServices.framework/Frameworks/PrintCore.framework/Versions/A/printtool --reset -f
else
  echo "Mojave or lower, using integrated command"
  
  # Stop CUPS
  /bin/launchctl stop org.cups.cupsd
  
  # Backup Installed Printers Property List
  if [[ -e "/Library/Printers/InstalledPrinters.plist" ]]; then
      /bin/mv /Library/Printers/InstalledPrinters.plist /Library/Printers/InstalledPrinters.plist.bak
  fi
  
  # Backup the CUPS config file
  if [[ -e "/etc/cups/cupsd.conf" ]]; then
      /bin/mv /etc/cups/cupsd.conf /etc/cups/cupsd.conf.bak
  fi
  
  # Restore the default config by copying it
  if [[ ! -e "/etc/cups/cupsd.conf" ]]; then
      /bin/cp /etc/cups/cupsd.conf.default /etc/cups/cupsd.conf
  fi
  
  # Backup the printers config file
  if [[ -e "/etc/cups/printers.conf" ]]; then
      /bin/mv /etc/cups/printers.conf /etc/cups/printers.conf.bak
  fi
  
  # Start CUPS
  /bin/launchctl start org.cups.cupsd
  
  # Remove all printers
  /usr/bin/lpstat -p | /usr/bin/cut -d' ' -f2 | /usr/bin/xargs -I{} /usr/sbin/lpadmin -x {}
  
fi
