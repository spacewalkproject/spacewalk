#!/usr/bin/python
#
# Copyright (c) 1999--2013 Red Hat, Inc.  Distributed under GPL.
#
# Author: Preston Brown <pbrown@redhat.com>
#         Adrian Likins <alikins@redhat.com>
#         Cristian Gafton <gafton@redhat.com>
#
# This thing gets the hardware configuraion out of a system
"""Used to read hardware info from kudzu, /proc, etc"""
import socket

import os
import string
import re

import config
import rhnUtils

#from rhpl import ethtool


# PORTME HP-specific code to get kernel symbol values
def GetKernelSymbol(ksym, hpux):
    command='echo "' + ksym + '/D" | adb -k ' + hpux + ' /dev/kmem'

    stdout = os.popen(command)
    line=stdout.read()
    stdout.close()

    l=line.splitlines()[1].split("\t")
    kval=l[-1]

    return kval


# The registration server has several ways of dealing with this hardware
# profile.
# One is to add a 'hardware' member to the registration dictionary when
# calling new_system
# Another is to call registration.add_hw_profile(sysid, Hardware)
#       (accordingly, there is a registration.delete_hw_profile(sysid)


#PORTME: if systems have the equivalent of kudzu, this is a good place
# to inspect it.  Note, anything here the servers need to know about,
# so, dont expect much to work
def read_hwconf():
    ret = []
    return ret

        

# the cpuinfo is dict with keys on class, desc, platform,
#  count, type, model, model_number, model_ver, model_rev,
#  cache, bogomips, other, and speed  
#
# of course, the meanings for those vary widely, even on
#  linux, so best guess for the port
#

def read_cpuinfo():
    platform = ''
    ptype=''
    model=''
    model_number=''
    model_ver=''
    model_rev=''
    count = 0
    mhz = 0

    uname = os.uname()
    system = uname[0]
    release = uname[2]
    machine = uname[4]
    # We may have to munge platform
    platform = machine

    if system == "HP-UX":
        # PORTME HP-specific stuff
        arch=''

        l=machine.splitlines()[0].split("/")
        ptype=l[0]
        model_ver=l[1]

        rev=int(release.split(".")[1])

        if model_ver[:2] == "31":	# 31x
            arch="m68000 "
        elif model_ver[:1] == "3":	# 3xx
            arch="m68k "
        elif model_ver[:1] == "4":	# 4xx
            arch="m68k"
        else:			# 6xx, 7xx, 8xx
            if rev > 10:
                stdout = os.popen("getconf SC_CPU_VERSION")
                ret=stdout.read()
                stdout.close()
                cpu_ver=int(ret)

		# On some HP systems, HW_CPU_SUPP_BITS returns 32/64.
		# Since this information doesn't appear to be used
		# anyway, we'll ignore it for now.
                #stdout = os.popen("getconf HW_CPU_SUPP_BITS")
                #ret=stdout.read()
                #stdout.close()
                #cpu_bits=int(ret)

                stdout = os.popen("getconf KERNEL_BITS")
                ret=stdout.read()
                stdout.close()
                kernel_bits=int(ret)

                if cpu_ver == 523:	# CPU_PA_RISC1_0
                    arch="hppa1.0"
                elif cpu_ver == 528:	# CPU_PA_RISC1_1
                    arch="hppa1.1"
                elif cpu_ver == 532: 	# CPU_PA_RISC2_0
                    if kernel_bits == 32:
                        arch="hppa2.0n"
                    elif kernel_bits == 64:
                        arch="hppa2.0w"

        model=arch.split(".")[0]
        if model[:2] == "hp":
            platform='pa_risc'
            ptype="HP"
            model_number=cpu_ver
            model_ver=model[len(model)-1:]
            model_rev=arch.split(".")[1]
            model=model[:len(model)-1]
        else:
            platform='m68xxx'
            ptype='Motorola'
            model=arch

        if rev > 9:
            hpux="/stand/vmunix"
        else:
            hpux="/hp-ux"

        ret=GetKernelSymbol("processor_count", hpux)
        count=int(ret)

        ret=GetKernelSymbol("itick_per_tick", hpux)
        mhz=int(ret)/10000
    elif system == "AIX":
        # PORTME AIX-specific stuff
        stdout = os.popen("/usr/sbin/lsdev -C -c processor -S available")
        lines = stdout.readlines()
        stdout.close()

        # Get number of CPUs
        cpu_id = ''
        for line in lines:
            matches = re.search('^(proc\d+) ', line)
            if matches:
                count = count + 1
                if not cpu_id:
                    cpu_id = matches.group(1)
        if not count:
            count = 1

        # Get system model name.  On IBM boxes, this is the same thing
        # as the CPU model, since if you change out the CPU, you've
        # changed the system model.
        stdout = os.popen('/usr/bin/uname -M')
        model = stdout.read()
        stdout.close()
        model = model.strip()
        # Chop off 'IBM,' at the beginning of the string
        if (model.find('IBM,') == 0):
            model = model[4:]

        # Try to get the platform and CPU speed.
        if cpu_id:
            stdout = os.popen("/usr/sbin/lsattr -El %s" % cpu_id)
            lines = stdout.readlines()
            stdout.close()
            platform = 'powerpc'
            for line in lines:
                matches = re.search(' POWER', line)
                if matches:
                    platform = 'rs6000'
                matches = re.search('frequency (\d+) ', line)
                if matches:
                    mhz = int(matches.group(1))/1000000

        # If we couldn't find the CPU speed,
        if (mhz == 0):
            # Do it the old (inaccurate) way.  All this information
            # was taken from the IBM "Performance Management Guide -
            # Determining CPU Speed" web page.
            mach_id = {
                '02' : { 'model' : '7015-930', 'mhz' : 25, },
                '10' : { 'model' : '7013-530/7016-730', 'mhz' : 25, },
                '11' : { 'model' : '7013-450', 'mhz' : 30, },
                '14' : { 'model' : '7013-540', 'mhz' : 30, },
                '18' : { 'model' : '7013-53H', 'mhz' : 33, },
                '1C' : { 'model' : '7013-550', 'mhz' : 41.6, },
                '20' : { 'model' : '7015-930', 'mhz' : 25, },
                '2E' : { 'model' : '7015-950', 'mhz' : 41, },
                '30' : { 'model' : '7013-520', 'mhz' : 20, },
                '31' : { 'model' : '7012-320', 'mhz' : 20, },
                '34' : { 'model' : '7013-52H', 'mhz' : 25, },
                '35' : { 'model' : '7012-32H', 'mhz' : 25, },
                '37' : { 'model' : '7012-340', 'mhz' : 33, },
                '38' : { 'model' : '7012-350', 'mhz' : 41, },
                '41' : { 'model' : '7011-220', 'mhz' : 33, },
                '43' : { 'model' : '7008-M20/7008-M2A', 'mhz' : 33, },
                '46' : { 'model' : '7011-250', 'mhz' : 66, },
                '47' : { 'model' : '7011-230', 'mhz' : 45, },
                '48' : { 'model' : '7009-C10', 'mhz' : 80, },
                '57' : { 'model' : '7012-390/7030-3BT/9076-SP2 Thin', 'mhz' : 67, },
                '58' : { 'model' : '7012-380/7030-3AT', 'mhz' : 59, },
                '59' : { 'model' : '7012-39H/9076-SP2 Thin', 'mhz' : 67, },
                '5C' : { 'model' : '7013-560', 'mhz' : 50, },
                '63' : { 'model' : '7015-970/7015-97B', 'mhz' : 50, },
                '64' : { 'model' : '7015-980/7015-98B', 'mhz' : 62.5, },
                '66' : { 'model' : '7013-580', 'mhz' : 62.5, },
                '67' : { 'model' : '7013-570/7015-R10', 'mhz' : 50, },
                '70' : { 'model' : '7013-590/9076-SP2 Wide', 'mhz' : 66, },
                '71' : { 'model' : '7013-58H', 'mhz' : 55, },
                '72' : { 'model' : '7013-59H/7015-R20/9076-SP2 Wide', 'mhz' : 66, },
                '75' : { 'model' : '7012-370/7012-375/9076-SP1 Thin', 'mhz' : 62, },
                '76' : { 'model' : '7012-360/7012-365', 'mhz' : 50, },
                '77' : { 'model' : '7012-350/7012-355/7013-55L', 'mhz' : 41, },
                '79' : { 'model' : '7013-591/9076-SP2 Wide', 'mhz' : 77, },
                '80' : { 'model' : '7015-990', 'mhz' : 71.5, },
                '81' : { 'model' : '7015-R24', 'mhz' : 71.5, },
                '89' : { 'model' : '7013-595/7076-SP2 Wide', 'mhz' : 135, },
                '94' : { 'model' : '7012-397/9076-SP2 Thin', 'mhz' : 160, },
                'A0' : { 'model' : '7013-J30', 'mhz' : 75, },
                'A1' : { 'model' : '7015-J40', 'mhz' : 112, },
                'F0' : { 'model' : '7007-N40', 'mhz' : 50, },
                }

            model_id = machine[8:10]
            if mach_id.has_key(model_id):
                mhz = mach_id[model_id]['mhz']
                model = mach_id[model_id]['model']
            elif model_id == '4C':
                if (model.find('S70') <> -1): # 7017-S70
                    mhz = 125
                elif (model.find('S7A') <> -1): # 7017-S7A
                    mhz = 262
                elif (model.find('S80') <> -1): # 7017-S80
                    mhz = 450
                elif (model.find('F40') <> -1): # 7025-F40
                    # this could be either 160 or 233
                    pass
                elif (model.find('H10') <> -1): # 7026-H10
                    # this could be either 160 or 233
                    pass
                elif (model.find('H70') <> -1): # 7026-H70
                    mhz = 340
                elif (model.find('260') <> -1): # 7043-260
                    mhz = 200
                elif (model.find('248') <> -1): # 7248-100/7248-120/7248-132
                    # this could be either 100/120/132
                    pass
                elif (model.find('B50') <> -1): # 7046-B50
                    mhz = 375
                elif (model.find('042') <> -1 or model.find('043') <> -1):
                    # mhz could be either 166/200/233
                    pass
                elif (re.search(r'F50|H50|270', model)):
                    # On these boxes, "lscfg -vp" reports CPU speed as
                    # ASCII coded hex. 
                    stdout = os.popen("/usr/sbin/lscfg -vp")
                    lines = stdout.readlines()
                    stdout.close()
                    for line in lines:
                        matches = re.search(r'ZC.+PS=([0-9A-Fa-f]+),', line)
                        if matches:
                            mhz = int(matches.group(1), 16)/1000000

            elif model_id == 'A3' or model_id == 'A4' or model_id == 'A6' \
                     or model_id == 'A7':
                stdout = os.popen("/usr/sbin/lscfg -vl cpucard0")
                lines = stdout.readlines()
                stdout.close()
                for line in lines:
                    if (line.find('FRU') <> -1):
                        if (line.find('E1D') <> -1 or line.find('C1D') <> -1):
                            mhz = 75
                        elif (line.find('C4D') <> -1
                              or line.find('E4D') <> -1):
                            mhz = 112
                        elif (line.find('X4D') <> -1):
                            mhz = 200
            elif model_id == 'C0' or model_id == 'C4':
                # On these boxes, "lscfg -vp" reports CPU speed in MHz
                stdout = os.popen("/usr/sbin/lscfg -vp")
                lines = stdout.readlines()
                stdout.close()
                for line in lines:
                    matches = re.search(r'ZA.+PS=([0-9]+),', line)
                    if matches:
                        mhz = int(matches.group(1))
    else:
        # PORTME Solaris-specific stuff
        if platform == "i86pc":
            # FIXME (20050629): i86pc should be probably added to the DB
            #platform = "i386"
            model = "i386"
        else:
            model = "sparc"

        stdout = os.popen("psrinfo -v")
        lines = stdout.readlines()
        stdout.close()

        for line in lines:
            matches = re.search(' (\S+) processor operates at (\d+) ', line)
            if matches:
                model, mhz = matches.groups()
                count = count + 1

        if not count: count = 1
        

    hwdict = {'class':'CPU',
              'desc': 'processor',
              'platform': platform,
              'count': str(count),
              'type': ptype,
              'model': model,
              'model_number': model_number,
              'model_ver': model_ver,
              'model_rev': model_rev,
              'speed': str(mhz)}

    return hwdict
    

# figure out how much ram is in the box
def read_memory():
    swap = 0
    megs = 0
    memdict= {}
    memdict['class'] = "MEMORY"
    uname = os.uname()
    system = uname[0]
    release = uname[2]
    if system == "HP-UX":
        # PORTME HP-specific stuff
        rev=int(release.split(".")[1])

        if rev > 9:
            hpux="/stand/vmunix"
        else:
            hpux="/hp-ux"

        if rev > 10:
            memsym="memory_installed_in_machine"
        else:
            memsym="physmem"

        ret=GetKernelSymbol(memsym, hpux)
        megs=int(ret)*4/1024

        stdout = os.popen("swapinfo -dmq")
        ret=stdout.read()
        stdout.close()
        swap=int(ret)
    elif system == "AIX":
        # PORTME AIX-specific stuff
        stdout = os.popen("/usr/sbin/lsattr -El sys0 -a realmem")
        line = stdout.read()
        stdout.close()
        matches = re.search('realmem (\d+)', line)
        if matches:
            kbytes_ram = matches.group(1)
        else:
            kbytes_ram = "0"
        megs=int(kbytes_ram)/1024

        stdout = os.popen("/usr/sbin/lsps -s")
        while 1:
            line = stdout.read()
            if not line: break
            matches = re.search('(\d+)MB', line)
            if matches:
                swap = matches.group(1)
                break
        stdout.close()
    else:
        # PORTME Solaris-specific stuff
        line = string.strip(os.popen("swap -s").read())
        matches = re.search(' (\d+)k used, (\d+)k available', line)
        if matches:
            used, avail = matches.groups()
            swap = (int(used)+int(avail))/1024
        pipe = os.popen("prtconf")
        while 1:
            line = pipe.readline()
            if not line: break
            matches = re.search('Memory size: (\d+) Megabytes', line)
            if matches:
                megs = matches.group(1)
                break
        pipe.close()

    memdict['ram'] = str(megs)
    memdict['swap'] = str(swap)
    return memdict


# in theory, this should be portable
def findHostByRoute():
    cfg = config.initUp2dateConfig()
    s = socket.socket()
    serverUrl = cfg['serverURL']
    server = string.split(serverUrl, '/')[2]
    port = 80
    if cfg['enableProxy']:
        server_port = rhnUtils.getProxySetting()
        (server, port) = string.split(server_port, ':')
        port = int(port)

    s.connect((server, port))
    (intf, port) = s.getsockname()
    try:
        hostname = socket.gethostbyaddr(intf)[0]
    # I dislike generic excepts, but is the above fails
    # for any reason, were not going to be able to
    # find a good hostname....
    except:
        hostname = "unknown"
    s.close()
    return hostname, intf

# in theory, portable
def read_network():
    netdict = {}
    netdict['class'] = "NETINFO"
    
    hostname = socket.gethostname()
    netdict['hostname'] = hostname
    try:
        netdict['ipaddr'] = socket.gethostbyname(hostname)
    except:
        netdict['ipaddr'] = "127.0.0.1"

    
    if netdict['hostname'] == 'localhost.localdomain' or \
	netdict['ipaddr'] == "127.0.0.1":
        hostname, ipaddr = findHostByRoute()
        netdict['hostname'] = hostname
        netdict['ipaddr'] = ipaddr

    return netdict

# PORTME: if you are bored, right code to find
# all the network interfaces, their ips, etc
def read_network_interfaces():
    intDict = {}
    intDict['class'] = "NETINTERFACES"
    interface = "eth99"
    hwaddr = "00:00:00:00:00:00"
    ipaddr = "127.0.0.1"
    netmask = "255.255.255.0"
    broadcast = "127.0.0.1"
    module = "whatever"
    intDict[interface] = {'hwaddr':hwaddr,
                              'ipaddr':ipaddr,
                              'netmask':netmask,
                              'broadcast':broadcast,
                              'module': module}

    return intDict
    
    
# this one reads it all
def Hardware():
    allhw = []
    ret = read_hwconf()
    if ret: # kudzu returns a list
        allhw = ret
    # all others return individual arrays

    # cpu info
    ret = read_cpuinfo()
    if ret: allhw.append(ret)

    # memory size info
    ret = read_memory()
    if ret: allhw.append(ret)

    # minimal networking info
    ret = read_network()
    if ret: allhw.append(ret)


#   ret = read_network_interfaces()
#    if ret:
#        allhw.append(ret)
        
    # all Done.
    return allhw

# XXX: Need more functions here:
#  - filesystems layout (/proc.mounts and /proc/mdstat)
#  - is the kudzu config enough or should we strat chasing lscpi and try to parse that
#    piece of crap output?

#
# Main program
#
if __name__ == '__main__':
    for hw in Hardware():
        for k in hw.keys():
            print "'%s' : '%s'" % (k, hw[k])
        print
