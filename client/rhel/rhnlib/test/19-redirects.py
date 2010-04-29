#!/usr/bin/python
#
#
#
# $Id$

import sys
sys.path.append('..')
from rhn.rpclib import Server, InvalidRedirectionError

_host = 'xmlrpc.rhn.webdev.redhat.com'

tests = [
    # Syntax: url, allow_redirect, should_fail, text_message
    ('http://%s/XMLRPC-REDIRECT' % _host, 1, None,
        "HTTP->HTTPS"),
    ('https://%s/XMLRPC-REDIRECT' % _host, 1, None,
        "HTTPS->HTTPS"),
    ('http://%s/XMLRPC-REDIRECT-NOSSL' % _host, 1, None,
        "HTTP->HTTP"),
    ('https://%s/XMLRPC-REDIRECT-NOSSL' % _host, 1, InvalidRedirectionError,
        "HTTPS->HTTP"),

    # These should fail
    ('http://%s/XMLRPC-REDIRECT' % _host, 0, InvalidRedirectionError,
        "HTTP->HTTPS"),
    ('https://%s/XMLRPC-REDIRECT' % _host, 0, InvalidRedirectionError,
        "HTTPS->HTTPS"),
    ('http://%s/XMLRPC-REDIRECT-NOSSL' % _host, 0, InvalidRedirectionError,
        "HTTP->HTTP"),
    ('https://%s/XMLRPC-REDIRECT-NOSSL' % _host, 0, InvalidRedirectionError,
        "HTTPS->HTTP"),
]

def main():
    if len(sys.argv) > 1:
        systemid_path = sys.argv[1]
    else:
        systemid_path = "/etc/sysconfig/rhn/systemid"
        print "Using %s as systemid (command line to override)" % systemid_path

    global SYSTEM_ID
    SYSTEM_ID = open(systemid_path).read()
    ret = 0
    for t in tests:
        ret = apply(run_test, t) or ret
    return ret


def run_test(url, allow_redirect, should_fail, text_message):
    global SYSTEM_ID
    
    message = "Running test: %s" % text_message

    print message,

    s = Server(url)
    s.allow_redirect(allow_redirect)

    try:
        s.up2date.login(SYSTEM_ID)
    except Exception, e:
        if should_fail and isinstance(e, should_fail):
            print "PASS"
            return 0

        print "FAIL (exception: %s)" % (e.__class__.__name__)
        return 1

    if should_fail:
        print "FAIL (no exception)"
        return 1

    print "PASS"
    return 0
        

if __name__ == '__main__':
    sys.exit(main() or 0)
