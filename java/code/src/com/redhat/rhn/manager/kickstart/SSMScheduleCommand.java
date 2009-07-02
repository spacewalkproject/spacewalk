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
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.manager.system.SystemManager;

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
    private String kickstartServerName;
    private List<SystemOverview> systems;
    private boolean isCobblerOnly = false;
    private boolean isIpBasedKs = false;
    
    //Optional 
    private String cobblerProfileName;
    private KickstartData ksdata;
 
    private String profileType;  
    private Long packageProfileId;
    private Long serverProfileId;


    private String kernelOptions;
    private String postKernelOptions;    
    
    private List<Action> scheduledActions =  new ArrayList<Action>();

    
    
    /**
     * Constructor for SSMScheduleCommand when we've selected a kickstart
     *      profile
     * @param userIn the user
     * @param systemsIn List of SystemOverview's to provision
     * @param dateIn the date to schedule it for
     * @param kickstartHostIn the kickstart hostname (proxy's or satellite's)
     * @param ksdataIn the kickstartData
     */
    public SSMScheduleCommand(User userIn, List<SystemOverview> systemsIn, Date dateIn, 
                                         String kickstartHostIn, KickstartData ksdataIn) {
        user = userIn;
        systems = systemsIn;
        scheduleDate = dateIn;
        kickstartServerName = kickstartHostIn;
        ksdata = ksdataIn;
    }
    
    /**
     * Constructor for SSMScheduleCommand when we've selected a cobbler-only
     *      profile
     * @param userIn the user
     * @param systemsIn List of SystemOverview's to provision
     * @param dateIn the date to schedule it for
     * @param kickstartHostIn the kickstart hostname (proxy's or satellite's)
     * @param cobblerProfileNameIn the cobbler  profile's name 
     */
    public SSMScheduleCommand(User userIn, List<SystemOverview> systemsIn, Date dateIn, 
            String kickstartHostIn, String cobblerProfileNameIn) {
        user = userIn;
        systems = systemsIn;
        scheduleDate = dateIn;
        kickstartServerName = kickstartHostIn;
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
     * @param kickstartHostIn the kickstart hostname (proxy's or satellite's)
     */
    public static SSMScheduleCommand initCommandForIPKickstart(User userIn, 
            List<SystemOverview> systemsIn, Date dateIn, String kickstartHostIn) {
        SSMScheduleCommand com = new SSMScheduleCommand();
        com.user = userIn;
        com.systems = systemsIn;
        com.scheduleDate = dateIn;
        com.kickstartServerName = kickstartHostIn;
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
        
        if (isIpBasedKs) {
            Server ser = SystemManager.lookupByIdAndUser(sid, user);
            uniqueKs = KickstartManager.findProfileForServersNetwork(ser);
        }
        
        KickstartScheduleCommand com;
        if (isCobblerOnly) {
            com = KickstartScheduleCommand.createCobblerScheduleCommand(sid, 
                    cobblerProfileName, user, scheduleDate, kickstartServerName);
        }
        else {
            com =  new KickstartScheduleCommand(sid, uniqueKs, user, scheduleDate, 
                    kickstartServerName);
        }
        
        com.setKernelOptions(kernelOptions);
        com.setPostKernelOptions(postKernelOptions);
        com.setProfileType(profileType);
        com.setProfileId(packageProfileId);
        com.setServerProfileId(serverProfileId);
        ValidatorError error = com.store();
        
        this.scheduledActions.add(com.getScheduledAction());
        return error;
    }

    
}
