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

import com.redhat.rhn.common.util.MethodUtil;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.KickstartableTree;

import org.apache.log4j.Logger;

import java.util.List;

/**
 * CobblerCommand - class to contain logic to communicate with cobbler
 * @version $Rev$
 */
public abstract class CobblerCommand {

    private static Logger log = Logger.getLogger(CobblerCommand.class);
    
    protected String xmlRpcToken;
    private XMLRPCInvoker invoker;

       
    /**
     * Construct a CobblerCommand
     * @param cobblerTokenIn - xmlrpc token for cobbler
     */
    public CobblerCommand(String cobblerTokenIn) {
        xmlRpcToken = cobblerTokenIn;
        log.debug("xmlrpc token for cobbler: " + xmlRpcToken);
        // We abstract this fetch of the class so a test class
        // can override the invoker with a mock xmlrpc invoker. 
        invoker = (XMLRPCInvoker) 
            MethodUtil.getClassFromConfig(XMLRPCHelper.class.getName());
    }

    /**
     * Sync the KickstartData to the Cobbler object
     *
     * @return ValidatorError if there is any errors 
     */
    public abstract ValidatorError store(); 
    
    
    /**
     * Invoke an XMLRPC method.
     * @param procedureName to invoke
     * @param args to pass to method
     * @return Object returned.
     */
    protected Object invokeXMLRPC(String procedureName, List args) {
        if (this.xmlRpcToken == null) {
            log.error("error, no cobbler token.  " +
                "spacewalk and cobbler will no longer be in sync");
            return null;
        }
        return invoker.invokeXMLRPC(procedureName, args);
    }
    
    // We have a naming convention for cobbler distros:
    // <channel label>--<ks tree label>    
    protected String getCobblerDistroName(KickstartableTree tree) {
        return tree.getChannel().getLabel() + 
            "--" + tree.getLabel(); 
    }

}
