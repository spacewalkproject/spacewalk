/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.manager.kickstart.cobbler;

import java.util.List;

import redstone.xmlrpc.XmlRpcFault;

/**
 * Interface to implement to indicate a class can invoke XMLRPC calls
 * @version $Rev$
 */
public interface XMLRPCInvoker {
   
    /**
     * Invoke an XMLRPC method
     * @param procedureName to invoke
     * @param args to pass to method.
     * @return Object returned from xmlrpc
     * @throws XmlRpcFault if expected error occurs
     */
    Object invokeXMLRPC(String procedureName, List args) throws XmlRpcFault;
}
