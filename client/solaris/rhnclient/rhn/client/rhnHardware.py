#!/usr/bin/python

import rhnAuth
import xmlrpclib
import rpcServer
import hardware



def updateHardware():
    registered =  rhnAuth.getSystemId()
    if not registered:
        print "system not registered"
        sys.exit(1)

    try:
        rhnAuth.updateLoginInfo()
    except xmlrpclib.Fault, f:
        faultError(f.faultString)
        sys.exit(1)
    except rhnErrors.ServerCapabilityError, e:
        print e
        sys.exit(1)
    except rhnErrors.CommunicationError, e:
        print e
        sys.exit(1)

    #print _("Updating package profile...")

    s = rpcServer.getServer()
    
    hardwareList = hardware.Hardware()
    s.registration.refresh_hw_profile(registered, hardwareList)
