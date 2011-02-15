#!/bin/env python
# API Script used to communicate with RHN Satellite 
# Copyright (C) 2008  Red Hat
#
# Author: Lars Jonsson (ljonsson@redhat.com)
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#

import xmlrpclib
from optparse import OptionParser
import sys

class RHNServer:
    def __init__(self,servername,user,passwd): 
        self.rhnServerName = servername
        self.login = user
        self.password = passwd
        self.rhnUrl = 'https://'+self.rhnServerName+'/rpc/api'
        self.server = xmlrpclib.Server(self.rhnUrl)
        self.rhnSession=self.rhnLogin(self.login,self.password)

    def rhnLogin(self, login, password): 
        try:
            rhnSession=self.server.auth.login(login,password)
        except  xmlrpclib.Fault, f:
            if f.faultCode==-20:
                print "Session expired"
                self.rhnLogin(login,password)
            else:
                print "Failed to login",f
                raise
        return rhnSession

    def cloneErrata(self,dest_chan,errata):
        out=[]
        try:
            print "Clone errata in progress, please be patient.."
            out = self.server.errata.clone(self.rhnSession,dest_chan,errata)
        except  xmlrpclib.Fault, f:
            if f.faultCode==-20:
                self.rhnLogin(self.login,self.password)
                return self.server.errata.clone(self.rhnSession,dest_chan,errata)
            else:
                raise
        return out

    def listChannelErrata(self,channel_label):
        out=[]
        try:
            out = self.server.errata.listByDate(self.rhnSession,channel_label)
        except  xmlrpclib.Fault, f:
            if f.faultCode==-20:
                self.rhnLogin(self.login,self.password)
                return self.server.errata.listByDate(self.rhnSession,channel_label)
            else:
                raise
        return out

def parse_args():
    parser = OptionParser()
    parser.add_option("-s", "--server", type="string", dest="servername",
            help="RHN Satellite server hostname") 
    parser.add_option("-l", "--login", type="string", dest="login",
            help="RHN Login") 
    parser.add_option("-p", "--password", type="string", dest="passwd",
            help="RHN password") 
    parser.add_option("", "--src-channel", type="string", dest="src_channel",
            help="channel label: ie.\"rhel-i386-as-4\"") 
    parser.add_option("", "--dest-channel", type="string", dest="dest_channel",
            help="channel label: ie.\"my-rhel-i386-as-4\"") 
    parser.add_option("", "--clone-up-to-date", type="string", dest="cdate",
            help="Date: ie. \"20080403T16:53:00\"") 
    parser.add_option("", "--list", action="store_true", dest="list", default=False,
            help="List source channel errata by date")

    (options,args) = parser.parse_args()
    return options 

def main():

    options = parse_args()

    if (options.servername and options.login and options.passwd) is None:
        print "try: "+sys.argv[0]+" --help"
        sys.exit(2)
    myserver = RHNServer(options.servername,options.login,options.passwd)

    if options.list and options.src_channel:
        for c in myserver.listChannelErrata(options.src_channel):
            print "%s\t%s (%s)" % (c['date'],c['advisory_synopsis'],c['advisory_name'])
    if options.cdate:
        aerrata = []
        for c in myserver.listChannelErrata(options.src_channel):
            if c['date'] <= options.cdate:
                aerrata.append(c['advisory_name'])
        myserver.cloneErrata(options.dest_channel, aerrata)

if __name__ == "__main__":
    main()
