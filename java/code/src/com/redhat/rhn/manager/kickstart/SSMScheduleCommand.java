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

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.kickstart.ScheduleKickstartWizardAction;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;
import com.redhat.rhn.manager.system.SystemManager;

import org.cobbler.Profile;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * 
 * SSMScheduleCommand
 * @version $Rev$
 */
public class SSMScheduleCommand {

    
    
    // Required attributes
    private User user;
    private Date scheduleDate;
    private List<SystemOverview> systems;
    private boolean isCobblerOnly = false;
    private boolean isIpBasedKs = false;
    
    //Optional 
    private String cobblerProfileName;
    private KickstartData ksdata;
 
    private String profileType;  
    private Long packageProfileId;
    private Long serverProfileId;

    private Server proxy;
    
    private List<Action> scheduledActions =  new ArrayList<Action>();

    
    private String kernelParamType;
    private String customKernelParams;
    
    private String postKernelParamType;
    private String customPostKernelParams;
    
    
    
    /**
     * Constructor for SSMScheduleCommand when we've selected a kickstart
     *      profile
     * @param userIn the user
     * @param systemsIn List of SystemOverview's to provision
     * @param dateIn the date to schedule it for
     * @param ksdataIn the kickstartData
     */
    public SSMScheduleCommand(User userIn, List<SystemOverview> systemsIn, Date dateIn, 
                                         KickstartData ksdataIn) {
        user = userIn;
        systems = systemsIn;
        scheduleDate = dateIn;
        ksdata = ksdataIn;
    }
    
    /**
     * Constructor for SSMScheduleCommand when we've selected a cobbler-only
     *      profile
     * @param userIn the user
     * @param systemsIn List of SystemOverview's to provision
     * @param dateIn the date to schedule it for
     * @param cobblerProfileNameIn the cobbler  profile's name 
     */
    public SSMScheduleCommand(User userIn, List<SystemOverview> systemsIn, Date dateIn, 
            String cobblerProfileNameIn) {
        user = userIn;
        systems = systemsIn;
        scheduleDate = dateIn;
        cobblerProfileName = cobblerProfileNameIn;
        isCobblerOnly = true;
    }    
    
    
    private SSMScheduleCommand() {
        
    }
    
    /**
     * Get a SSMScheduleCommand when were using IP ADDRESS 
     *  base kickstarting
     * @param userIn the user
     * @param systemsIn List of SystemOverview's to provision
     * @param dateIn the date to schedule it for
     * @return the SSMScheduleCommand
     */
    public static SSMScheduleCommand initCommandForIPKickstart(User userIn, 
            List<SystemOverview> systemsIn, Date dateIn) {
        SSMScheduleCommand com = new SSMScheduleCommand();
        com.user = userIn;
        com.systems = systemsIn;
        com.scheduleDate = dateIn;
        com.isIpBasedKs = true;
        return com;
    }    
    
    
    
    /**
     * @param profileTypeIn The profileType to set.
     */
    public void setProfileType(String profileTypeIn) {
        this.profileType = profileTypeIn;
    }

    /**
     * @param packageProfileIdIn The packageProfileId to set.
     */
    public void setPackageProfileId(Long packageProfileIdIn) {
        this.packageProfileId = packageProfileIdIn;
    }

    /**
     * @param serverProfileIdIn The serverProfileId to set.
     */
    public void setServerProfileId(Long serverProfileIdIn) {
        this.serverProfileId = serverProfileIdIn;
    }
    
    /**
     * @return Returns the storedActions.
     */
    public List<Action> getScheduledActions() {
        return scheduledActions;
    }
    
    
    /**
     * Store the Command 
     * @return list of ValidatorErrors that were encountered
     */
    public List<ValidatorError> store() {
        List<ValidatorError> errors = new ArrayList<ValidatorError>();
        
        for (SystemOverview sys : systems) {
            ValidatorError e = scheduleSystem(sys.getId());
            if (e != null) {
                errors.add(e);
            }
        }
        return errors;
    }


    
    private ValidatorError scheduleSystem(Long sid) {
        
        KickstartData uniqueKs = ksdata;
        String profileId = "";
        
        
        if (isIpBasedKs) {
            Server ser = SystemManager.lookupByIdAndUser(sid, user);
            uniqueKs = KickstartManager.getInstance().findProfileForServersNetwork(ser);
        }
        
        KickstartScheduleCommand com;
        if (isCobblerOnly) {
            com = KickstartScheduleCommand.createCobblerScheduleCommand(sid, 
                    cobblerProfileName, user, scheduleDate, null);
            Profile prof = Profile.lookupById(CobblerXMLRPCHelper.getConnection(user), 
                    cobblerProfileName);
            profileId = prof.getId();
        }
        else {
            com =  new KickstartScheduleCommand(sid, uniqueKs, user, scheduleDate, 
                    null);
            
            profileId = uniqueKs.getCobblerId();
        }
        
        
        
        com.setKernelOptions(ScheduleKickstartWizardAction.parseKernelOptions(
                         customKernelParams, kernelParamType, profileId, false, user));
        com.setPostKernelOptions(ScheduleKickstartWizardAction.parseKernelOptions(
                customPostKernelParams, postKernelParamType, profileId, true, user));
        com.setProfileType(profileType);
        com.setProfileId(packageProfileId);
        com.setServerProfileId(serverProfileId);
        com.setProxy(proxy);
        ValidatorError error = com.store();
        
        this.scheduledActions.add(com.getScheduledAction());
        return error;
    }

    
    /**
     * @param proxyIn The proxy to set.
     */
    public void setProxy(Server proxyIn) {
        this.proxy = proxyIn;
    }


    /**
     * @param kernelParamTypeIn The kernelParamType to set.
     */
    public void setKernelParamType(String kernelParamTypeIn) {
        this.kernelParamType = kernelParamTypeIn;
    }

    
    /**
     * @param customKernelParamsIn The customKernelParams to set.
     */
    public void setCustomKernelParams(String customKernelParamsIn) {
        this.customKernelParams = customKernelParamsIn;
    }

    
    /**
     * @param postKernelParamTypeIn The postKernelParamType to set.
     */
    public void setPostKernelParamType(String postKernelParamTypeIn) {
        this.postKernelParamType = postKernelParamTypeIn;
    }

    
    /**
     * @param customPostKernelParamsIn The customPostKernelParams to set.
     */
    public void setCustomPostKernelParams(String customPostKernelParamsIn) {
        this.customPostKernelParams = customPostKernelParamsIn;
    }



    
    
}
