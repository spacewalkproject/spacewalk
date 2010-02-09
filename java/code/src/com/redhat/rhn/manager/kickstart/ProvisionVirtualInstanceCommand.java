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
package com.redhat.rhn.manager.kickstart;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.kickstart.KickstartGuestAction;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.kickstart.KickstartVirtualizationType;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.kickstart.KickstartDto;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerSystemCreateCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerVirtualSystemCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.cobbler.Profile;

import java.io.File;
import java.util.Date;
import java.util.Iterator;
import java.util.LinkedList;

/**
 * Provides frequently used data for scheduling a kickstart
 * 
 * @version $Rev $
 */
public class ProvisionVirtualInstanceCommand extends KickstartScheduleCommand {
    
    private static Logger log = Logger.getLogger(ProvisionVirtualInstanceCommand.class);
    
    private String guestName;
    private Long memoryAllocation;
    private Long virtualCpus;
    private String storageType;
    private Long localStorage;
    private String filePath;
    private String virtBridge;


    /**
     * Constructor
     * @param selectedServer server to kickstart
     * @param userIn user performing the kickstart
     */
    public ProvisionVirtualInstanceCommand(Long selectedServer, User userIn) {
        super(selectedServer, null, (KickstartData)null, userIn, null, null);
        this.setPackagesToInstall(new LinkedList());
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
        this(selectedServer, KickstartFactory.
                        lookupKickstartDataByIdAndOrg(userIn.getOrg(), ksid),
                        userIn, scheduleDateIn, kickstartServerNameIn);
    }

    /**
     * Constructor to be used when you want to call the store() 
     * method.
     * 
     * @param selectedServer server to kickstart
     * @param ksData the KickstartData we are using
     * @param userIn user performing the kickstart
     * @param scheduleDateIn Date to schedule the KS.
     * @param kickstartServerNameIn the name of the server who is kickstarting 
     *                              this machine 
     */
    public ProvisionVirtualInstanceCommand(Long selectedServer, 
                                KickstartData ksData, 
            User userIn, Date scheduleDateIn, String kickstartServerNameIn) {

        // We'll pass in the host server here, since the host server is the
        // only one that exists.

        super(selectedServer, null, ksData, userIn, scheduleDateIn, kickstartServerNameIn);
    }    

    /**
     * Creates the Kickstart Sechdule command that works with a cobbler  only
     *  kickstart where the host and the target may or may *not* be
     * the same system.  If the target system does not yet exist, selectedTargetServer
     * should be null.  To be used when you want to call the store() method.
     * 
     * @param selectedServer server to host the kickstart
     * @param label cobbler only profile label.
     * @param userIn user performing the kickstart
     * @param scheduleDateIn Date to schedule the KS.
     * @param kickstartServerNameIn the name of the server who is serving the kickstart
     * @return the created cobbler only profile aware kickstartScheduleCommand
     */
    public static ProvisionVirtualInstanceCommand createCobblerScheduleCommand(
                                            Long selectedServer,
                                            String label, 
                                            User userIn, 
                                            Date scheduleDateIn, 
                                            String kickstartServerNameIn) {
        
        ProvisionVirtualInstanceCommand cmd = new 
                                        ProvisionVirtualInstanceCommand(selectedServer,
                     (KickstartData)null,  userIn, scheduleDateIn, kickstartServerNameIn);
        cmd.cobblerProfileLabel = label;
        cmd.cobblerOnly =  true;
        return cmd;
        
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

    
    @Override
    protected CobblerSystemCreateCommand getCobblerSystemCreateCommand(User userIn, 
            Server serverIn, KickstartData ksdataIn, String mediaPath, String tokenList) {
        return new CobblerVirtualSystemCommand(userIn, serverIn,
                ksdataIn, mediaPath, tokenList, guestName);
    }
    
    @Override
    protected CobblerSystemCreateCommand getCobblerSystemCreateCommand(User userIn, 
            Server serverIn, String cobblerProfileLabelIn) {
        return new CobblerVirtualSystemCommand(userIn, 
                serverIn, cobblerProfileLabelIn);
    }

    /**
     * @param prereqAction the prerequisite for this action
     *
     * @return Returns the KickstartGuestAction
     */
    public Action scheduleKickstartAction(Action prereqAction) {
    
        KickstartSession ksSession = getKickstartSession();
        Long sessionId = (ksSession != null) ? ksSession.getId() : null;
        //TODO -- It feels a little dirty to pass in this & this.getExtraOptions,
        //but I don't know that I understand the implications of making getExtraOptions
        //a public method.
        KickstartGuestAction ksAction = (KickstartGuestAction)
            ActionManager.scheduleKickstartGuestAction(this, sessionId);
        ksSession.setAction(ksAction);
        ksAction.setPrerequisite(prereqAction);
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
    public Long getMemoryAllocation() {
        return memoryAllocation;
    }

    /**
     * @param memoryAllocationIn the memoryAllocation to set.
     */
    public void setMemoryAllocation(Long memoryAllocationIn) {
        this.memoryAllocation = memoryAllocationIn;
    }

    /**
     * @return Returns the virtualCpus
     */
    public Long getVirtualCpus() {
        return virtualCpus;
    }

    /**
     * @param virtualCpusIn the virtualCpus to set.
     */
    public void setVirtualCpus(Long virtualCpusIn) {
        this.virtualCpus = virtualCpusIn;
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
    public Long getLocalStorageSize() {
        return localStorage;
    }

    /**
     * @param localStorageIn the localStorage to set.
     */
    public void setLocalStorageSize(Long localStorageIn) {
        this.localStorage = localStorageIn;
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public DataResult<? extends KickstartDto> getKickstartProfiles() {
        DataResult<? extends KickstartDto> result =  super.getKickstartProfiles();
        for (Iterator<? extends KickstartDto> itr = result.iterator(); itr.hasNext();) {
            KickstartDto dto  = itr.next();
            Profile prf = Profile.lookupById(
                    CobblerXMLRPCHelper.getConnection(this.getUser()), dto.getCobblerId());
            if (prf != null) {
                dto.setVirtBridge(prf.getVirtBridge());
                dto.setVirtCpus(prf.getVirtCpus());
                dto.setVirtMemory(prf.getVirtRam());
                dto.setVirtSpace(prf.getVirtFileSize());
            }
            else {
                itr.remove();
            }
        }
        return result;
    }

    
    /**
     * @return Returns the filePath.
     */
    public String getFilePath() {
        return filePath;
    }

    
    /**
     * @param filePathIn The filePath to set.
     */
    public void setFilePath(String filePathIn) {
        this.filePath = filePathIn;
        if (StringUtils.isBlank(filePath)) {
            filePath = makeDefaultVirtPath(getGuestName(),
                    getKsdata().getKickstartDefaults().getVirtualizationType());
        }
    }

    
    /**
     * @return Returns the virtBridge.
     */
    public String getVirtBridge() {
        return virtBridge;
    }

    
    /**
     * @param virtBridgeIn The virtBridge to set.
     */
    public void setVirtBridge(String virtBridgeIn) {
        this.virtBridge = virtBridgeIn;
    }
    
    /**
     * Method to set up the default virt path where the guset will be stored
     * based on the guest name.
     * @param name the name of the guest
     * @param type virtualization type to determine the virt paths
     *             its different for xen/kvm 
     * @return the virt path.
     */
    public static String makeDefaultVirtPath(String name,
                                KickstartVirtualizationType type) {
        File virtPathDir =  ConfigDefaults.get().getVirtPath(
                            KickstartVirtualizationType.xenPV().equals(type) ||
                                KickstartVirtualizationType.xenFV().equals(type));
        File virtPath = new File(virtPathDir, name.replace(' ', '-'));
        return virtPath.getAbsolutePath();
    }

}
