#!/bin/env python
# Script that uses RHN API to clone RHN Errata to Satellite
# or Spacewalk server.
# Copyright (c) 2008--2011  Red Hat, Inc.
#
# Author: Andy Speagle (andy.speagle@wichita.edu)
#
# This script is an extension of the original "rhn-clone-errata.py"
# script written by:  Lars Jonsson (ljonsson@redhat.com)
#
# (THANKS!)
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
# Version Information:
#
# 0.1 - 2009-09-01 - Andy Speagle
#
#        Initial release.  Lots of problems.  Oof.
#
# 0.2 - 2009-09-11 - Andy Speagle
#
#        Updated methodology for handling errata. Breaking up individual
#        errata appended with a channel identifier to better automate publishing
#        of errata.
#
#        Some code reworking.  I still suck at python.  Removed deprecated "sets"
#        module.
#
# 0.3 - 2009-09-17 - Andy Speagle
#
#        Fixed a rather glaring bug in the logic regarding relevant channel
#        for package selection.  Ugh.
#
# 0.4 - 2009-10-01 - Andy Speagle
#
#        Modified how the publish happens.  Now it creates the errata and THEN
#        calls the separate errata.publish() function.  I was having some
#        intermittent time-outs doing the two together in the errata.create()
#        function.
#
# 0.5 - 2010-03-17 - Andy Speagle
#
#        Moved servers, users and passwords to a config file of your choice.
#        Many config options changed as a result. Options on the command line
#        override config file options.
#
#        Merged proxy support code from Colin Coe <colin.coe@gmail.com> (THANKS!)
#
#        Modified some of the formatting for logfile output.
#
#        I continue to suck at Python.
#
# 0.6 - 2010-03-18 - Andy Speagle
#
#        Corrected a grievous bug in the new Proxy code.
#
#        Moved Channel and ChannelSuffix maps to the config file.
#
# 0.7 - 2010-11-10 - Andy Speagle
#
#        Minor bugfixes a/o cosmetic changes.
#
# 0.8.1 - 2011-06-06 - Andy Speagle
#
#        Testing out new proxy code for handling authenticated proxies also.
#        NOT PRODUCTION CODE
#
# 0.8.2 - 2011-06-06 - Andy Speagle
#
#        Update to new proxy code.
#
# 0.8.3 - 2011-06-06 - Andy Speagle
#
#        Add selector for which server connections need proxy.  This is crude, will cleanup later.
#
# 0.8.4 - 2011-06-06 - Andy Speagle
#
#        Add some code to handle transparent proxies.
#
# 0.9.0 - 2011-11-17 - Andy Speagle
#
#        Included patch from Pierre Casenove <pcasenove@gmail.com> that gives an option for a
#        full sync of all channels listed in the configuration file.
#
#        Thanks, Pierre!
#
#        Additionally, changed the default behaviour of how the script handles errata that are
#        missing packages on the system.  The script now skips any errata that is missing one
#        or more packages on the system.  However, I've added an option to allow the script
#        to ignore missing packages so that the old behaviour remains.
#
# 0.9.1
#
#        Whitspace cleanup and additon of CVE handling.
#
# 0.9.2 - 2012-02-14 - Andy Speagle
#
#        Rewrite of package searching and handling.
#        Fix some problems with CVE handling.
#

import xmlrpclib, httplib
from optparse import OptionParser
from time import time, localtime, strftime
from datetime import datetime, timedelta
import sys, os, re
import ConfigParser
import base64, urllib
from urllib import unquote, splittype, splithost

class AuthProxyTransport(xmlrpclib.Transport):
    def set_proxy(self, proxy):
        self.proxy = options.proxy

    def request(self, host, handler, request_body, verbose=0):
        type, r_type = splittype(self.proxy)

        if 'http' in type:
            phost, XXX = splithost(r_type)
        else:
            phost = self.proxy

        puser_pass = None
        if '@' in phost:
            user_pass, phost = phost.split('@', 1)
            if ':' in user_pass:
                user, password = user_pass.split(':', 1)
                puser_pass = base64.encodestring('%s:%s' % (unquote(user),unquote(password))).strip()

        urlopener = urllib.FancyURLopener({'http':'http://%s'%phost})
        if not puser_pass:
            urlopener.addheaders = [('User-agent', self.user_agent)]
        else:
            urlopener.addheaders = [('User-agent', self.user_agent),('Proxy-authorization', 'Basic ' + puser_pass)]

        host = unquote(host)
        f = urlopener.open("http://%s%s"%(host,handler), request_body)

        self.verbose = verbose
        return self.parse_response(f)

class ProxiedTransport(xmlrpclib.Transport):
    def set_proxy(self, proxy):
        self.proxy = options.proxy
    def make_connection(self, host):
        self.realhost = host
        h = httplib.HTTP(self.proxy)
        return h
    def send_request(self, connection, handler, request_body):
        connection.putrequest("POST", "http://%s%s" % (self.realhost, handler))
    def send_host(self, connection, host):
        connection.putheader("Host", self.realhost)

class RHNServer:
    def __init__(self,servername,user,passwd,proxy_enable):
        self.rhnServerName = servername
        self.login = user
        self.password = passwd
        self.rhnUrl = 'https://'+self.rhnServerName+'/rpc/api'
        self.proxy_enable = proxy_enable
        if self.proxy_enable:
#        if options.proxy is None:
#            self.server = xmlrpclib.Server(self.rhnUrl)
#        else:
#            proxy = ProxiedTransport()
            proxy = AuthProxyTransport()
            proxy.set_proxy(options.proxy);
            self.server = xmlrpclib.Server(self.rhnUrl, transport=proxy)
        else:
            self.server = xmlrpclib.Server(self.rhnUrl)
        self.rhnSession = self.rhnLogin(self.login,self.password,0)

    def rhnLogin(self, login, password, retry):
        try:
            rhnSession=self.server.auth.login(login,password)
        except  xmlrpclib.Fault, f:
            if options.verbose:
                print "Fault Code: %d\tFault String: %s" % (f.faultCode,f.faultString)
            if f.faultCode == -20 or f.faultCode == -1:
                self.rhnLogin(login,password,retry)
            else:
                print "Failed to login",f
                raise
        except xmlrpclib.ProtocolError, err:
            if options.verbose:
                print "ProtocolError: %d - %s" % (err.errcode,err.errmsg)
            if retry > 3:
                raise
            else:
                return self.rhnLogin(login,password, (retry + 1))
        return rhnSession

    def getErrataChannels(self,advisory,retry):
        channels = []
        try:
            details = self.server.errata.applicableToChannels(self.rhnSession,advisory)
        except xmlrpclib.Fault, f:
            if options.verbose:
                print "Fault Code: %d\tFault String: %s" % (f.faultCode,f.faultString)
            if f.faultCode == -20 or f.faultCode == -1:
                self.rhnLogin(self.login,self.password,0)
                return self.server.errata.applicableToChannels(self.rhnSession,advisory)
            elif f.faultCode == -208:
                if options.verbose:
                    print "Errata %s Doesn't Exist on %s ..." % (advisory,self.rhnServerName)
                return []
            else:
                raise
        except xmlrpclib.ProtocolError, err:
            if options.verbose:
                print "ProtocolError: %d - %s" % (err.errcode,err.errmsg)
            if retry > 3:
                raise
            else:
                return self.getErrataChannels(advisory, (retry + 1))
        return channels

    def getErrataDetails(self,advisory,retry):
        details = []
        try:
            details = self.server.errata.getDetails(self.rhnSession,advisory)
        except xmlrpclib.Fault, f:
            if options.verbose:
                print "Fault Code: %d\tFault String: %s" % (f.faultCode,f.faultString)
            if f.faultCode == -20 or f.faultCode == -1:
                self.rhnLogin(self.login,self.password,0)
                return self.server.errata.getDetails(self.rhnSession,advisory)
            elif f.faultCode == -208:
                if options.verbose:
                    print "Errata %s Doesn't Exist on %s ..." % (advisory,self.rhnServerName)
                return []
            else:
                raise
        except xmlrpclib.ProtocolError, err:
            if options.verbose:
                print "ProtocolError: %d - %s" % (err.errcode,err.errmsg)
            if retry > 3:
                raise
            else:
                return self.getErrataDetails(advisory, (retry + 1))
        return details

    def getErrataKeywords(self,advisory,retry):
        keywords = []
        try:
            keywords = self.server.errata.listKeywords(self.rhnSession,advisory)
        except xmlrpclib.Fault, f:
            if options.verbose:
                print "Fault Code: %d\tFault String: %s" % (f.faultCode,f.faultString)
            if f.faultCode == -20 or f.faultCode == -1:
                self.rhnLogin(self.login,self.password,0)
                return self.server.errata.listKeywords(self.rhnSession,advisory)
            elif f.faultCode == -208:
                if options.verbose:
                    print "Errata %s Doesn't Exist on %s ..." % (advisory,self.rhnServerName)
                return []
            else:
                print "Error Getting Keywords : "+advisory
        except xmlrpclib.ProtocolError, err:
            if options.verbose:
                print "ProtocolError: %d - %s" % (err.errcode,err.errmsg)
            if retry > 3:
                raise
            else:
                return self.getErrataKeywords(advisory, (retry + 1))
        return keywords

    def getErrataCVEs(self,advisory,retry):
        keywords = []
        try:
            keywords = self.server.errata.listCves(self.rhnSession,advisory)
        except xmlrpclib.Fault, f:
            if options.verbose:
                print "Fault Code: %d\tFault String: %s" % (f.faultCode,f.faultString)
            if f.faultCode == -20 or f.faultCode == -1:
                self.rhnLogin(self.login,self.password,0)
                return self.server.errata.listCves(self.rhnSession,advisory)
            elif f.faultCode == -208:
                if options.verbose:
                    print "Errata %s Doesn't Exist on %s ..." % (advisory,self.rhnServerName)
                return []
            else:
                print "Error Getting CVEs : "+advisory
        except xmlrpclib.ProtocolError, err:
            if options.verbose:
                print "ProtocolError: %d - %s" % (err.errcode,err.errmsg)
            if retry > 3:
                raise
            else:
                return self.getErrataCves(advisory, (retry + 1))
        return keywords

    def getErrataBugs(self,advisory,retry):
        bugs = []
        try:
            bugs = self.server.errata.bugzillaFixes(self.rhnSession,advisory)
        except xmlrpclib.Fault, f:
            if options.verbose:
                print "Fault Code: %d\tFault String: %s" % (f.faultCode,f.faultString)
            if f.faultCode == -20 or f.faultCode == -1:
                self.rhnLogin(self.login,self.password,0)
                return self.server.errata.bugzillaFixes(self.rhnSession,advisory)
            elif f.faultCode == -208:
                if options.verbose:
                    print "Errata %s Doesn't Exist on %s ..." % (advisory,self.rhnServerName)
                return []
            else:
                print "Error Getting Bugs : "+advisory
        except xmlrpclib.ProtocolError, err:
            if options.verbose:
                print "ProtocolError: %d - %s" % (err.errcode,err.errmsg)
            if retry > 3:
                raise
            else:
                return self.getErrataBugs(advisory, (retry + 1))
        return bugs

    def getErrataCVEs(self,advisory,retry):
        cves=[]
        try:
            cves = self.server.errata.listCves(self.rhnSession,advisory)
        except xmlrpclib.Fault, f:
            if options.verbose:
                print "Fault Code: %d\tFault String: %s" % (f.faultCode,f.faultString)
            if f.faultCode == -20 or f.faultCode == -1:
                self.rhnLogin(self.login,self.password,0)
                return self.server.errata.listCves(self.rhnSession,advisory)
            elif f.faultCode == -208:
                if options.verbose:
                    print "Errata %s Doesn't Exist on %s ..." % (advisory,self.rhnServerName)
                return []
            else:
                print "Error Getting CVEs : %s" % advisory
        except xmlrpclib.ProtocolError, err:
            if options.verbose:
                print "ProtocolError: %d - %s" % (err.errcode,err.errmsg)
            if retry > 3:
                raise
            else:
                return self.getErrataCVEs(advisory, (retry + 1))
        return cves

    def getErrataPackages(self,advisory,retry):
        packages=[]
        try:
            packages = self.server.errata.listPackages(self.rhnSession,advisory)
        except xmlrpclib.Fault, f:
            if options.verbose:
                print "Fault Code: %d\tFault String: %s" % (f.faultCode,f.faultString)
            if f.faultCode == -20 or f.faultCode == -1:
                self.rhnLogin(self.login,self.password,0)
                return self.server.errata.listPackages(self.rhnSession,advisory)
            elif f.faultCode == -208:
                if options.verbose:
                    print "Errata %s Doesn't Exist on %s ..." % (advisory,self.rhnServerName)
                return []
            else:
                print "Error Getting Packages : %s" % advisory
        except xmlrpclib.ProtocolError, err:
            if options.verbose:
                print "ProtocolError: %d - %s" % (err.errcode,err.errmsg)
            if retry > 3:
                raise
            else:
                return self.getErrataPackages(advisory, (retry + 1))
        return packages

    def listChannelErrata(self,dest_chan,dateStart,dateEnd,retry):
        out = []
        try:
            out = self.server.channel.software.listErrata(self.rhnSession,dest_chan,dateStart,dateEnd)
        except xmlrpclib.Fault, f:
            if options.verbose:
                print "Fault Code: %d\tFault String: %s" % (f.faultCode,f.faultString)
            if f.faultCode == -20 or f.faultCode == -1:
                self.rhnLogin(self.login,self.password,0)
                return self.server.channel.software.listErrata(self.rhnSession,dest_chan,dateStart,dateEnd)
            else:
                raise
        except xmlrpclib.ProtocolError, err:
            if options.verbose:
                print "ProtocolError: %d - %s" % (err.errcode,err.errmsg)
            if retry > 3:
                raise
            else:
                return self.listChannelErrata(dest_chan,dateStart,dateEnd,(retry + 1))
        return out

    def findPackageChannels(self,pkgid,retry):
        channels=[]
        try:
            channels = self.server.packages.listProvidingChannels(self.rhnSession,pkgid)
        except xmlrpclib.Fault, f:
            if options.verbose:
                print "Fault Code: %d\tFault String: %s" % (f.faultCode,f.faultString)
            if f.faultCode == -20 or f.faultCode == -1:
                self.rhnLogin(self.login,self.password,0)
                return self.server.packages.listProvidingChannels(self.rhnSession,pkgid)
            else:
                print "Error Finding Channels for Package : %s" % pkgid
        except xmlrpclib.ProtocolError, err:
            if options.verbose:
                print "ProtocolError: %d - %s" % (err.errcode,err.errmsg)
            if retry > 3:
                raise
            else:
                return self.server.packages.findPackageChannels(pkgid, (retrun + 1))
        return channels

    def cloneErrata(self,dest_chan,errata,retry):
        out=[]
        try:
            print "Clone errata in progress, please be patient.."
            out = self.server.errata.clone(self.rhnSession,dest_chan,errata)
        except  xmlrpclib.Fault, f:
            print "Fault Code: %d\tFault String: %s" % (f.faultCode,f.faultString)
            if f.faultCode == -20 or f.faultCode == -1:
                self.rhnLogin(self.login,self.password,0)
                return self.self.server.errata.clone(self.rhnSession,dest_chan,errata)
            else:
                raise
        except xmlrpclib.ProtocolError, err:
            print "ProtocolError: %d - %s" % (err.errcode,err.errmsg)
            if retry > 3:
                raise
            else:
                return self.cloneErrata(dest_chan,errata, (retry + 1))
        return out

class SPWServer(RHNServer):

    def searchNVREA(self,name,version,release,epoch,archlabel,retry):
        package=[]
        try:
            package = self.server.packages.findByNvrea(self.rhnSession,name,version,release,epoch,archlabel)
        except xmlrpclib.Fault, f:
            if options.verbose:
                print "Fault Code: %d\tFault String: %s" % (f.faultCode,f.faultString)
            if f.faultCode == -20 or f.faultCode == -1:
                self.rhnLogin(self.login,self.password,0)
                return self.server.packages.findByNvrea(self.rhnSession,name,version,release,archlabel)
            else:
                print "Error Finding Package via NVREA : %s" % name
        except xmlrpclib.ProtocolError, err:
            if options.verbose:
                print "ProtocolError: %d - %s" % (err.errcode,err.errmsg)
            if retry > 3:
                raise
            else:
                return self.searchNVREA(name,version,release,epoch,archlabel, (retry + 1))
        return package

    def listChannelErrata(self,dest_chan,retry):
        out = []
        try:
            out = self.server.channel.software.listErrata(self.rhnSession,dest_chan)
        except xmlrpclib.Fault, f:
            if options.verbose:
                print "Fault Code: %d\tFault String: %s" % (f.faultCode,f.faultString)
            if f.faultCode == -20 or f.faultCode == -1:
                self.rhnLogin(self.login,self.password,0)
                return self.server.channel.software.listErrata(self.rhnSession,dest_chan)
            else:
                raise
        except xmlrpclib.ProtocolError, err:
            if options.verbose:
                print "ProtocolError: %d - %s" % (err.errcode,err.errmsg)
            if retry > 3:
                raise
            else:
                return self.listChannelErrata(dest_chan,(retry + 1))
        return out

    def errataPublish(self,name,channels,retry):
        errata=[]
        try:
            errata = self.server.errata.publish(self.rhnSession,name,channels)
        except xmlrpclib.Fault, f:
            if options.verbose:
                print "Fault Code: %d - %s" % (f.faultCode,f.faultString)
            if f.faultCode == -20 or f.faultCode == -1:
                self.rhnLogin(self.login,self.password,0)
                return self.server.errata.publish(self.rhnSession,name,channels)
            elif f.faultCode == 2601:
                print "Errata Already Exists..."
                return []
            else:
                print "Error Publishing Errata!"
                raise
        except xmlrpclib.ProtocolError, err:
            if options.verbose:
                print "ProtocolError: %d - %s" % (err.errcode,err.errmsg)
            if retry > 3:
                raise
            else:
                return self.errataPublish(name,channels, (retry + 1))
        return errata

    def errataCreate(self,info,bugs,keywords,packages,publish,channels,retry):
        new_errata=[]
        try:
            new_errata = self.server.errata.create(self.rhnSession,info,bugs,keywords,packages,publish,channels)
        except xmlrpclib.Fault, f:
            if options.verbose:
                print "Fault Code: %d - %s" % (f.faultCode,f.faultString)
            if f.faultCode == -20 or f.faultCode == -1:
                self.rhnLogin(self.login,self.password,0)
                return self.server.errata.create(self.rhnSession,info,bugs,keywords,packages,publish,channels)
            elif f.faultCode == 2601:
                print "Errata Already Exists..."
                return []
            else:
                print "Error Creating Errata!"
                raise
        except xmlrpclib.ProtocolError, err:
            if options.verbose:
                print "ProtocolError: %d - %s" % (err.errcode,err.errmsg)
            if retry > 3:
                raise
            else:
                return self.errataCreate(info,bugs,keywords,packages,publish,channels, (retry + 1))
        return new_errata

    def setDetails(self,advisory,details,retry):
        out=[]
        try:
            out = self.server.errata.setDetails(self.rhnSession,advisory,details)
        except xmlrpclib.Fault, f:
            if options.verbose:
                print "Fault Code: %d - %s" % (f.faultCode,f.faultString)
            if f.faultCode == -20 or f.faultCode == -1:
                self.rhnLogin(self.login,self.password,0)
                return self.server.errata.setDetails(self.rhnSession,advisory,details)
            else:
                print "Can't Update Errata Details!"
                raise
        except xmlrpclib.ProtocolError, err:
            if options.verbose:
                print "ProtocolError: %d - %s" % (err.errcode,err.errmsg)
            if retry > 3:
                raise
            else:
                return self.setDetails(advisory,details, (retry + 1))
        return out

    def getPkgDetails(self,id,retry):
        out=[]
        try:
            out = self.server.packages.getDetails(self.rhnSession,id)
        except xmlrpclib.Fault, f:
            if options.verbose:
                print "Fault Code: %d - %s" % (f.faultCode,f.faultString)
            if f.faultCode == -20 or f.faultCode == -1:
                self.rhnLogin(self.login,self.password,0)
                return self.server.packages.getDetails(self.rhnSession,id)
            else:
                print "Can't Get Package Details!"
                raise
        except xmlrpclib.ProtocolError, err:
            if options.verbose:
                print "ProtocolError: %d - %s" % (err.errcode,err.errmsg)
            if retry > 3:
                raise
            else:
                return self.getPkgDetails(id, (retry + 1))
        return out

def parse_args():
    parser = OptionParser()
    parser.add_option("-s", "--spw-server", type="string", dest="spw_server",
            help="Spacewalk Server (spacewalk.mydomain.org)")
    parser.add_option("-S", "--rhn-server", type="string", dest="rhn_server",
            help="RHN Server (rhn.redhat.com)")
    parser.add_option("-u", "--spw-user", type="string", dest="spw_user",
            help="Spacewalk User")
    parser.add_option("-p", "--spw-pass", type="string", dest="spw_pass",
            help="Spacewalk Password")
    parser.add_option("-U", "--rhn-user", type="string", dest="rhn_user",
            help="RHN User")
    parser.add_option("-P", "--rhn-pass", type="string", dest="rhn_pass",
            help="RHN Password")
    parser.add_option("-f", "--config-file", type="string", dest="cfg_file",
            help="Config file for servers, users and passwords.")
    parser.add_option("-c", "--src-channel", type="string", dest="src_channel",
            help="Source Channel Label: ie.\"rhel-x86_64-server-5\"")
    parser.add_option("-b", "--begin-date", type="string", dest="bdate",
            help="Beginning Date: ie. \"19000101\" (defaults to \"19000101\")")
    parser.add_option("-e", "--end-date", type="string", dest="edate",
            help="Ending Date: ie. \"19001231\" (defaults to TODAY)")
    parser.add_option("-i", "--publish", action="store_true", dest="publish", default=False,
            help="Publish Errata (into destination channels)")
    parser.add_option("-I", "--ignore-missing-packages", action="store_true", dest="ignoremissing", default=False,
            help="Ignore Missing Packages")
    parser.add_option("-x", "--proxy", type="string", dest="proxy",
            help="Proxy server and port to use (e.g. proxy.company.com:3128)")
    parser.add_option("--no-spw-proxy", action="store_true", dest="nospwproxy", default=False,
            help="Don't proxy the Spacewalk server connection. (Proxy by default, if proxy is set)")
    parser.add_option("--no-rhn-proxy", action="store_true", dest="norhnproxy", default=False,
            help="Don't proxy the RHN server connection. (Proxy by default, if proxy is set)")
    parser.add_option("-F", "--format-header", action="store_true", dest="format", default=False,
            help="Format header for logfiles")
    parser.add_option("-A", "--sync-all-channels", action="store_true", dest="fullsync", default=False,
            help="Synchronize erratas of all channels listed in the provided configuration file")
    parser.add_option("-v", "--verbose", action="store_true", dest="verbose", default=False)
    parser.add_option("-q", "--quiet", action="store_true", dest="quiet", default=False)

    (options,args) = parser.parse_args()
    return options

def main():
    global chanMap
    global chanSuffixMap
    global RHNServer
    global RHNUser
    global RHNPass
    global options

    options = parse_args()

#   Config File Format:  It needs to be ConfigParser compliant:
#
#   [Section]
#   option=value

    if (options.cfg_file):
        config = ConfigParser.ConfigParser()
        config.read (options.cfg_file)

        if options.spw_server is None:
            options.spw_server = config.get ('Spacewalk', 'spw_server')
        if options.spw_user is None:
            options.spw_user = config.get ('Spacewalk', 'spw_user')
        if options.spw_pass is None:
            options.spw_pass = config.get ('Spacewalk', 'spw_pass')
        if options.rhn_server is None:
            options.rhn_server = config.get ('RHN', 'rhn_server')
        if options.rhn_user is None:
            options.rhn_user = config.get ('RHN', 'rhn_user')
        if options.rhn_pass is None:
            options.rhn_pass = config.get ('RHN', 'rhn_pass')

#        Here we setup our mappings from RHN to Spacewalk software channels.
#        These are read from the config file in this format:
#
#        [ChanMap]
#        RHNChannel = SPWChannel
#
#        Example:
#        rhn-tools-rhel-x86_64-server-5 = rhel-x86_64-server-rhntools-5

        chanMap = {}

        if options.fullsync:
            for chan in config.options('ChanMap'):
                chanMap[chan] = config.get('ChanMap', chan)
        else:
            if options.src_channel is None:
                print "Source channel not given, aborting"
                sys.exit(2)
            chanMap[options.src_channel] = config.get('ChanMap', options.src_channel)

#        Here we also setup mappings from RHN channels to errata suffixes.
#        Since we can't easily publish automagically, while ensuring that
#        the right packages go into the right channels, we're going to
#        split multi-channel affecting errata into individual errata
#        that are suffixed with something meaningful that identifies
#        each sub-errata per channel... blah blah... Of course, modify this
#        as you will.  I'm not sure if this will be required in the future.
#
#        [ChanSuffixMap]
#        RHNChannel = ErrataSuffix
#
#        Example:
#        rhn-tools-rhel-x86_64-server-5 = R5-64-T

        chanSuffixMap = {}

        for chan in config.options('ChanSuffixMap'):
            chanSuffixMap[chan] = config.get('ChanSuffixMap', chan)

    if (options.spw_server and options.spw_user and options.spw_pass and
        options.rhn_server and options.rhn_user and options.rhn_pass) is None:
        print "try: "+sys.argv[0]+" --help"
        sys.exit(2)

    rhnProxy = 0
    spwProxy = 0

    if options.proxy is not None:
        if not options.norhnproxy:
            rhnProxy = 1
        if not options.nospwproxy:
            spwProxy = 1

    myRHN = RHNServer(options.rhn_server, options.rhn_user, options.rhn_pass, rhnProxy)
    mySPW = SPWServer(options.spw_server, options.spw_user, options.spw_pass, spwProxy)

    dateStart = options.bdate or '19000101'
    dateToday = strftime("%Y%m%d", localtime())
    dateEnd = options.edate or dateToday

    for chan in chanMap:
        if chanMap[chan] is None:
            print "Invalid Channel!"
            sys.exit(2)

        if options.format:
            print >>sys.stdout, "%s:CLONE:%s" % (dateToday, chan)
            print >>sys.stderr, "%s:CLONE:%s" % (dateToday, chan)

        for rhnErrata in myRHN.listChannelErrata(chan,dateStart,dateEnd,0):
            if not options.quiet and not options.format:
                print rhnErrata['errata_advisory']

#               Now, let's check if we already have this errata locally...
            spwErrataName = rhnErrata['errata_advisory']+':'+chanSuffixMap[chan]
            spwErrCheck = mySPW.getErrataDetails (spwErrataName,0)

            if not spwErrCheck:
#               Ok, so the errata doesn't already exists... let's get busy creating it.
                spwErrSolution = "Before applying this update, make sure that all "+\
                    "previously-released errata relevant to your system have been applied."

                spwErrPackages = []

                missingcheck = 0

                for pkg in myRHN.getErrataPackages(rhnErrata['errata_advisory'],0):
                    if chan not in pkg['providing_channels']:
                        continue

                    pkgList = mySPW.searchNVREA(pkg['package_name'],\
                                                pkg['package_version'],\
                                                pkg['package_release'],\
                                                '',\
                                                pkg['package_arch_label'],\
                                                0)

                    if not pkgList:
                        missingcheck += 1
                        continue

                    innercheck = 1

                    for pkgFound in pkgList:
                        pkgFoundDetails = mySPW.getPkgDetails(pkgFound['id'],0)

                        if chanMap[chan] in pkgFoundDetails['providing_channels']:
                            spwErrPackages.append(pkgFound['id'])
                            innercheck = 0

                            break

                    if innercheck:
                        missingcheck += 1

                        if options.format:
                            print >>sys.stderr, "%s:%s:Hmmm... "+\
                                "Package Missing: %s" % (dateToday, rhnErrata['errata_advisory'], pkg['package_name'])
                        else:
                            print "Hmmm... Package Missing: %s" % pkg['package_name']

                if missingcheck:
                    if options.ignoremissing:
                        skiptext = "Ignoring missing package(s) and continuing..."

                        if options.format:
                            print >>sys.stderr, "%s" % skiptext
                        else:
                            print "%s" % skiptext
                    else:
                        skiptext = "Skipping errata due to missing package(s)..."

                        if options.format:
                            print >>sys.stderr, "%s" % skiptext
                        else:
                            print "%s" % skiptext

                        continue

                spwErrDetails = myRHN.getErrataDetails(rhnErrata['errata_advisory'],0)
                spwErrKeywords = myRHN.getErrataKeywords(rhnErrata['errata_advisory'],0)
                spwErrCVEs = myRHN.getErrataCVEs(rhnErrata['errata_advisory'],0)

                spwErrBugs = []
                tmpBugs = myRHN.getErrataBugs(rhnErrata['errata_advisory'],0)

                for bug in tmpBugs:
                    href = 'https://bugzilla.redhat.com/show_bug.cgi?id=%s' % bug
                    spwErrBugs.append({'id': int(bug), 'summary': tmpBugs[bug], 'url' : href})

                if not options.quiet and not options.format:
                    print "\t%s - %s" % (spwErrDetails['errata_issue_date'],spwErrDetails['errata_synopsis'])

                spwErrObject = mySPW.errataCreate ({ 'synopsis': spwErrDetails['errata_synopsis'],\
                                                     'advisory_name': spwErrataName,\
                                                     'advisory_release': 1,\
                                                     'advisory_type': spwErrDetails['errata_type'],\
                                                     'product': 'RHEL',\
                                                     'topic': spwErrDetails['errata_topic'],\
                                                     'description': spwErrDetails['errata_description'],\
                                                     'references': spwErrDetails['errata_references'],\
                                                     'notes': spwErrDetails['errata_notes'],\
                                                     'solution': spwErrSolution },\
                                                     spwErrBugs,\
                                                     spwErrKeywords,\
                                                     spwErrPackages,\
                                                     0,\
                                                     [chanMap[chan]],\
                                                     0)

                if options.format:
                    print "%s#%s#Errata Created#" % (dateToday, spwErrataName),
                else:
                    print "\tErrata Created: %d" % spwErrObject['id']

                if options.publish:
                    spwPublish = mySPW.errataPublish (spwErrataName, [chanMap[chan]], 0)
                    if options.format:
                        print "Errata Published"
                    else:
                        print "\tErrata Published!"

                    # we must add the CVEs after publishing because the foreign key
                    # constraint on 'rhnErrataCve' is for the 'rhnErrata' table, not
                    # the 'rhnErrataTmp' table
                    if len(spwErrCVEs):
                        mySPW.setDetails(spwErrataName, { 'cves' : spwErrCVEs }, 0)
                else:
                    if options.format:
                        print "Errata Not Published"
                    else:
                        print "\tErrata Not Published!"
            else:
                if options.format:
                    print "%s#%s#Errata Already Exists" % (dateToday, spwErrataName)
                elif not options.quiet:
                    print "\tErrata Already Exists.  %s" % spwErrataName
                    continue

if __name__ == "__main__":
    main()
