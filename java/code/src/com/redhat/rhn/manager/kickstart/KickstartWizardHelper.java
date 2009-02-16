/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.manager.kickstart;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.kickstart.KickstartCommand;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.kickstart.KickstartVirtualizationType;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.kickstart.crypto.CryptoKey;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnpackage.PackageName;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerDistroCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerProfileCreateCommand;

import org.apache.log4j.Logger;

import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * Provides convenience methods for creating a kickstart profile.
 * 
 * @version $Rev $
 */
public class KickstartWizardHelper {
    
    protected User currentUser;
    private static Logger log = Logger.getLogger(KickstartWizardHelper.class);
    
    /**
     * Constructor
     * @param user Provides the security "context" for all subsequent calls
     */
    public KickstartWizardHelper(User user) {
        currentUser = user;
    }
    
    /**
     * Retrieve a list of trees based on the user's Org
     * @return list of KickstartableTrees
     */
    public List getKickstartableTrees() {
        return KickstartFactory.lookupKickstartTreesByOrg(currentUser.getOrg());
    }

    /**
     * Retrieve a list of the valid virtualization types
     * @return list of VirtualizationTypes
     */
    public List getVirtualizationTypes() {   
        // Filter out KVM if this is Satellite
        List types = KickstartFactory.lookupVirtualizationTypes();
        if (!Config.get().isSpacewalk()) {
            for (int i = 0; i < types.size(); i++) {
                KickstartVirtualizationType type =
                    (KickstartVirtualizationType) types.get(i);
                if (type.getLabel().equals(KickstartVirtualizationType.KVM_FULLYVIRT)) {
                    types.remove(i);
                }
            }            
        }
        return types;
    }

    /**
     * Retrieve a specific tree based on id and org id
     * @param id tree id
     * @return KickstartableTree if found, otherwise null
     */
    public KickstartableTree getKickstartableTree(Long id) {
        return KickstartFactory.lookupKickstartTreeByIdAndOrg(id, 
                currentUser.getOrg());
    }
    
    /**
     * Creates a new command and associates it to the owning kickstart
     * @param name command name
     * @param args command args
     * @param owner owning kickstart
     * @return newly created command
     */
    public KickstartCommand createCommand(String name, String args, 
            KickstartData owner) {
        KickstartCommand cmd = KickstartFactory.createKickstartCommand(owner, name);
        cmd.setArguments(args);
        if (owner.getCommands() == null) {
            owner.setCommands(new HashSet());
        }
        owner.getCommands().add(cmd);
        return cmd;
    }

    /**
     * Create repo specific kickstart commands. Should only ever be used for 
     * kickstart trees that are RHEL 5 or greater.
     * @param ksdata Kickstart data to modify.
     * @param downloadUrl Download url. (i.e. the argument to --url)
     */
    public void addRepoLocations(KickstartData ksdata, String downloadUrl) {
        log.debug("Adding repo locations for: " + downloadUrl);
        // for some reason our ks trees have preceeding rhn/kickstart in 
        // their basepath.  Need to swap that out with the downloadable
        // path to the repodata:
        // before: http://host/rhn/kickstart/ks-rhel-i386-server-5/Workstation
        // after:  http://host/kickstart/dist/ks-rhel-i386-server-5/Workstation
        String repoUrl = downloadUrl.replaceAll("rhn/kickstart", "kickstart/dist");
        addRepoLocation(ksdata, repoUrl, "Cluster");
        addRepoLocation(ksdata, repoUrl, "ClusterStorage");
        addRepoLocation(ksdata, repoUrl, "Workstation");
        addRepoLocation(ksdata, repoUrl, "VT");
        createCommand("key", "--skip", ksdata);
    }

    private void addRepoLocation(KickstartData ksdata, 
            String location, String name) {
        createCommand("repo", "--name=" + name + " --baseurl=" + location + "/" + name,
                ksdata);
    }
    
    /**
     * Looks up a PackageName based on its string name
     * @param name name of PackageName object
     * @return PackageName if found, else null
     */
    public PackageName findPackageName(String name) {
        return PackageFactory.lookupOrCreatePackageByName(name);
    }
    
    /**
     * Get list of available Channels for Kickstarting.
     * @return Collection of Channels.
     */
    public List getAvailableChannels() {
        List returnCollection = ChannelFactory
                .getKickstartableChannels(currentUser.getOrg());
        return returnCollection;
    }
    
    /**
     * Returns a list of KickstartableTrees available for a given channel id and org id
     * @param channelId base channel
     * @return list of KickstartableTree instances
     */
    public List getTrees(Long channelId) {
        List trees = KickstartFactory.lookupKickstartableTrees(channelId, 
                currentUser.getOrg());
        // Now we filter out an 
        List retval = new LinkedList();
        CobblerDistroCommand cmd = new CobblerDistroCommand(currentUser);
        
        List<Map> distros = cmd.getCobblerDistros();
        for (int i = 0; i < trees.size(); i++) {
            KickstartableTree tree = (KickstartableTree) trees.get(i);
            boolean hasCobblerDistro = false;
            for (Map row : distros) {
                log.debug("getDistroMap.ROW: " + row);
                String uid = (String) row.get("uid");
                if (uid.equals(tree.getCobblerId())) {
                    log.debug("tree [" + tree.getLabel() + 
                            "] has a cobbler distro.  Display it.");
                    hasCobblerDistro = true;
                }
            }
            if (hasCobblerDistro) {
                retval.add(tree);
            }
            else {
                log.error("This Kickstart tree " +
                        "does not have an associated " +
                        "cobbler distro: " + tree.getLabel());
            }
        }
        return retval;  
    }    

    /**
     * Returns a list of possible Virtualization types
     * @return list of VirtualizationType instances
     */
    
    /**
     * Store a newly created KickstartData
     * Sets created timestamp and the appropriate org
     * @param ksdata object to save
     */
    public void store(KickstartData ksdata) {
        
        if (ksdata.getCryptoKeys() != null) {
            // Setup the default CryptoKeys
            List keys = KickstartFactory.lookupCryptoKeys(this.currentUser.getOrg());
            if (keys != null && keys.size() > 0) {
                if (ksdata.getCryptoKeys() == null) {
                    ksdata.setCryptoKeys(new HashSet());
                }
                Iterator i = keys.iterator();
                while (i.hasNext()) {
                    CryptoKey key = (CryptoKey) i.next();
                    if (key.getCryptoKeyType().equals(
                            KickstartFactory.KEY_TYPE_SSL)) {
                        ksdata.getCryptoKeys().add(key);
                    }
                }
            }
        }
        ksdata.setOrg(currentUser.getOrg());
        ksdata.setCreated(new Date());
        if (!ksdata.isRawData()) {
            if (ksdata.getCommand("url") != null) {
                ksdata.getCommand("url").setCreated(new Date());
            }
            if (ksdata.getCommand("url") != null) {
                ksdata.getCommand("url").setCreated(new Date());
            }
        }

        ksdata.getKickstartDefaults().setCreated(new Date());
        
        // Setup the default KickstartSession for this KickstartData
        // We now do this because each profile needs a default key 
        // associated with it because of the way we store the actual
        // kickstart files on disk and have them templated through cobbler
        KickstartSessionCreateCommand kcmd = new KickstartSessionCreateCommand(
                this.currentUser.getOrg(), ksdata);
        kcmd.store();
        
        KickstartSession ksess = 
            KickstartFactory.lookupDefaultKickstartSessionForKickstartData(ksdata); 
        log.debug("Did we create the default session OK? : " +  ksess);
        
        KickstartFactory.saveKickstartData(ksdata, ksess);
        log.debug("KSData stored.  Calling cobbler.");
        CobblerProfileCreateCommand cmd =
            new CobblerProfileCreateCommand(ksdata, currentUser);
        cmd.store();
        log.debug("store() - done.");
    }
}
