#!/usr/bin/python
#
# $Id$
"""
Tests a memory leak in the applet
"""

import sys
import string
import socket
from rhn import SSL

def main():
    server_name = "xmlrpc.rhn.redhat.com"
    server_port = 443
    ca_cert = "/usr/share/rhn/RHNS-CA-CERT"
    try:
        server_name = sys.argv[1]
        server_port = int(sys.argv[2])
        ca_cert = sys.argv[3]
    except:
        pass
    diff_count = 0


    mem_usage = None
    for i in range(10000):
        run_test(server_name, server_port, ca_cert)
        if i % 100 == 0:
            new_mem_usage = mem_usage_int()
            if mem_usage is not None:
                if mem_usage[1] != new_mem_usage[1]:
                    diff_count = diff_count + 1
            mem_usage = new_mem_usage

            print "memory usage: %s %s %s" % mem_usage[1:4]

    if diff_count > 4:
        # Failure
        print "Test FAILS"
        return diff_count

    print "Test PASSES"
    return 0
                

def run_test(server_name, server_port, ca_cert):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((server_name, server_port))

    sslsock = SSL.SSLSocket(sock, [ca_cert])
    sslsock.init_ssl()

    sslsock.close()

def mem_usage():
    f = open("/proc/self/status")
    dct = {}
    while 1:
        line = f.readline()
        if not line:
            break
        arr = map(string.strip, string.split(line, ':', 1))
        if len(arr) == 1:
            continue
        dct[arr[0]] = arr[1]
    return dct['Name'], dct['VmSize'], dct['VmRSS'], dct['VmData']

def mem_usage_int():
    memusage = mem_usage()
    ret = [memusage[0]]
    for val in memusage[1:4]:
        # Split it
        arr = string.split(val)
        try:
            v = int(arr[0])
        except ValueError:
            v = val
        ret.append(v)
    return tuple(ret)


def _line_value(line):
    arr = string.split(line, ':', 1)
    if len(arr) == 1:
        return None
    return string.strip(arr[1])

if __name__ == '__main__':
    sys.exit(main() or 0)

