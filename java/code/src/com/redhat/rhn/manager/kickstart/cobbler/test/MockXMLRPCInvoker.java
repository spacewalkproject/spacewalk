/**
 * Copyright (c) 2009--2010 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public License,
 * version 2 (GPLv2). There is NO WARRANTY for this software, express or
 * implied, including the implied warranties of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
 * along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 *
 * Red Hat trademarks are not licensed under GPLv2. No permission is
 * granted to use or replicate Red Hat trademarks that are incorporated
 * in this software or its documentation.
 */
package com.redhat.rhn.manager.kickstart.cobbler.test;

import com.redhat.rhn.frontend.xmlrpc.util.XMLRPCInvoker;
import com.redhat.rhn.testing.TestUtils;

import org.apache.log4j.Logger;
import org.cobbler.test.MockConnection;

import java.util.List;

import redstone.xmlrpc.XmlRpcFault;

/**
 * Mock class for invoking xmlrpc
 * @author mmccune
 *
 */
public class MockXMLRPCInvoker implements XMLRPCInvoker {

    private static Logger log = Logger.getLogger(MockXMLRPCInvoker.class);

    public MockXMLRPCInvoker() {
        log.debug("Constructor: " + TestUtils.randomString());
    }

    public Object invokeMethod(String procedureName, List args)
        throws XmlRpcFault {
        MockConnection con = new MockConnection("url", "token");
        return con.invokeMethod(procedureName, args.toArray());
    }
}
