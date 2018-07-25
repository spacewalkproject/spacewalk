#!/usr/bin/python
#
#
# USAGE:  $0 SERVER CERT
"""
Tests a memory leak in the applet
"""

import sys
from rhn import rpclib

def main():
    server_name = "xmlrpc.rhn.redhat.com"
    ca_cert = "/usr/share/rhn/RHNS-CA-CERT"
    try:
        server_name = sys.argv[1]
        ca_cert = sys.argv[2]
    except:
        pass
    server_url = "https://" + server_name + "/APPLET"

    mem_usage = None
    mem_usage_VmSize_max = None
    mem_usage_VmSize_first = None
    mem_usage_VmSize_allowed_percent = 0.5   # [%] allowed gain of first -> max
    for i in range(1,10000):
        run_test(server_url, ca_cert)
        if i % 100 == 0:
            new_mem_usage = mem_usage_int()
            if mem_usage is not None:
                if new_mem_usage[1] > mem_usage_VmSize_max:
                    mem_usage_VmSize_max = new_mem_usage[1]
            else:
                mem_usage_VmSize_max = new_mem_usage[1]
                mem_usage_VmSize_first = new_mem_usage[1]
            mem_usage = new_mem_usage

            print "memory usage: %s %s %s" % mem_usage[1:4]

    percent = float((mem_usage_VmSize_max - mem_usage_VmSize_first)) / (float(mem_usage_VmSize_first) / 100)
    if percent >= mem_usage_VmSize_allowed_percent:
        # Failure
        print "Test FAILS (%s %%)" % percent
        return 1

    print "Test PASSES"
    return 0

def run_test(server_url, ca_cert):
    s = rpclib.Server(server_url)
    s.add_trusted_cert(ca_cert)

    status = s.applet.poll_status()


def mem_usage():
    f = open("/proc/self/status")
    dct = {}
    while 1:
        line = f.readline()
        if not line:
            break
        arr = [s.strip() for s in line.split(':', 1)]
        if len(arr) == 1:
            continue
        dct[arr[0]] = arr[1]
    return dct['Name'], dct['VmSize'], dct['VmRSS'], dct['VmData']

def mem_usage_int():
    memusage = mem_usage()
    ret = [memusage[0]]
    for val in memusage[1:4]:
        # Split it
        arr = val.split()
        try:
            v = int(arr[0])
        except ValueError:
            v = val
        ret.append(v)
    return tuple(ret)

def _line_value(line):
    arr = line.split(':', 1)
    if len(arr) == 1:
        return None
    return arr[1].strip()

if __name__ == '__main__':
    sys.exit(main() or 0)
