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

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartDefaults;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.kickstart.KickstartVirtualizationType;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.ActivationKeyFactory;
import com.redhat.rhn.domain.token.Token;
import com.redhat.rhn.domain.user.User;

import org.apache.log4j.Logger;
import org.cobbler.CobblerConnection;
import org.cobbler.Distro;
import org.cobbler.Profile;

import java.util.Iterator;
import java.util.Map;

/**
 * CobblerProfileComand - class to contain logic to communicate with cobbler
 * @version $Rev$
 */
public abstract class CobblerProfileCommand extends CobblerCommand {
    
    private static Logger log = Logger.getLogger(CobblerProfileCommand.class);

    private String kernelOptions;
    private String postKernelOptions;
    
    
    protected KickstartData ksData;
    
    /**
     * @param ksDataIn - KickstartData to sync
     * @param userIn - user wanting to sync with cobbler 
     */
    public CobblerProfileCommand(KickstartData ksDataIn, User userIn) {
        super(userIn);
        this.ksData = ksDataIn;
    }
    
    /**
     * Call this if you want to use the taskomatic_user.
     * 
     * Useful for automated non-user initiated syncs
     * 
     * @param ksDataIn - KickstartData to sync
     */
    public CobblerProfileCommand(KickstartData ksDataIn) {
        super();
        this.ksData = ksDataIn;
    }
    
    protected void updateCobblerFields(Profile profile) {
        if (getDistroForKickstart() != null) {
            profile.setDistro(getDistroForKickstart());
        }
        if (kernelOptions != null) {
            profile.setKernelOptions(kernelOptions);
        }
        if (postKernelOptions != null) {
            profile.setKernelPostOptions(postKernelOptions);
        }
        // redhat_management_key
        KickstartSession ksession = 
            KickstartFactory.lookupDefaultKickstartSessionForKickstartData(this.ksData); 
        if (ksession != null) {
            ActivationKey key = ActivationKeyFactory.lookupByKickstartSession(ksession);
            
            StringBuffer keystring = new StringBuffer();
            keystring.append(key.getKey());
            if (this.ksData.getDefaultRegTokens() != null) {
                log.debug("Adding associated activation keys.");
                Iterator i = this.ksData.getDefaultRegTokens().iterator();
                while (i.hasNext()) {
                    ActivationKey akey = 
                        ActivationKeyFactory.lookupByToken((Token) i.next());
                    keystring.append(",");
                    keystring.append(akey.getKey());
                }
            }
            log.debug("Setting setRedHatManagementKey to: " + keystring);
            profile.setRedHatManagementKey(keystring.toString());
        }
        else {
            log.warn("We could not find a default kickstart session for this ksdata: " + 
                    ksData.getLabel());
        }
        
        Map meta = profile.getKsMeta();
        meta.put("org", this.ksData.getOrg().getId());
        profile.setKsMeta(meta);
        
        // Check for para_host
        if (ksData.getKickstartDefaults().getVirtualizationType().
                getLabel().equals(KickstartVirtualizationType.PARA_HOST)) {
            profile.setVirtType(KickstartVirtualizationType.XEN_PARAVIRT);
        }
        //If we're using NONE, use KVM fully virt
        else if (ksData.getKickstartDefaults().getVirtualizationType().
                getLabel().equals(KickstartVirtualizationType.NONE)) {
            profile.setVirtType(KickstartVirtualizationType.KVM_FULLYVIRT);
        }
        else {
            profile.setVirtType(ksData.getKickstartDefaults().
                    getVirtualizationType().getLabel());
        }

        profile.save();
    }
    
    /**
     * Get the cobbler distro for a particular kickstart file
     *      selects the xen or non-xen cobbler distro depending
     *      upon the virt type
     * @return the distro object
     */
    public Distro getDistroForKickstart() {
        KickstartDefaults def = ksData.getKickstartDefaults();
        if (def ==  null) {
            return null;
        }
        return getCobblerDistroForVirtType(def.getKstree(), 
                ksData.getKickstartDefaults().getVirtualizationType(), user);
    }
    
    /**
     * @param kernelOptionsIn The kernelOptions to set.
     */
    public void setKernelOptions(String kernelOptionsIn) {
        this.kernelOptions = kernelOptionsIn;
    }


    
    /**
     * @param postKernelOptionsIn The postKernelOptions to set.
     */
    public void setPostKernelOptions(String postKernelOptionsIn) {
        this.postKernelOptions = postKernelOptionsIn;
    }

    /**
     * Get the cobbler distro for a particular tree and virt type combo
     *      selects the xen or non-xen cobbler distro depending
     *      upon the virt type
     * @param tree the kickstart tree
     * @param virtType the virt type
     * @param user the user doing the query
     * @return null if there is none, otherwise the cobbler distro
     */
    public static Distro getCobblerDistroForVirtType(KickstartableTree tree, 
            KickstartVirtualizationType virtType, User user) {
        CobblerConnection con = getCobblerConnection(user);
        if (virtType.equals(KickstartFactory.VIRT_TYPE_XEN_PV)) {
            if (tree.getCobblerXenId() == null) {
                return null;
            }
            else {
                return Distro.lookupById(con, tree.getCobblerXenId());
            }
        }
        else {
            return Distro.lookupById(con, tree.getCobblerId());
        }
    }
    
}
