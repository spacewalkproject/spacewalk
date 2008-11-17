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
package com.redhat.rhn.manager.kickstart;

import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.kickstart.KickstartGuestAction;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.action.ActionManager;

import org.apache.log4j.Logger;

import java.util.Date;
import java.util.LinkedList;

/**
 * Provides frequently used data for scheduling a kickstart
 * 
 * @version $Rev $
 */
public class ProvisionVirtualInstanceCommand extends KickstartScheduleCommand {
    
    private static Logger log = Logger.getLogger(ProvisionVirtualInstanceCommand.class);
    
    private String guestName;
    private String memoryAllocation;
    private String virtualCpus;
    private String storageType;
    private String localStorageMb;

    /**
     * Constructor
     * @param selectedServer server to kickstart
     * @param userIn user performing the kickstart
     */
    public ProvisionVirtualInstanceCommand(Long selectedServer, User userIn) {
        super(selectedServer, null, null, userIn, null, null);
        this.setActivationType(ACTIVATION_TYPE_EXISTING);
        this.setPackagesToInstall(new LinkedList());
        this.setStaticDevice("");        
    }
    
    /**
     * Constructor to be used when you want to call the store() 
     * method.
     * 
     * @param selectedServer server to kickstart
     * @param ksid id of the KickstartData we are using
     * @param userIn user performing the kickstart
     * @param scheduleDateIn Date to schedule the KS.
     * @param kickstartServerNameIn the name of the server who is kickstarting 
     *                              this machine 
     */
    public ProvisionVirtualInstanceCommand(Long selectedServer, Long ksid, 
            User userIn, Date scheduleDateIn, String kickstartServerNameIn) {

        // We'll pass in the host server here, since the host server is the
        // only one that exists.

        super(selectedServer, null, ksid, userIn, scheduleDateIn, kickstartServerNameIn);
        this.setScheduleDate(scheduleDateIn);
        this.setKsdata(KickstartFactory.
            lookupKickstartDataByIdAndOrg(userIn.getOrg(), ksid));
        this.setKickstartServerName(kickstartServerNameIn);
        assert (this.getKsdata() != null);
    }

    /**
     * @param prereqAction the prerequisite for this action
     *
     * @return Returns the rebootAction (if any) - null for virtual
     * provisioning, since we don't want to reboot the host!
     */
    public Action scheduleRebootAction(Action prereqAction) {
        log.debug("** Skipping rebootAction - provisioning a virtual instance.");

        return null;
    }

    protected SelectMode getMode() {
        return ModeFactory.getMode("General_queries", 
                                   "virtual_kickstarts_channels_for_org");
    }

    /**
     * @param prereqAction the prerequisite for this action
     *
     * @return Returns the KickstartGuestAction
     */
    public Action scheduleKickstartAction(Action prereqAction) {
    
        KickstartSession ksSession = getKickstartSession();
    
        //TODO -- It feels a little dirty to pass in this & this.getExtraOptions,
        //but I don't know that I understand the implications of making getExtraOptions
        //a public method.
        KickstartGuestAction ksAction = (KickstartGuestAction)
            ActionManager.scheduleKickstartGuestAction(this, 
                                                       ksSession.getId());
    
        ksAction.setPrerequisite(prereqAction.getId());
        ActionFactory.save(ksAction);
    
        return (Action) ksAction;
    }

    /**
     * This is a noop in the virtualization case - up2date isn't required
     *
     * @return Returns a ValidatorError if something goes wrong.  ie, never
     */
    protected ValidatorError validateUp2dateVersion() {
        return null;
    }
 
    /**
     * @return Returns the guestName
     */
    public String getGuestName() {
        return this.guestName;
    }

    /**
     * @param guestNameIn the guestName to set.
     */
    public void setGuestName(String guestNameIn) {
        this.guestName = guestNameIn;
    }

    /**
     * @return Returns the memoryAllocation
     */
    public String getMemoryAllocation() {
        return memoryAllocation;
    }

    /**
     * @param memoryAllocationIn the memoryAllocation to set.
     */
    public void setMemoryAllocation(String memoryAllocationIn) {
        this.memoryAllocation = memoryAllocationIn;
    }

    /**
     * @return Returns the virtualCpus
     */
    public String getVirtualCpus() {
        return virtualCpus;
    }

    /**
     * @param virtualCpusIn the virtualCpus to set.
     */
    public void setVirtualCpus(String virtualCpusIn) {
        this.virtualCpus = virtualCpusIn;
    }

    /**
     * @return Returns the storageType
     */
    public String getStorageType() {
        return storageType;
    }

    /**
     * @param storageTypeIn the storageType to set.
     */
    public void setStorageType(String storageTypeIn) {
        this.storageType = storageTypeIn;
    }

    /**
     * @return Returns the localStorageMb
     */
    public String getLocalStorageMb() {
        return localStorageMb;
    }

    /**
     * @param localStorageMbIn the localStorageMb to set.
     */
    public void setLocalStorageMb(String localStorageMbIn) {
        this.localStorageMb = localStorageMbIn;
    }
    
}
