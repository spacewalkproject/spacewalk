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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.profile.Profile;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.profile.ProfileManager;

import org.apache.commons.lang.BooleanUtils;
import org.apache.log4j.Logger;

import java.util.Date;
import java.util.Iterator;
import java.util.List;

/**
 * KickstartSessionCreateCommand - Command to create a KickstartSession object
 * @version $Rev$
 */
public class KickstartSessionCreateCommand {

    private static Logger log = Logger.getLogger(KickstartSessionCreateCommand.class);
    
    private KickstartSession ksession;
    
    /**
     * Constructor
     * @param owner who creates the session
     * @param ksdata KickstartData profile used for this session
     */
    public KickstartSessionCreateCommand(Org owner, KickstartData ksdata) {
        this(owner, ksdata, null);
    }    
    
    /**
     * Constructor
     * @param owner who creates the session
     * @param ksdata KickstartData profile used for this session
     * @param clientIp Client IP of the kickstarting system.
     */
    public KickstartSessionCreateCommand(Org owner, KickstartData ksdata, String clientIp) {
        this.ksession = new KickstartSession();
        this.ksession.setKickstartMode(KickstartSession.MODE_DEFAULT_SESSION);
        this.ksession.setOrg(owner);
        this.ksession.setDeployConfigs(Boolean.FALSE);
        this.ksession.setPackageFetchCount(new Long(0));
        this.ksession.setKsdata(ksdata);
        this.ksession.setVirtualizationType(ksdata
            .getKickstartDefaults().getVirtualizationType());
        this.ksession.setKstree(ksdata.getTree());
        this.ksession.setLastAction(new Date());
        this.ksession.setState(KickstartFactory.SESSION_STATE_CREATED);
        this.ksession.setClientIp(clientIp);
        log.debug("serverProfile on ksdata: " + ksdata.getKickstartDefaults().getProfile());
        if (ksdata.getKickstartDefaults().getProfile() != null) {
            Profile p = ProfileManager.
                lookupByIdAndOrg(ksdata.getKickstartDefaults().getProfile().getId(), 
                    owner);
            log.debug("setting serverProfile on session: " + p.getId());
            this.ksession.setServerProfile(p);    
        }
        
        log.debug("Saving new KickstartSession: " + this.ksession.getId());
        KickstartFactory.saveKickstartSession(this.ksession);
        log.debug("Saved new KickstartSession: " + this.ksession.getId());

        // Now create one time ActivationKey
        User user = UserFactory.findRandomOrgAdmin(owner);
        log.debug("Got random orgadmin: " + user.getLogin());
        String note = LocalizationService.getInstance().
            getMessage("kickstart.session.newtokennote", " ");
       
        Channel toolsChannel = KickstartScheduleCommand.getToolsChannel(ksdata, user, 
                null);
        log.debug("creating one-time-activation key: " + user.getLogin());
        ActivationKey key = KickstartScheduleCommand.createKickstartActivationKey(user, 
                ksdata, null, 
                this.ksession, toolsChannel, BooleanUtils.toBoolean(
                        ksdata.getKickstartDefaults().getCfgManagementFlag()), null, note);
        log.debug("added key: " + key.getKey());
        
        // Need to add child channels to the key so when kickstarting the 
        // system from bare metal we will have the proper child channel subscriptions.
        if (ksdata.getKickstartDefaults().getProfile() != null) {
            log.debug("Checking child channels for packages in profile.");
            addChildChannelsForProfile(ksdata.getKickstartDefaults().getProfile(), 
                    ksdata.getChannel(), key);
        }
    }
    
    private void addChildChannelsForProfile(Profile profile, Channel baseChannel, 
            ActivationKey key) {
        log.debug("** addChildChannelsForProfile");
        User orgAdmin = UserFactory.findRandomOrgAdmin(this.ksession.getOrg());
        List channels = ProfileManager.getChildChannelsNeededForProfile(orgAdmin, 
                baseChannel, profile);
        Iterator i = channels.iterator();
        while (i.hasNext()) {
            Channel child = (Channel) i.next();
            log.debug("** adding child channel for profile: " + child.getLabel());
            key.addChannel(child);
        }
        
        
        
    }

    
    /**
     * Saves the kickstart session returning any validation errors if any.
     * @return ValidatorError validation errors if any, can also be null.
     */
    public ValidatorError store() {
        KickstartFactory.saveKickstartSession(this.ksession);
        return null;
    }

    /**
     * Get the KickstartSession created
     * @return KickstartSession created.
     */
    public KickstartSession getKickstartSession() {
        return this.ksession;
    }

}
