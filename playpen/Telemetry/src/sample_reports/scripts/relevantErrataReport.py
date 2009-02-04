#!/usr/bin/python

from telemetry import Report
import sys
import xmlrpclib

class SystemGroup():
    pass
        
class System():
    pass

class Erratum():
    pass

def processData(client, key, systemsGroups):
    
    try:
        # Get All SystemGroups on Satellite
        sGroups = client.systemgroup.listAllGroups(key)
    
        for sGroup in sGroups:
    
            systemGroup = SystemGroup()
            systemGroup.name = sGroup['name']
            systemGroups.append(systemGroup)
    
            systems = client.systemgroup.listSystems(key, sGroup['name'])
    
            systemGroup.systems = []
    
            for system in systems:
        
                sys = System()
                sys.profile_name = system['profile_name']
                sys.id = system['id']
                systemGroup.systems.append(sys)
        
                errata = client.system.getRelevantErrata(key, system['id'])
        
                sys.errata = []
        
                for erratum in errata:
        
                    e = Erratum()
                    e.advisory_name = erratum['advisory_name']
                    e.advisory_type = erratum['advisory_type']
                    e.advisory_summary = erratum['advisory_synopsis']
                    sys.errata.append(e)
        
    except xmlrpclib.Fault, fault:
        print "Error in relevantErrataReport.processData():"
        print fault.faultCode
        print fault.faultString
        sys.exit(1)
            
    return systemGroups
        

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

systemGroups = []

_count = 0

# Get ServerProxies
clients = report.connect()

for client in clients:
    
    # get the session key
    try:
        key = client.auth.login(username, password)
    except xmlrpclib.Fault, fault:
        print "Error in relevantErrataReport:"
        print fault.faultCode
        print fault.faultString
        sys.exit(1)
        
    if not (report.aggregate):
        systemGroups = []
    
        systemGroups = processData(client,key,systemGroups)
        satellites = [report.satellites[_count]]
        vars = {'systemGroups': systemGroups, 'satellites': satellites}
        report.templatify(vars, type)
    
    else:
        systemGroups = processData(client,key,systemGroups)
    
    _count = _count + 1
        
if (report.aggregate):
    vars = {'systemGroups': systemGroups, 'satellites': report.satellites}
    report.templatify(vars, type)

                                                        
