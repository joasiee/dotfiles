#!/bin/sh
if [ "${1}" == "pre" ]; then
  modprobe -r xhci_pci
elif [ "${1}" == "post" ]; then
  modprobe xhci_pci
fi
