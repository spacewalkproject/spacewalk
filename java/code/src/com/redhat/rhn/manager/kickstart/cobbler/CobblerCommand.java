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
import com.redhat.rhn.domain.kickstart.KickstartData;

import org.apache.log4j.Logger;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * KickstartCobblerCommand - class to contain logic to communicate with cobbler
 * @version $Rev$
 */
public abstract class CobblerCommand {

    private static Logger log = Logger.getLogger(CobblerCommand.class);
    
    protected String xmlRpcToken;
    private XMLRPCInvoker invoker;
    protected KickstartData ksData;
    
    /**
     * Construct a KickstartCloneCommand
     * @param ksDataIn KickstartData we are sychronizing to Cobbler
     * @param cobblerTokenIn - xmlrpc token for cobbler
     */
    public CobblerCommand(KickstartData ksDataIn, String cobblerTokenIn) {
        this.ksData = ksDataIn;
        xmlRpcToken = cobblerTokenIn;
        log.debug("xmlrpc token for cobbler: " + xmlRpcToken);
        if (xmlRpcToken == null) {
            throw new IllegalStateException("we don't have a cobbler token!");
        }
        
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
     * Get the Cobbler profile associated with this KickstartData
     * @return Map of Cobbler profile fields.
     */
    public Map getProfile() {
        List < String > args = new ArrayList();
        args.add(this.ksData.getCobblerName());
        args.add(xmlRpcToken);
        Map retval = (Map) invokeXMLRPC("get_profile", args);
        return retval;
    }
    
    /**
     * Get the distribution associated with the current KickstartData
     * @return Map of cobbler distro fields.
     */
    public Map getDistro() {
        List < String > args = new ArrayList();
        args.add(this.ksData.getKsdefault().getKstree().getCobblerDistroName());
        args.add(xmlRpcToken);
        Map retval = (Map) invokeXMLRPC("get_distro", args);
        return retval;
    }



    /**
     * Invoke an XMLRPC method.
     * @param procedureName to invoke
     * @param args to pass to method
     * @return Object returned.
     */
    protected Object invokeXMLRPC(String procedureName, List args) {
        return invoker.invokeXMLRPC(procedureName, args);
    }
    
}
