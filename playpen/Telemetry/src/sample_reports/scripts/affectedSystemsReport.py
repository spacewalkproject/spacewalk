#!/usr/bin/python

from telemetry import Report
import sys
import xmlrpclib

class Erratum():
    pass

class System():
    pass

def processData(client, key, errata):
    
    try:
        
        for erratum in errataList:
            
            print erratum
            
            e = client.errata.getDetails(key, erratum)
            
            if e:
                
                ee = Erratum()
                ee.advisoryName = erratum
                ee.type = e['type']
                ee.description = e['description']
                ee.synopsis = e['synopsis']
                ee.systems = []
                
                errata.append(ee)
                
                slist = client.errata.listAffectedSystems(key, erratum)
                
                for s in slist:
                    
                    system = System()
                    system.id = s['id']
                    system.name = s['name']
                    
                    ee.systems.append(system)
                    
    except xmlrpclib.Fault, fault:
        print "Error in systemDetailsReport.processData():"
        print fault.faultCode
        print fault.faultString
        sys.exit(1)
            
    return errata
    
# Main Processing 
if len(sys.argv) != 6:
    print "Usage %s <config> <type> <username> <password> <errata>" % (sys.argv[0])
    sys.exit(1)
    
# Arguments
config = sys.argv[1]
type = sys.argv[2]
username = sys.argv[3]
password = sys.argv[4]
errataList = sys.argv[5].split(',')

# Create Report Instance
report = Report(config)

# Get ServerProxies
clients = report.connect()

errata = []

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
        errata = []
        
        systems = processData(client,key,errata)
        satellites = [report.satellites[_count]]
        vars = {'errata': errata, 'satellites': satellites}
        report.templatify(vars, type)
        
    else:
        systems = processData(client,key,errata)
        
    _count = _count + 1
        
if (report.aggregate):
    vars = {'errata': errata, 'satellites': report.satellites}
    report.templatify(vars, type)
        
                                                               
    