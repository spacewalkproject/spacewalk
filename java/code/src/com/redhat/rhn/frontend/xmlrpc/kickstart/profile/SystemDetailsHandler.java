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

package com.redhat.rhn.frontend.xmlrpc.kickstart.profile;

import com.redhat.rhn.domain.kickstart.SELinuxMode;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.kickstart.XmlRpcKickstartHelper;
import com.redhat.rhn.manager.kickstart.SystemDetailsCommand;

/**
* SystemDetailsHandler
* @xmlrpc.namespace kickstart.profile.system
* @xmlrpc.doc Provides methods to set various properties of a kickstart profile.
* @version $Rev$
*/
public class SystemDetailsHandler extends BaseHandler {

    /**
     * Enables the configuration management flag in a kickstart profile 
     * so that a system created using this profile will be configuration capable.
     * @param sessionKey the session key
     * @param ksLabel the ks profile label 
     * @return 1 on success
     * 
     * 
     * @xmlrpc.doc Enables the configuration management flag in a kickstart profile 
     * so that a system created using this profile will be configuration capable.
     * @xmlrpc.param #session_key() 
     * @xmlrpc.param #param_desc("string", "ksLabel","the kickstart profile label")
     * @xmlrpc.returntype #return_int_success()
     */
    public int enableConfigManagement(String sessionKey, String ksLabel) {
        return setConfigFlag(sessionKey, ksLabel, true);
    }

    /**
     * Disables the configuration management flag in a kickstart profile 
     * so that a system created using this profile will be NOT be configuration capable.
     * @param sessionKey the session key
     * @param ksLabel the ks profile label
     * @return 1 on success
     * 
     * @xmlrpc.doc Disables the configuration management flag in a kickstart profile 
     * so that a system created using this profile will be NOT be configuration capable.   
     * @xmlrpc.param #session_key() 
     * @xmlrpc.param #param_desc("string", "ksLabel","the kickstart profile label")
     * @xmlrpc.returntype #return_int_success()

     */
    public int disableConfigManagement(String sessionKey, String ksLabel) {
        return setConfigFlag(sessionKey, ksLabel, false);
    }
    
    private int setConfigFlag(String sessionKey, String ksLabel, boolean flag) {
        User user = getLoggedInUser(sessionKey);
        ensureConfigAdmin(user);
        SystemDetailsCommand command  = getSystemDetailsCommand(ksLabel, user);
        command.enableConfigManagement(flag);
        command.store();
        return 1;
    }
    
    /**
     * Enables the remote command flag in a kickstart profile 
     * so that a system created using this profile 
     * will be capable of running remote commands
     * @param sessionKey the session key
     * @param ksLabel the ks profile label
     * @return 1 on success
     * 
     * @xmlrpc.doc Enables the remote command flag in a kickstart profile 
     * so that a system created using this profile
     *  will be capable of running remote commands
     * @xmlrpc.param #session_key() 
     * @xmlrpc.param #param_desc("string", "ksLabel","the kickstart profile label")
     * @xmlrpc.returntype #return_int_success()
     */
    public int enableRemoteCommands(String sessionKey, String ksLabel) {
        return setRemoteCommandsFlag(sessionKey, ksLabel, true);
    }

    /**
     * Disables the remote command flag in a kickstart profile 
     * so that a system created using this profile
     * will be capable of running remote commands
     * @param sessionKey the session key
     * @param ksLabel the ks profile label
     * @return 1 on success
     * 
     * @xmlrpc.doc Disables the remote command flag in a kickstart profile 
     * so that a system created using this profile
     * will be capable of running remote commands
     * @xmlrpc.param #session_key() 
     * @xmlrpc.param #param_desc("string", "ksLabel","the kickstart profile label")
     * @xmlrpc.returntype #return_int_success()

     */
    public int disableRemoteCommands(String sessionKey, String ksLabel) {
        return setRemoteCommandsFlag(sessionKey, ksLabel, false);
    }
    
    private int setRemoteCommandsFlag(String sessionKey, String ksLabel, boolean flag) {
        User user = getLoggedInUser(sessionKey);
        ensureConfigAdmin(user);
        SystemDetailsCommand command  = getSystemDetailsCommand(ksLabel, user);
        command.enableRemoteCommands(flag);
        command.store();
        return 1;
    }
    
    /**
     * Sets the SELinux enforcing mode property of a kickstart profile 
     * so that a system created using this profile will be have 
     * the appropriate SELinux enforcing mode.
     * @param sessionKey the session key
     * @param ksLabel the ks profile label
     * @param enforcingMode the SELinux enforcing mode. 
     * @return 1 on success
     * 
     * @xmlrpc.doc Sets the SELinux enforcing mode property of a kickstart profile 
     * so that a system created using this profile will be have 
     * the appropriate SELinux enforcing mode.
     * @xmlrpc.param #session_key() 
     * @xmlrpc.param #param_desc("string", "ksLabel","the kickstart profile label")
     * @xmlrpc.param #param_desc("string", "enforcingMode","the selinux enforcing mode")
     *      #options()
     *          #item ("enforcing")
     *          #item ("permissive")
     *          #item ("disabled")
     *      #options_end()
     * @xmlrpc.returntype #return_int_success()
     */
    public int setSELinux(String sessionKey, String ksLabel, String enforcingMode) {
        User user = getLoggedInUser(sessionKey);
        ensureConfigAdmin(user);
        SystemDetailsCommand command  = getSystemDetailsCommand(ksLabel, user);
        command.setMode(SELinuxMode.lookup(enforcingMode));
        return setRemoteCommandsFlag(sessionKey, ksLabel, true);
    }

    /**
     * Sets the network device property of a kickstart profile 
     * so that a system created using this profile will be have 
     * the appropriate network device associated to it.
     * @param sessionKey the session key
     * @param ksLabel the ks profile label
     * @param isDhcp true if the network device uses DHCP
     * @param interfaceName network interface name
     * @return 1 on success
     * 
     * @xmlrpc.doc Sets the network device property of a kickstart profile 
     * so that a system created using this profile will be have 
     * the appropriate network device associated to it.
     * @xmlrpc.param #session_key() 
     * @xmlrpc.param #param_desc("string", "ksLabel","the kickstart profile label")
     * @xmlrpc.param #param("int", "isDhcp")
     *      #options()
     *          #item_desc ("1", 
     *          "to set the network type of the connection type to dhcp")
     *          #item_desc ("0", 
     *          "to set the network type of the connection type to static device")
     *      #options_end()
     * @xmlrpc.param #param("string", "interfaceName",
     *                           "name of the network interface- eg:- eth0")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setNetworkConnection(String sessionKey, String ksLabel, 
                                            boolean isDhcp, String interfaceName) {
        User user = getLoggedInUser(sessionKey);
        ensureConfigAdmin(user);
        SystemDetailsCommand command  = getSystemDetailsCommand(ksLabel, user);
        
        command.setNetworkDevice(interfaceName, isDhcp);
        return setRemoteCommandsFlag(sessionKey, ksLabel, true);
    }
    
    private SystemDetailsCommand getSystemDetailsCommand(String label, User user) {
        XmlRpcKickstartHelper helper = XmlRpcKickstartHelper.getInstance();
        return new SystemDetailsCommand(helper.lookupKsData(label, user), user);
    }    
    
}
