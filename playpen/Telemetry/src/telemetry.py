#!/usr/bin/env python

import xmlrpclib
import csv
import sys
import os
import time
from datetime import datetime
import yaml
import Cheetah.Template as Template
import smtplib

def templatify(template, answers, output):
    t = Template.Template(file=template, searchList=answers)
    open(output,"w").write(t.respond())


def sendNotification(config, address_list):
      sender = config['from_address']
      
      # Initialize to list
      to = ''
      for address in address_list:
          to = to + address + ','
      
      subject = config['subject_line']
      text = 'Report Completed Successfully!'
      headers = "From: %s\r\nTo: %s\r\nSubject: %s\r\n\r\n" % (sender, to, subject)
      message = headers + text
      
      if (('smtp_server' in config) and (config['smtp_server'] != None)):
          # Use external mail server
          mailServer = smtplib.SMTP(config['smtp_server'])
          
          if (('smtp_username' in config) and (config['smtp_username'] != None)):
              # Authentication Required
              mailServer.login(config['smtp_username'], config['smtp_password'])
      else:
          # Use locally configured sendmail
          mailServer = smtplib.SMTP('localhost')
          
      mailServer.set_debuglevel(1)
      mailServer.sendmail(sender, to, message)
      mailServer.quit()

class Report():
    
    parameters = None
    telemetry_config = None
     
    def __init__(self, config):
        
        # Open & parse Telemetry Configuration file
        config_file = "/etc/telemetry/telemetry.conf"
        f = open(config_file, 'r')
        self.telemetry_config = yaml.load(f)
         
        # Open & parse Report Configuration file
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
        
        #Send Report Notification
        if (len(self.parameters['Notifications']) > 0):
            sendNotification(self.telemetry_config, self.parameters['Notifications'])