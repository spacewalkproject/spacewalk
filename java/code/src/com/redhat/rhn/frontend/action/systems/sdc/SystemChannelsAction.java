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
package com.redhat.rhn.frontend.action.systems.sdc;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.DynamicComparator;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ChannelOverview;
import com.redhat.rhn.frontend.dto.ChildChannelDto;
import com.redhat.rhn.frontend.dto.EssentialChannelDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnLookupDispatchAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.system.UpdateBaseChannelCommand;
import com.redhat.rhn.manager.system.UpdateChildChannelsCommand;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * SystemChannelsAction - action to setup/process viewing a system's channel subscription 
 * info.
 * @version $Rev: 1 $
 */
public class SystemChannelsAction extends RhnLookupDispatchAction {

    /**
     * Logger for this class
     */
    private static Logger log = Logger.getLogger(SystemChannelsAction.class);

    public static final String AVAIL_CHILD_CHANNELS = "avail_child_channels";
    public static final String BASE_CHANNELS = "base_channels";
    public static final String CUSTOM_BASE_CHANNELS = "custom_base_channels";
    public static final String NEW_BASE_CHANNEL_ID = "new_base_channel_id";

    public static final String CHILD_CHANNELS = "child_channel";
    
    public static final String CURRENT_PRESERVED_CHILD_CHANNELS = 
        "current_preserved_child_channels";
    public static final String CURRENT_UNPRESERVED_CHILD_CHANNELS = 
        "current_unpreserved_child_channels";
    public static final String PRESERVED_CHILD_CHANNELS = "preserved_child_channels";
    
    public static final String CURRENT_BASE_CHANNEL = "current_base_channel";
    public static final String CURRENT_BASE_CHANNEL_ID = "current_base_channel_id";
    public static final String NEW_BASE_CHANNEL = "new_base_channel";
    

    /** {@inheritDoc} */
    public ActionForward unspecified(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {
        DynaActionForm form = (DynaActionForm) formIn;
        RequestContext rctx = new RequestContext(request);
        User user = rctx.getLoggedInUser();
        Server s  = SystemManager.lookupByIdAndUser(
                rctx.getRequiredParam(RequestContext.SID), user);
        
        // Setup request attributes
        request.setAttribute(RequestContext.SYSTEM, s);
        if (s.getBaseChannel() != null) {
            Channel baseChannel = s.getBaseChannel();
            List channels = baseChannel.getAccessibleChildrenFor(user);

            Collections.sort(channels, 
                    new DynamicComparator("name", RequestContext.SORT_ASC));
            
            ChildChannelDto[] childchannels = new ChildChannelDto[channels.size()];
            for (int i = 0; i < channels.size(); i++) {
                Channel child = (Channel) channels.get(i); 
                childchannels[i] = new ChildChannelDto(child.getId(), child.getName(), 
                        s.isSubscribed(child), 
                        ChannelManager.isChannelFreeForSubscription(s, child),
                        child.isSubscribable(user.getOrg(), s));
                childchannels[i].setAvailableSubscriptions(
                        ChannelManager.getAvailableEntitlements(user.getOrg(), child));
            }
            request.setAttribute(AVAIL_CHILD_CHANNELS, childchannels);
            form.set(NEW_BASE_CHANNEL_ID, s.getBaseChannel().getId());
            
            if (log.isDebugEnabled()) {
                log.debug("base_channel: " + form.get(NEW_BASE_CHANNEL_ID));
            }
            
        } 
        else {
            log.debug("System base_channel is null.");
        }
        
        
        List<EssentialChannelDto> orgChannels = ChannelManager.listBaseChannelsForSystem(
                user, s);
        
        List<EssentialChannelDto> rhnChannels = new LinkedList<EssentialChannelDto>();
        List<EssentialChannelDto> customChannels = new LinkedList<EssentialChannelDto>();
        
        for (EssentialChannelDto bc : orgChannels) {
            if (bc.isCustom()) {
                customChannels.add(bc);
            }
            else {
                rhnChannels.add(bc);
            }
        }
        
        SdcHelper.ssmCheck(request, s.getId(), user);
        
        request.setAttribute(BASE_CHANNELS, rhnChannels);
        request.setAttribute(CUSTOM_BASE_CHANNELS, customChannels);
        // Used to compare to the EssentialChannelDto id's:
        Long currentBaseChanId = new Long(-1);
        if (s.getBaseChannel() != null) {
            currentBaseChanId = s.getBaseChannel().getId();
        }
        request.setAttribute(CURRENT_BASE_CHANNEL_ID, currentBaseChanId);
        SdcHelper.ssmCheck(request, s.getId(), user);
        return getStrutsDelegate().forwardParam(mapping.findForward("default"), 
                RequestContext.SID, s.getId().toString());
    }

    private List<ChannelOverview> convertToChannelOverview(List<Channel> orgChannels) {
        List<ChannelOverview> retval = new LinkedList<ChannelOverview>();
        for (Channel c : orgChannels) {
            retval.add(new ChannelOverview(c.getName(), c.getId()));
        }
        return retval;
    }
    
    /**
     * Confirm the changing of the base channel for a system.
     *   
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward confirmUpdateBaseChannel(ActionMapping mapping,
            ActionForm formIn, HttpServletRequest request, HttpServletResponse response) {
        log.debug("SystemChannelsAction.confirmUpdateBaseChannel");
        RequestContext rctx = new RequestContext(request);
        User user = rctx.getLoggedInUser();
        Server s  = SystemManager.lookupByIdAndUser(
                rctx.getRequiredParam(RequestContext.SID), user);
        request.setAttribute(RequestContext.SYSTEM, s);
        log.debug("existing child channels:");
        List<Channel> currentChildChans = new LinkedList<Channel>();
        List<Channel> currentPreservedChildChans = new LinkedList<Channel>();
        List<Channel> currentUnpreservedChildChans = new LinkedList<Channel>();
        
        if (s.getChildChannels() != null) {
            for (Channel childChan : s.getChildChannels()) {
                log.debug("   " + childChan.getName());
                currentChildChans.add(childChan);
            }
        }
        
        Long newBaseChannelId = (Long) ((DynaActionForm) formIn).get(NEW_BASE_CHANNEL_ID);
        log.debug("newBaseChannelId = " + newBaseChannelId);
        
        Channel newChannel = null;
        List<Channel> preservedChildChannels = new LinkedList<Channel>();

        if (newBaseChannelId != null && newBaseChannelId.longValue() != -1) {
            newChannel = ChannelManager.lookupByIdAndUser(
                new Long(newBaseChannelId.longValue()), user);

            Map<Channel, Channel> preservations = ChannelManager.findCompatibleChildren(
                    s.getBaseChannel(), newChannel, user);
            log.debug("Preservations:");
            for (Entry<Channel, Channel> entry : preservations.entrySet()) {
                log.debug("   " + entry.getKey().getName() + " -> " + 
                        entry.getValue().getName());
                if (currentChildChans.contains(entry.getKey())) {
                    preservedChildChannels.add(entry.getValue());
                }
            }

            // Another pass so we can highlight the entries in the current chans list that
            // will be lost: (grr)
            for (Channel c : currentChildChans) {
                if (preservations.containsKey(c)) {
                    currentPreservedChildChans.add(c);
                }
                else {
                    currentUnpreservedChildChans.add(c);
                }
            }
        }
        else {
            // Nothing's going to be preserved if we're removing service:
            currentUnpreservedChildChans = currentChildChans;
        }

        // Pass along data for the actual update:
        request.setAttribute(CURRENT_PRESERVED_CHILD_CHANNELS, 
                convertToChannelOverview(currentPreservedChildChans));
        request.setAttribute(CURRENT_UNPRESERVED_CHILD_CHANNELS, 
                convertToChannelOverview(currentUnpreservedChildChans));
        request.setAttribute(PRESERVED_CHILD_CHANNELS,
                convertToChannelOverview(preservedChildChannels));
        request.setAttribute(NEW_BASE_CHANNEL, newChannel);
        request.setAttribute(CURRENT_BASE_CHANNEL, s.getBaseChannel());
        request.setAttribute(NEW_BASE_CHANNEL_ID, newBaseChannelId);
        SdcHelper.ssmCheck(request, s.getId(), user);
        return getStrutsDelegate().forwardParam(mapping.findForward("confirm"), 
                RequestContext.SID, s.getId().toString());
    }
    
    /**
     * Update the base channel for a system.  
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward updateBaseChannel(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        log.debug("SystemChannelsAction.updateBaseChannel");

        RequestContext rctx = new RequestContext(request);
        User user = rctx.getLoggedInUser();
        Server s  = SystemManager.lookupByIdAndUser(
                rctx.getRequiredParam(RequestContext.SID), user);
        
        Long newBaseChannelId = (Long) ((DynaActionForm) formIn).get(NEW_BASE_CHANNEL_ID);
        UpdateBaseChannelCommand cmd = new UpdateBaseChannelCommand(user, s, 
                newBaseChannelId);
        ValidatorError error = cmd.store();
        if (error != null) {
            log.debug("Got error trying to store child channels: " + error);
            getStrutsDelegate().saveMessages(request, 
                    RhnValidationHelper.validatorErrorToActionErrors(error));
        }
        else {
            getStrutsDelegate().saveMessage("sdc.channels.edit.base_channel_updated", 
                    request);

            String message = 
                LocalizationService.getInstance().getMessage("snapshots.basechannel");
            SystemManager.snapshotServer(s, message);
        }
        SdcHelper.ssmCheck(request, s.getId(), user);
        return getStrutsDelegate().forwardParam(mapping.findForward("update"), 
                RequestContext.SID, s.getId().toString());
    }

    /**
     * Update the base channel for a system.  
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward updateChildChannels(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        RequestContext rctx = new RequestContext(request);
        User user = rctx.getLoggedInUser();
        Server s  = SystemManager.lookupByIdAndUser(
                rctx.getRequiredParam(RequestContext.SID), user);
        
        String[] childChannelIds = request.getParameterValues(CHILD_CHANNELS);
        
        List<Long> channelIdsList = new LinkedList<Long>();
        if (childChannelIds != null) {
            for (int i = 0; i < childChannelIds.length; i++) {
                channelIdsList.add(Long.valueOf(childChannelIds[i]));
                log.debug("Adding child id: " + channelIdsList.get(i));
            }
        }
        UpdateChildChannelsCommand cmd = new UpdateChildChannelsCommand(user, s, 
                channelIdsList);
        ValidatorError error = cmd.store();
        if (error != null) {
            log.debug("Got error trying to store child channels: " + error);
            getStrutsDelegate().saveMessages(request, 
                    RhnValidationHelper.validatorErrorToActionErrors(error));
        }
        else {
            getStrutsDelegate().saveMessage("sdc.channels.edit.child_channels_updated", 
                    request);

            String message = 
                LocalizationService.getInstance().getMessage("snapshots.childchannel");
            SystemManager.snapshotServer(s, message);
        }
        
        return getStrutsDelegate().forwardParam(mapping.findForward("update"), 
                RequestContext.SID, s.getId().toString());
    }

    protected Map getKeyMethodMap() {
        Map<String, String> map = new HashMap<String, String>();
        map.put("sdc.channels.edit.confirm_update_base", "confirmUpdateBaseChannel");
        map.put("sdc.channels.edit.update_sub", "updateChildChannels");
        map.put("sdc.channels.confirmNewBase.cancel", "unspecified");
        map.put("sdc.channels.confirmNewBase.modifyBaseSoftwareChannel", 
                "updateBaseChannel");
        return map;
        
    }
}
