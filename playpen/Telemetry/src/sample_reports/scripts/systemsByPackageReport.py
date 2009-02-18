#!/usr/bin/python

import sys
import xmlrpclib
from telemetry import Report

class System():
    pass

class Package():
    pass

def comparePkgs(system_packages, packageList):

    common_packages = []

    for pkg in packageList:

        for package in system_packages:

            if pkg == package['name']:
  
                common_packages.append(package)

    return common_packages 

def processData(client, key, systems):

    try:
        user_systems = client.system.listUserSystems(key)

        for system in user_systems:

            print system

            sys_packages = client.system.listPackages(key, int(system['id']))

            #returns a array of packages installed on the system that are in common with the user provided list
            common_pkgs = comparePkgs(sys_packages, packages)

            if len(common_pkgs) > 0:
                
                sys = System()
                sys.id = system['id']
                sys.name = system['name']
                sys.packages = common_pkgs
                systems.append(sys)


    except xmlrpclib.Fault, fault:
        print "Error in systemDetailsReport.processData():"
        print fault.faultCode
        print fault.faultString
        sys.exit(1)

    return systems

# Main Processing
if len(sys.argv) != 6:
    print "Usage %s <config> <type> <username> <password> <packagelist>" % (sys.argv[0])
    sys.exit(1)

# Arguments
config = sys.argv[1]
type = sys.argv[2]
username = sys.argv[3]
password = sys.argv[4]
packages = sys.argv[5].split(",")

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
        print "Error in systemByPackageReport:"
        print fault.faultCode
        print fault.faultString
        sys.exit(1)

    if not (report.aggregate):
        systems = []

        systems = processData(client,key,systems)
        satellites = [report.satellites[_count]]
        vars = {'systems': systems, 'satellites': satellites, 'criteria': sys.argv[5]}
        report.templatify(vars, type)

    else:
        systems = processData(client,key,systems)

    _count = _count + 1

if (report.aggregate):
    vars = {'systems': systems, 'satellites': report.satellites, 'criteria': sys.argv[5]}
    report.templatify(vars, type)



