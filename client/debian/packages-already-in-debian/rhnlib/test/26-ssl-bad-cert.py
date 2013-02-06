#!/usr/bin/python
#
# $Id$
"""
Negative test - make sure we raise an exception when the wrong SSL cert is
used
"""

import sys
import socket
from rhn import SSL

def main():
    server_name = "www.redhat.com"
    server_port = 443
    ca_cert = "/usr/share/rhn/RHNS-CA-CERT"
                
    try:
        run_test(server_name, server_port, ca_cert)
    except SSL.SSL.Error, e:
        if e[0][0][2] == 'certificate verify failed':
            print "test PASSES"
            return 0

        print "Test failed for unknown reasons:", e
        return 1

    print "Connection did not fail, test FAILS"
    return 1

def run_test(server_name, server_port, ca_cert):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((server_name, server_port))

    sslsock = SSL.SSLSocket(sock, [ca_cert])
    sslsock.init_ssl()
    sslsock.do_handshake()

    sslsock.close()

if __name__ == '__main__':
    sys.exit(main() or 0)


