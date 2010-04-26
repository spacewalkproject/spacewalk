#!/usr/bin/python

from hwdata import PCI, USB

# for obtaining real id of your devices you can use package python-gudev

pci_vendor_id = '0e11'
pci_device_id = 'b01e'

usb_vendor_id = '03f0'
usb_device_id = '1f12'


pci = PCI()
print("Vendor: %s" % pci.get_vendor(pci_vendor_id))
print("Device: %s" % pci.get_device(pci_vendor_id, pci_device_id))


usb = USB()
print("Vendor: %s" % usb.get_vendor(usb_vendor_id))
print("Device: %s" % usb.get_device(usb_vendor_id, usb_device_id))



