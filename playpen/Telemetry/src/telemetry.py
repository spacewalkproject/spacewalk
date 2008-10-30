#!/usr/bin/env python

import xmlrpclib
import csv
import sys
import os
import time
from datetime import datetime
import yaml
import Cheetah.Template as Template

def templatify(template, answers, output):
    t = Template.Template(file=template, searchList=answers)
    open(output,"w").write(t.respond())

class Report():
    
    parameters = None
     
    def __init__(self, config):
         
        # Open & parse Configuration file
        config_dir = "/usr/share/telemetry/config/"
        config_file = os.path.join(config_dir, config)
    
        f = open(config_file, 'r')
        self.parameters =  yaml.load(f)
        
        f.close()
        
    def connect(self):
    
        clients = []
        
        # Create connections to all Satellites
        for satellite in self.parameters['Satellites']:
            
            client = xmlrpclib.ServerProxy(satellite, verbose=0)
            
            # Validate API version
            apiV = client.api.getVersion()
            
            if (apiV in self.parameters['APIVersions']):
                clients.append(client)
            else:
                print "Error: API Version Mismatch."
                print "Version Required: %s" % self.parameters['APIVersion']
                print "Satellite is: %s" % apiV
                print "%s will not be added." % satellite
            
        return clients
    
    def templatify(self, vars, type):

        template_dir = "/usr/share/telemetry/templates/"
        
        # Retrieve Template from Type
        template_file = os.path.join(template_dir, self.parameters['Templates'][type])
        
        report_dir = self.parameters['Report_Dir']
        
        if not os.path.exists(report_dir):
            os.makedirs(report_dir)
            
        now = datetime.now().strftime("%Y-%m-%d:%H:%M:%S");
        report_name = "%s.%s.%s" % (self.parameters['Report_Name'], now, type)
        report_file = os.path.join(report_dir, report_name)

        templatify(template_file, vars, report_file)  