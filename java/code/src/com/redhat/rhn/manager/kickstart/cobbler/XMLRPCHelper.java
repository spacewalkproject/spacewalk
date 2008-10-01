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

import com.redhat.rhn.common.conf.Config;

import org.apache.log4j.Logger;

import java.net.MalformedURLException;
import java.util.List;

import redstone.xmlrpc.XmlRpcClient;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcFault;

/**
 * 
 * XMLRPCHelper - class that contains helpful logic for calling an XMLRPC server
 * @version $Rev$
 */
public class XMLRPCHelper implements XMLRPCInvoker {
    
    private XmlRpcClient client;
    
    private static Logger log = Logger.getLogger(XMLRPCHelper.class);
    
    /**
     * Constructor
     */
    public XMLRPCHelper() {
        try {
            client = new XmlRpcClient(Config.get().
                    getCobblerServerUrl(), false);
        }
        catch (MalformedURLException e) {
            throw new RuntimeException(e);
        }
    }
    
    /**
     * Invoke an XMLRPC method.
     * @param procedureName to invoke
     * @param args to pass to method
     * @return Object returned.
     */
    public Object invokeXMLRPC(String procedureName, List args) {
        log.debug("procedure: " + procedureName + " Orig ags: " + args);
        Object retval;
        
        try {
            log.debug("args array: " + args);
            retval = client.invoke(procedureName, args);
            
        } 
        catch (XmlRpcException e) {
            throw new RuntimeException("XmlRpcException calling cobbler.", e);
        } 
        catch (XmlRpcFault e) {
            throw new RuntimeException("XmlRpcException calling cobbler.", e);
        }
        if (retval instanceof String) {
            retval = retval + "\n";
        }
        return retval;
    }


}
