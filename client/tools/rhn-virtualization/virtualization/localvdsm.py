#!/usr/bin/python
#
# Copyright 2009 Red Hat, Inc.
#
# Contact vdsm running on localhost over xmlrpc (possibly over ssl)
#
# Dan Kenigsberg <danken@redhat.com>

import xmlrpclib
import subprocess
import sys

VDSM_DIR = '/usr/share/vdsm'
VDSM_CONF = '/etc/vdsm/vdsm.conf'

try:
    sys.path.append(VDSM_DIR)
    from config import config
    sys.path.pop()
    config.read(VDSM_CONF)
except:
    # VDSM not available
    raise ImportError('local vdsm not found')

def getTrustStorePath():
    tsPath = None
    if config.getboolean('vars', 'ssl'):
        tsPath = config.get('vars', 'trust_store_path')
    return tsPath

def getLocalVdsName(tsPath):
    p = subprocess.Popen(['/usr/bin/openssl', 'x509', '-noout', '-subject', '-in',
            '%s/certs/vdsmcert.pem' % tsPath],
            stdout=subprocess.PIPE, close_fds=True)
    out, err = p.communicate()
    if p.returncode != 0:
        return '0'
    return out.split('=')[-1].strip()

def connect():
    tsPath = getTrustStorePath()
    port = config.get('addresses', 'management_port')
    addr = getLocalVdsName(tsPath)
    if tsPath:
        from M2Crypto.m2xmlrpclib import SSL_Transport
        from M2Crypto import SSL

        KEYFILE = tsPath + '/keys/vdsmkey.pem'
        CERTFILE = tsPath + '/certs/vdsmcert.pem'
        CACERT = tsPath + '/certs/cacert.pem'

        ctx = SSL.Context ('sslv3')

        ctx.set_verify(SSL.verify_peer | SSL.verify_fail_if_no_peer_cert, 16)
        ctx.load_verify_locations(CACERT)
        ctx.load_cert(CERTFILE, KEYFILE)

        server = xmlrpclib.Server('https://%s:%s' % (addr, port),
                                SSL_Transport(ctx))
    else:
        server = xmlrpclib.Server('http://%s:%s' % (addr, port))
    return server

if __name__ == '__main__':
    server = connect()
    response = server.list(True)
    if response['status']['code'] != 0:
        print response['status']['message']
    else:
        for d in response['vmList']:
            print d

