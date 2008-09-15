#!/usr/bin/python
import sys
import socket

try:
    from rhn import rpclib
except ImportError:
    import xmlrpclib
    rpclib = xmlrpclib

ServerURL = "https://xmlrpc.rhn.redhat.com/XMLRPC"
CAFile = "/usr/share/rhn/RHNS-CA-CERT"

Server = rpclib.Server(ServerURL)
try:
    Server.use_CA_chain(CAFile)
except NotImplementedError:
    Server.add_trusted_cert(CAFile)

print "Testing SSL connectivity against %s ..." % (ServerURL,)

try:
    ret = Server.registration.welcome_message()
except socket.sslerror:
    print """
    Connectivity test ERROR: SSL Handshake failed

    This error can be caused by one or more of the following:
    - failure to update the RHN Certificate Authority file, which is
      located at `%s'
    - the time/date on this computer is out of sync. Please check your
      system's time and update it accordingly.
    """ % (CAFile,)
    ret = None
except:
    print """
    Connectivity test ERROR: Failed to connect to server

    This error can be caused by one or more of the following:
    - lack on Internet connectivity;
    - running behind a proxy server. Please try running up2date
      instead to test SSL functionality.
    """
    ret = None

if not ret:
    sys.exit(1)

print "Connectivity OK, test succeeded"
