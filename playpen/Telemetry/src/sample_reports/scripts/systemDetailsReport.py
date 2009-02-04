#!/usr/bin/python

from telemetry import Report
import sys
import xmlrpclib

class System():
    pass

class Entitlement():
    pass

class BaseChannel():
    pass

class ChildChannel():
    pass

class Group():
    pass

def processData(client, key, systems):
    
    try:
        syss = client.system.list_user_systems(key)
        
        for sys in syss:
            
            system = System()
            system.id = sys['id']
            system.name = sys['name']
    
            systems.append(system)
            
            entitlements = client.system.getEntitlements(key, int(sys['id']))
            
            system.entitlements = []
            
            for entitlement in entitlements:
                
                e = Entitlement()
                e.label = entitlement
                
                system.entitlements.append(e)
                
            childchannels = client.system.listSubscribedChildChannels(key, int(sys['id']))
            
            system.childchannels = []
            
            for childchannel in childchannels:
                
                cc = ChildChannel()
                cc.id = childchannel['id']
                cc.name = childchannel['name']
                cc.label = childchannel['label']
                
                system.childchannels.append(cc)
                
            basechannel = client.system.getSubscribedBaseChannel(key, int(sys['id']))
                                                                      
            bc = BaseChannel()
            bc.id = basechannel['id']
            bc.name = basechannel['name']
            bc.label = basechannel['label']
            
            system.basechannel = bc
                
            groups = client.system.listGroups(key, int(sys['id']))
            
            system.groups = []
            
            for group in groups:
                
                if group['subscribed']:
                    
                    g = Group()
                    g.sgid = group['sgid']
                    g.name = group['system_group_name']
                    
                    system.groups.append(g)
                    
    except xmlrpclib.Fault, fault:
        print "Error in systemDetailsReport.processData():"
        print fault.faultCode
        print fault.faultString
        sys.exit(1)
            
    return systems
    
# Main Processing 
if len(sys.argv) != 5:
    print "Usage %s <config> <type> <username> <password>" % (sys.argv[0])
    sys.exit(1)
    
# Arguments
config = sys.argv[1]
type = sys.argv[2]
username = sys.argv[3]
password = sys.argv[4]

# Create Report Instance
report = Report(config)

# Get ServerProxies
clients = report.connect()

systems = []

_count = 0

for client in clients:
    
    # get the session key
    try:
        key = client.auth.login(username, password)
    except xmlrpclib.Fault, fault:
        print "Error in systemDetailsReport:"
        print fault.faultCode
        print fault.faultString
        sys.exit(1)
    
    if not (report.aggregate):
        systems = []
        
        systems = processData(client,key,systems)
        satellites = [report.satellites[_count]]
        vars = {'systems': systems, 'satellites': satellites}
        report.templatify(vars, type)
        
    else:
        systems = processData(client,key,systems)
        
    _count = _count + 1
        
if (report.aggregate):
    vars = {'systems': systems, 'satellites': report.satellites}
    report.templatify(vars, type)
        
                                                               
    