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

import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.SortedSet;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.domain.kickstart.KickstartCommand;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.manager.kickstart.KickstartOptionsCommand;

import com.redhat.rhn.frontend.action.kickstart.KickstartHelper;
import com.redhat.rhn.frontend.xmlrpc.kickstart.XmlRpcKickstartHelper;

/**
 * ProfileHandler
 * @version $Rev$
 * @xmlrpc.namespace kickstart.profile
 * @xmlrpc.doc Provides methods to access and modify many aspects of 
 * a kickstart profile.
 */
public class ProfileHandler extends BaseHandler {
    
    /** 
     * Get advanced options for existing kickstart profile.
     * @param sessionKey User's session key. 
     * @param kslabel label of the kickstart profile to be updated.
     * @return An array of advanced options
     * @throws FaultException A FaultException is thrown if
     *         the profile associated with ksLabel cannot be found 
     *
     * @xmlrpc.doc Get advanced options for existing kickstart profile. 
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "kslabel", "Label of kickstart
     * profile to be changed.")
     * @xmlrpc.returntype 
     * #array()
     * $KickstartCommandSerializer
     * #array_end()
     */
    
    public Object[] getAdvancedOptions(String sessionKey, String kslabel)
    throws FaultException {
        User loggedInUser = getLoggedInUser(sessionKey);
        KickstartData ksdata = KickstartFactory.
            lookupKickstartDataByLabelAndOrgId(kslabel, loggedInUser.
                    getOrg().getId());
        if (ksdata == null) {
            throw new FaultException(-3, "kickstartProfileNotFound",
                    "No Kickstart Profile found with label: " + kslabel);
        }       
        
        Set options = ksdata.getOptions();
        return options.toArray();
    }

    
    /**
     * List custom options in a kickstart profile.
     * @param sessionKey the session key
     * @param ksLabel the kickstart label
     * @return a list of hashes holding this info.
     *
     * @xmlrpc.doc List custom options in a kickstart profile.
     * @xmlrpc.param #session_key() 
     * @xmlrpc.param #param("string","ksLabel")
     *  
     * @xmlrpc.returntype
     * #array()
     * $KickstartCommandSerializer
     * #array_end()
     */
    public Object[] getCustomOptions(String sessionKey, String ksLabel) {
        User user = getLoggedInUser(sessionKey);
        KickstartData k = KickstartFactory.lookupKickstartDataByLabelAndOrgId(
                ksLabel, user.getOrg().getId());
        SortedSet options = k.getCustomOptions();
        return options.toArray();
    }

   /**
    * Set custom options in a kickstart profile
    * @param sessionKey the session key
    * @param ksLabel the kickstart label
    * @param options the custom options to set
    * @return a int being the number of options set
    *
    * @xmlrpc.doc Set custom options in a kickstart profile
    * @xmlrpc.param #session_key()
    * @xmlrpc.param #param("string","ksLabel")
    * @xmlrpc.param #param("string[]","options")
    * @xmlrpc.returntype #return_int_success()
    */
   public int setCustomOptions(String sessionKey, String ksLabel, List<String> options) {
       User user = getLoggedInUser(sessionKey);
       KickstartData ksdata = 
               XmlRpcKickstartHelper.getInstance().lookupKsData(ksLabel, user.getOrg());
       Long ksid = ksdata.getId();
       KickstartHelper helper = new KickstartHelper(null);
       KickstartOptionsCommand cmd = new KickstartOptionsCommand(ksid, user, helper);
       Set customSet = new HashSet();
       if (options != null) {
           for (int i = 0; i < options.size(); i++) {
               String option = options.get(i);
               KickstartCommand custom = new KickstartCommand();
               custom.setCommandName(
                    KickstartFactory.lookupKickstartCommandName("custom"));
               
               // the following is a workaround to ensure that the options are rendered
               // on the UI on separate lines.
               if (i < (options.size() - 1)) {
                   option += "\r";
               } 
                   
               custom.setArguments(option);
               custom.setKickstartData(cmd.getKickstartData());
               custom.setCustomPosition(customSet.size());
               custom.setCreated(new Date());
               custom.setModified(new Date());
               customSet.add(custom);
           }
           cmd.getKickstartData().getCustomOptions().clear();
           cmd.getKickstartData().getCustomOptions().addAll(customSet);
           cmd.store();
       }
       return 1;
   }
}
