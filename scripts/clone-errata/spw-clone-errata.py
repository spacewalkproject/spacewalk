#!/bin/env python
# Script that uses RHN API to clone RHN Errata to Satellite
# or Spacewalk server.
# Copyright (c) 2008--2010 Red Hat, Inc.
#
# Author: Andy Speagle (andy.speagle@wichita.edu)
#
# This script was written based on the "rhn-clone-errata.py"
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
#	Initial release.  Lots of problems.  Oof.
#
# 0.2 - 2009-09-11 - Andy Speagle
#
#	Updated methodology for handling errata. Breaking up individual
#	errata appended with a channel identifier to better automate publishing
#	of errata.
#
#	Some code reworking.  I still suck at python.  Removed deprecated "sets"
#	module.
#
# 0.3 - 2009-09-17 - Andy Speagle
#
#	Fixed a rather glaring bug in the logic regarding relevant channel
#	for package selection.  Ugh.

import xmlrpclib
from optparse import OptionParser
from time import time, localtime, strftime
import sys
import os
import re

class RHNServer:
    def __init__(self,servername,user,passwd): 
        self.rhnServerName = servername
        self.login = user
        self.password = passwd
        self.rhnUrl = 'https://'+self.rhnServerName+'/rpc/api'
        self.server = xmlrpclib.Server(self.rhnUrl)
        self.rhnSession = self.rhnLogin(self.login,self.password,0)

    def rhnLogin(self, login, password, retry): 
        try:
            rhnSession=self.server.auth.login(login,password)
        except  xmlrpclib.Fault, f:
	    if options.verbose:
		print "Fault Code: %d\tFault String: %s" % (f.faultCode,f.faultString)
            if f.faultCode==-20:
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
            if f.faultCode == -20:
                self.rhnLogin(self.login,self.password)
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
	    if f.faultCode == -20:
		self.rhnLogin(self.login,self.password)
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
	    if f.faultCode == -20:
		self.rhnLogin(self.login,self.password)
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

    def getErrataBugs(self,advisory,retry):
	bugs = []
	try:
	    bugs = self.server.errata.bugzillaFixes(self.rhnSession,advisory)
	except xmlrpclib.Fault, f:
            if options.verbose:            
                print "Fault Code: %d\tFault String: %s" % (f.faultCode,f.faultString)
	    if f.faultCode == -20:
		self.rhnLogin(self.login,self.password)
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
            if f.faultCode == -20:
                self.rhnLogin(self.login,self.password)
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
            if f.faultCode == -20:
                self.rhnLogin(self.login,self.password)
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
	    if f.faultCode == -20:
		self.rhnLogin(self.login,self.password)
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
            if f.faultCode == -20:
                self.rhnLogin(self.login,self.password)
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
            if f.faultCode == -20:
                self.rhnLogin(self.login,self.password)
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
            if f.faultCode == -20:
                self.rhnLogin(self.login,self.password)
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
            if f.faultCode == -20:
                self.rhnLogin(self.login,self.password)
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
            if f.faultCode == -20:
                self.rhnLogin(self.login,self.password)
                return self.server.errata.publish(self.rhnSession,name,channels)
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
                return self.errataPublish(name,channels, (retry + 1))
	return errata

    def errataClone(self,channel,errata,retry):
	clone=[]
	try:
	    clone = self.server.errata.clone(self.rhnSession,channel,errata)
	except xmlrpclib.Fault, f:
            if options.verbose:
                print "Fault Code: %d - %s" % (f.faultCode,f.faultString)
            if f.faultCode == -20:
                self.rhnLogin(self.login,self.password)
                return self.server.errata.clone(self.rhnSession,channel,errata)
	    elif f.faultCode == -208:
		print "Errata Doesn't Exist..."
		return []
            else:
                print "Error Cloning Errata!"
                raise
        except xmlrpclib.ProtocolError, err:
            if options.verbose:
                print "ProtocolError: %d - %s" % (err.errcode,err.errmsg)
            if retry > 5:
                return []
            else:
                return self.errataClone(channel,errata, (retry + 1))
        return clone

    def errataCreate(self,info,bugs,keywords,packages,publish,channels,retry):
	new_errata=[]
	try:
	    new_errata = self.server.errata.create(self.rhnSession,info,bugs,keywords,packages,publish,channels)
	except xmlrpclib.Fault, f:
	    if options.verbose:            
                print "Fault Code: %d - %s" % (f.faultCode,f.faultString)
            if f.faultCode == -20:
                self.rhnLogin(self.login,self.password)
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

def parse_args():
    parser = OptionParser()
    parser.add_option("-s", "--server", type="string", dest="server",
            help="Spacewalk Server (spacewalk.mydomain.org)") 
    parser.add_option("-l", "--login", type="string", dest="login",
            help="RHN Login") 
    parser.add_option("-p", "--password", type="string", dest="passwd",
            help="RHN password") 
    parser.add_option("-c", "--channel", type="string", dest="channel",
            help="Dest channel for cloning.") 
    parser.add_option("-b", "--begin-date", type="string", dest="bdate",
            help="Beginning Date: ie. \"19000101\" (defaults to \"19000101\")")
    parser.add_option("-e", "--end-date", type="string", dest="edate",
            help="Ending Date: ie. \"19001231\" (defaults to TODAY)")
    parser.add_option("-n", "--named-errata", type="string", dest="errata",
	    help="Name of errata: (RHSA-XXXX:XXXX:XX-XX)")
    parser.add_option("-r", "--pattern", type="string", dest="pattern",
	    help="Name pattern of errata: (RHSA, 2005, Foo)")
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

    if (options.server and options.login and options.passwd) is None:
        print "try: "+sys.argv[0]+" --help"
        sys.exit(2)

#   I don't reckon this should change anytime soon...
#
    svrRHN = 'rhn.redhat.com'

#   Ok, configure your RHN credentials here...
#
    userRHN = 'wsuadmin'
    passRHN = 'W$youAdm'

#   Here we setup our mappings from RHN to Local software channels.
#   Set these to what you have created for your SPW.
#   They are paired as:
#
#   RHNChannel: SPWChannel
#

    chanMapRHN = {
                'rhel-x86_64-server-5':                 'rhel-x86_64-server-5',
                'rhel-x86_64-server-rhntools-5':	'rhn-tools-rhel-x86_64-server-5',
                'rhel-x86_64-server-productivity-5':    'rhel-x86_64-server-productivity-5',
                'rhel-x86_64-server-supplementary-5':   'rhel-x86_64-server-supplementary-5',
                'rhel-x86_64-server-vt-5':              'rhel-x86_64-server-vt-5',
                'rhel-i386-server-5':                   'rhel-i386-server-5',
                'rhel-i386-server-rhntools-5':		'rhn-tools-rhel-i386-server-5',
                'rhel-i386-server-productivity-5':      'rhel-i386-server-productivity-5',
                'rhel-i386-server-supplementary-5':     'rhel-i386-server-supplementary-5',
                'rhel-i386-server-vt-5':                'rhel-i386-server-vt-5',
                'rhel-x86_64-server-4':			'rhel-x86_64-as-4',
                'rhel-x86_64-server-extras-4':		'rhel-x86_64-as-4-extras',
                'rhel-x86_64-server-rhntools-4':	'rhn-tools-rhel-4-as-x86_64',
                'rhel-i386-server-4':			'rhel-i386-as-4',
                'rhel-i386-server-extras-4':		'rhel-i386-as-4-extras',
                'rhel-i386-server-rhntools-4':		'rhn-tools-rhel-4-as-i386'
                };

#   Here I setup the production to authoritative channel mapping...

    chanMapSPW = {
		'rhel-x86_64-server-prod-5-3':			'rhel-x86_64-server-5',
		'rhel-x86_64-server-rhntools-prod-5-3':		'rhel-x86_64-server-rhntools-5',
		'rhel-x86_64-server-productivity-prod-5-3':	'rhel-x86_64-server-productivity-5',
		'rhel-x86_64-server-supplementary-prod-5-3':	'rhel-x86_64-server-supplementary-5',
		'rhel-x86_64-server-vt-prod-5-3':		'rhel-x86_64-server-vt-5',
		'rhel-i386-server-prod-5-3':			'rhel-i386-server-5',
		'rhel-i386-server-rhntools-prod-5-3':		'rhel-i386-server-rhntools-5',
                'rhel-i386-server-productivity-prod-5-3': 	'rhel-i386-server-productivity-5',
                'rhel-i386-server-supplementary-prod-5-3':	'rhel-i386-server-supplementary-5',
                'rhel-i386-server-vt-prod-5-3':			'rhel-i386-server-vt-5',
		'rhel-x86_64-server-prod-4-7':			'rhel-x86_64-server-4',
		'rhel-x86_64-server-extras-prod-4-7':		'rhel-x86_64-server-extras-4',
		'rhel-x86_64-server-rhntools-prod-4-7':		'rhel-x86_64-server-rhntools-4',
		'rhel-i386-server-prod-4-7':			'rhel-i386-server-4',
		'rhel-i386-server-extras-prod-4-7':		'rhel-i386-server-extras-4',
		'rhel-i386-server-rhntools-prod-4-7':		'rhel-i386-server-rhntools-4'
		};

#   Here we also setup mappings from RHN channels to errata suffixes.
#   Since we can't easily publish automagically, while ensuring that
#   the right packages go into the right channels, we're going to
#   split multi-channel affecting errata into individual errata
#   that are suffixed with something meaningful that identifies
#   each sub-errata per channel... blah blah... Of course, modify this
#   as you will.
#
#   RHNChannel: ErrataSuffix
#
    chanSuffixMap = {
		'rhel-x86_64-server-5':			'R5-64',
		'rhn-tools-rhel-x86_64-server-5':	'R5-64-T',
		'rhel-x86_64-server-productivity-5':	'R5-64-P',
		'rhel-x86_64-server-supplementary-5':	'R5-64-S',
		'rhel-x86_64-server-vt-5':		'R5-64-V',
		'rhel-i386-server-5':			'R5-32',
		'rhn-tools-rhel-i386-server-5':		'R5-32-T',
		'rhel-i386-server-productivity-5':	'R5-32-P',
		'rhel-i386-server-supplementary-5':	'R5-32-S',
		'rhel-i386-server-vt-5':		'R5-32-V',
		'rhel-x86_64-as-4':			'R4-64',
		'rhel-x86_64-as-4-extras':		'R4-64-E',
		'rhn-tools-rhel-4-as-x86_64':		'R4-64-T',
		'rhel-i386-as-4':			'R4-32',
		'rhel-i386-as-4-extras':		'R4-32-E',
		'rhn-tools-rhel-4-as-i386':		'R4-32-T'
		};

    if chanMapSPW[options.channel] is None:
	print "Invalid Channel!"
	sys.exit(2)

    mySPW = SPWServer(options.server,options.login,options.passwd)

    dateStart = options.bdate or '19000101'
    dateEnd = options.edate or strftime("%Y%m%d", localtime())

    errList = []

    if options.errata:
	errList = [ options.errata ]

    if options.pattern:
	for spwErrata in mySPW.listChannelErrata(chanMapSPW[options.channel],0):
	    if re.search (options.pattern, spwErrata['advisory_name']):
	        errList.append (spwErrata['advisory_name'])

    if options.bdate or options.edate:
	myRHN = RHNServer(svrRHN,userRHN,passRHN)
	chanRHN = chanMapRHN[chanMapSPW[options.channel]]

	for rhnErrata in myRHN.listChannelErrata(chanRHN,dateStart,dateEnd,0):
	    errName = rhnErrata['errata_advisory'] + ":" + chanSuffixMap[chanRHN]
	    errList.append (errName)

    for spwErr in errList:
	print spwErr

	spwClone = re.sub ('RH[BES]A', 'CLA', spwErr)
	spwCloneCheck = mySPW.getErrataDetails (spwClone, 0)

	if spwCloneCheck:
	    print "\tErrata Already Cloned:  %s - %s" % (spwClone, spwCloneCheck['synopsis'])
	    continue

	spwErrClone = mySPW.errataClone (options.channel, [ spwErr ], 0)

	if spwErrClone:
	    print "\tErrata Cloned:\t%s - %s" % (spwErrClone[0]['advisory_name'], spwErrClone[0]['advisory_synopsis'])
	else:
	    print "\tErrata NOT Cloned! - Some Error Occurred."

if __name__ == "__main__":
    main()
