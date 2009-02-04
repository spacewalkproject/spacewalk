#!/usr/bin/python

import xmlrpclib
import csv
import sys
import os
import time
from datetime import datetime
import yaml
import Cheetah.Template as Template
import smtplib
import getopt

CONFIG_DIR = "/etc/telemetry/"
CONFIG_FILE = "telemetry.conf"
USER_TELEMETRY_DIR = "/usr/share/telemetry/"
SUDOERS_FILE = "/etc/sudoers"

def getReports():
    reports = []
    config_dir = USER_TELEMETRY_DIR + "config/"
    files = os.listdir(config_dir)
    for file in files:
        reports.append(Report(file))
    return reports

def getConfig():
    config_file = os.path.join(CONFIG_DIR, CONFIG_FILE)
    f = open(config_file, 'r')
    return yaml.load(f)

class Report():
    
    satellites = []
    api_versions = []
    templates = []
    name = None
    notifications = []
    config = None
    script = None
    description = None
    prefix = None
    criteria = []
    aggregate = False
    
     
    def __init__(self, config):
        
        # Open & parse Report Configuration file
        config_dir = USER_TELEMETRY_DIR + "config/"
        config_file = os.path.join(config_dir, config)
        f = open(config_file, 'r')
        parameters =  yaml.load(f)
        
        self.satellites = parameters['satellites']
        self.api_versions = parameters['api_versions']
        self.templates = parameters['templates']
        self.name = parameters['name']
        self.script = parameters['script']
        self.description = parameters['description']
        if ('notifications' in parameters):
        	self.notifications = parameters['notifications']
        self.prefix = parameters['prefix']
        if ('criteria' in parameters):
        	self.criteria = parameters['criteria']
        self.aggregate = parameters['aggregate']
        self.config = config
        
        f.close()
        
    def connect(self):
    
        clients = []
        
        # Create connections to all Satellites
        for satellite in self.satellites:
            
            client = xmlrpclib.ServerProxy(satellite, verbose=0)
            
            # Validate API version
            api = client.api.getVersion()
            
            if (api in self.api_versions):
                clients.append(client)
            else:
                print "Error: API Version Mismatch."
                print "Satellite is: %s" % api
                print "%s will not be added." % satellite
            
        return clients
    
    def notify(self, report_name):
        
        config = getConfig()
    
        sender = config['from_address']
      
        # Initialize to list
        to = ''
        for address in self.notifications:
            to = to + address + ','
      
        subject = config['subject_line']
        text = 'Report Completed Successfully! -> ' + config['report_url'] + report_name
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
    
    def templatify(self, vars, type):

        template_dir = USER_TELEMETRY_DIR + "/templates/"
        
        # Retrieve Template from Type
        template_file = os.path.join(template_dir, self.templates[type])
        
        directory = getConfig()['report_directory']
        
        if not os.path.exists(directory):
            os.makedirs(directory)
            
        now = datetime.now().strftime("%Y-%m-%d:%H:%M:%S");
        report_name = "%s.%s.%s" % (self.prefix, now, type)
        report_file = os.path.join(directory, report_name) 
        
        t = Template.Template(file=template_file, searchList=vars)
        open(report_file,"w").write(t.respond())
        
        #Send Report Notification
        if (len(self.notifications) > 0):
            self.notify(report_name)
            
            
def main(argv=None):
    
    if argv is None:
        argv = sys.argv
    try:
        opts, args = getopt.getopt(argv[1:], "hs", ["help","setup"])
    except getopt.error, msg:
        print str(msg)
        usage() 
        sys.exit()  
        
    if (len(opts) == 0):
        usage()
        sys.exit()

    for o, a in opts:  
        if o in ("-h", "--help"):  
            usage()  
            sys.exit()  
        elif o in ("-s", "--setup"):  
            setup()           
        else:  
            assert False, "unhandled option"  

def usage():  
     usage = """ 
telemetry:
*************************************************************
-h --help                 Prints this 
-s --setup                Perform initial setup configuration
"""  
     print usage  
     
     
def setup():
    
    print "telemetry setup"
    #Grant apache sudo access to crontab for scheduling.
    updated = False
    f = open(SUDOERS_FILE, 'r')
    
    for line in f.readlines():
        if ("TELEMETRY" in line):
            updated = True
        
    if not updated:
        print "*updating sudoers"
        command = "cat /etc/telemetry/sudoers.telemetry >> /etc/sudoers"
        
        try:
            rc = os.system(command)
        except OSError, e:
            print >>sys.stderr, "Execution failed:", e
            
        if (rc >= 0):
            print "*update complete"
            
    else:
        print "*sudoers already updated.....skipping"
        
    #Verify Report Output directory exists and we can write to it.    
    config = getConfig()
    
    if not os.path.exists(config['report_directory']):
        prompt = "*create output directory {%s}? [y] " % config['report_directory']
        response = raw_input(prompt)
        
        if ((response == "") or (response.lower() in "yes")):
            #Create output directory
            os.umask(0)
            os.makedirs(config['report_directory'],mode=0777)
            
        prompt = "*update apache configuration as well? [y]"
        reponse = raw_input(prompt)
        
        if ((response == "") or (response.lower() in "yes")):
            f = open("/etc/httpd/conf/httpd.conf", "a")
            config = """ 
Alias /pub/ "%s"
<Directory "%s">
    Options Indexes MultiViews FollowSymLinks
    AllowOverride None
    Order allow,deny
    Allow from all
</Directory>
            """ % (config['report_directory'],config['report_directory'])
            f.write(config)
            f.close()
            
            print "*please restart httpd services"
    else:
        print "*output directory already exists.....skipping"
        
    print "*telemetry setup complete"


if __name__ == "__main__":
    sys.exit(main())
