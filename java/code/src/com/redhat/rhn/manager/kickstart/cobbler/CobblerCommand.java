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
package com.redhat.rhn.manager.kickstart.cobbler;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.util.MethodUtil;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.integration.IntegrationService;
import com.redhat.rhn.frontend.xmlrpc.util.XMLRPCInvoker;

import org.apache.log4j.Logger;
import org.cobbler.CobblerConnection;

import java.util.Arrays;
import java.util.List;

import redstone.xmlrpc.XmlRpcFault;

/**
 * CobblerCommand - class to contain logic to communicate with cobbler
 * @version $Rev$
 */
public abstract class CobblerCommand {

    private static Logger log = Logger.getLogger(CobblerCommand.class);

    protected String xmlRpcToken;
    protected User user;
    private XMLRPCInvoker invoker;


    /**
     * Construct a CobblerCommand
     * @param userIn - xmlrpc token for cobbler
     */
    public CobblerCommand(User userIn) {
        xmlRpcToken =
            IntegrationService.get().getAuthToken(userIn.getLogin());
        log.debug("xmlrpc token for cobbler: " + xmlRpcToken);
        // We abstract this fetch of the class so a test class
        // can override the invoker with a mock xmlrpc invoker.
        invoker = (XMLRPCInvoker)
            MethodUtil.getClassFromConfig(CobblerXMLRPCHelper.class.getName());
        user = userIn;
    }

    /**
     * Construct a CobblerCommand without using authentication
     *  This should only be used for taskomatic!
     */
    public CobblerCommand() {
        xmlRpcToken = IntegrationService.get().getAuthToken(
                ConfigDefaults.get().getCobblerAutomatedUser());
        log.debug("Unauthenticated Cobbler call");
        // We abstract this fetch of the class so a test class
        // can override the invoker with a mock xmlrpc invoker.
        invoker = (XMLRPCInvoker)
            MethodUtil.getClassFromConfig(CobblerXMLRPCHelper.class.getName());
        user = null;
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
            throw new NoCobblerTokenException("Tried to call: " + procedureName +
                    " but we don't have a cobbler token");
        }
        try {
            return invoker.invokeMethod(procedureName, args);
        }
        catch (XmlRpcFault e) {
            log.error("Error calling cobbler.", e);
            throw new RuntimeException(e);
        }
    }

    /**
     * Invoke an XMLRPC method.
     * @param procedureName to invoke
     * @param args to pass to method
     * @return Object returned.
     */
    protected Object invokeXMLRPC(String procedureName, Object ... args) {
        return invokeXMLRPC(procedureName, Arrays.asList(args));
    }

    /**
     * Makes a simple profile or distro object
     * name that 'd fit our cobbler naming convention
     * @param label the distro or profile label
     * @param org the org to appropriately add the org info
     * @return the cobbler name.
     */
    public static String makeCobblerName(String label, Org org) {
        String sep = ConfigDefaults.get().getCobblerNameSeparator();
        label = label.replace(' ', '_').replaceAll("[^a-zA-Z0-9_-]", "");

        if (org == null) {
            return label;
        }

        String orgName = org.getName().replaceAll("[^a-zA-Z0-9_-]", "").replace(' ', '_');
        String format = "%s" + sep + "%s" + sep + "%s";
        return String.format(format, label, org.getId(), orgName);

    }

    /**
     * Makes a local file path out of the cobbler name.
     *
     * Currently ends up in :
     *
     * /var/lib/rhn/kickstarts/label--orgid--orgname.cfg
     *
     * @param label the distro or profile label
     * @param org the org to appropriately add the org info
     * @return the cobbler file name in /var/lib/rhn/kickstarts/label--orgid--orgname.cfg
     */
    public static String makeCobblerFileName(String label, Org org) {
        if (org == null) {
            return label.replace(' ', '_');
        }
        String format = "%s--%s";
        String kickstartConfigDir = ConfigDefaults.get().getKickstartConfigDir();
        String fileName = String.format(format, label.replace(' ', '_'), org.getId());
        String retval = kickstartConfigDir + fileName + ".cfg";
        return retval;
    }

    /**
     * Make a cobbler name for a kickstartable tree
     * @param tree the tree
     * @return the name
     */
    public static String makeCobblerName(KickstartableTree tree) {
        return makeCobblerName(tree.getLabel(), tree.getOrg());
    }

    /**
     * Make a cobbler name for a kickstart profile
     * @param data the profile
     * @return the name
     */
    public static String makeCobblerName(KickstartData data) {
        return makeCobblerName(data.getLabel(), data.getOrg());
    }

    protected void invokeCobblerUpdate() {
        invokeXMLRPC("update", xmlRpcToken);
    }

    protected CobblerConnection getCobblerConnection() {
        return getCobblerConnection(user);
    }

    protected static CobblerConnection getCobblerConnection(User user) {
        if (user == null) {
            return CobblerXMLRPCHelper.getAutomatedConnection();
        }
        else {
            return CobblerXMLRPCHelper.getConnection(user);
        }
    }
}
