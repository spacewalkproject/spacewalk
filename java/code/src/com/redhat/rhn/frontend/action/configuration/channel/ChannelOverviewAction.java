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
package com.redhat.rhn.frontend.action.configuration.channel;

import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.configuration.ChannelSummary;
import com.redhat.rhn.manager.configuration.ConfigChannelCreationHelper;
import com.redhat.rhn.manager.configuration.ConfigurationManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * DetailsAction backs the page for managing config-channel details
 * @version $Rev: 1 $
 */
public class ChannelOverviewAction extends RhnAction {
    
    /** Current ChannelSummary, in request/responce */
    public static final String CHANNEL_SUMMARY = "summary";
    /** Are we editing? */
    public static final String CHANNEL_EDITING = "editing";
    

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
    
        DynaActionForm daForm = (DynaActionForm)form;
        Map params = makeParamMap(request);
        RequestContext  context = new RequestContext(request);
        User user = context.getLoggedInUser();
        ConfigurationManager manager = ConfigurationManager.getInstance();
        ConfigChannelCreationHelper helper = new ConfigChannelCreationHelper();
        ConfigChannel cc = findChannel(daForm, request, helper);
        
        // If submitting, validate
        if (isSubmitted(daForm)) {
            try {
                helper.validate(daForm);
                if (cc != null) {
                    helper.update(cc, daForm);
                    helper.save(cc);
                    setupForm(request, cc, daForm, params);                
                    return getStrutsDelegate().forwardParams(
                            mapping.findForward("success"), params);
                }
            }
            catch (ValidatorException ve) {
                setupForm(request, cc, null, params);
                getStrutsDelegate().saveMessages(request, ve.getResult());
                daForm.getMap().put(CHANNEL_EDITING, Boolean.TRUE);
                RhnValidationHelper.setFailedValidation(request);
                return getStrutsDelegate().forwardParams(
                        mapping.findForward("error"), params);                
            }
            
        }        
        
        if (cc != null) {
            // Have a Channel and updating
            if (!isSubmitted(daForm)) {
                if (cc.isSandboxChannel()) {
                    String sid = String.valueOf(manager.getServerIdFor(cc, user));
                    params.put("sid", sid);
                    return getStrutsDelegate().forwardParams(
                            mapping.findForward("sandbox"), params);
                }
                else if (cc.isLocalChannel()) {
                    String sid = String.valueOf(manager.getServerIdFor(cc, user));
                    params.put("sid", sid);
                    return getStrutsDelegate().forwardParams(
                            mapping.findForward("local"), params);
                }
                else {
                    setupForm(request, cc, daForm, params);                
                    return getStrutsDelegate().forwardParams(
                            mapping.findForward("default"), params);
                }
            }
        }
        
        // No channel - proabably creating a new one
        return getStrutsDelegate().forwardParams(mapping.findForward("default"), params);
    }

    
    /**
     * Given the incoming request, set up the ChanelOverview form with channel info
     * @param request the incoming request
     * @param cc the channel to be affected
     * @param form the form to be filled in
     */
    protected void setupForm(HttpServletRequest request, ConfigChannel cc, 
            DynaActionForm form, Map params) {
        
        RequestContext ctx = new RequestContext(request);

        if (form != null) {
            form.set("cofName", cc.getName());
            form.set("cofLabel", cc.getLabel());
            form.set("cofDescription", cc.getDescription());
        }
        
        if (cc.getId() != null) {
            User u = ctx.getLoggedInUser();
            request.setAttribute(CHANNEL_SUMMARY, getSummary(u, cc));
        }


        ConfigActionHelper.processParamMap(cc, params);
        ConfigActionHelper.setupRequestAttributes(ctx, cc);
   }

    /**
     * Grab the summary info for the specified channel
     * @param u The user-context
     * @param cc The channel of interest
     * @return the summary information
     */
    protected ChannelSummary getSummary(User u, ConfigChannel cc) {
        return ConfigurationManager.getInstance().getChannelSummary(u, cc);
    }
    
    /**
     * Find the channel specified in the request (if any).
     * If there is no channel specified but the form was submitted, then this must
     * be the request to create a new channel.
     * If there is no channel specified and we were NOT submitted, then this is the
     * initial "fill in the blanks" request and can return "null" for channel.
     * @param form incoming channelOverviewForm
     * @param request incoming request
     * @return existing channel, or a new (empty) channel on submit, or null if 
     * we're asking the user for new-channel info for the first time
     */
    protected ConfigChannel findChannel(DynaActionForm form, HttpServletRequest request, 
                                                      ConfigChannelCreationHelper helper) {
        RequestContext ctx = new RequestContext(request);
        User u = ctx.getLoggedInUser();
        
        ConfigChannel cc = ConfigActionHelper.getChannel(request);
        
        // Creating a new channel?
        if (cc == null && isSubmitted(form)) {
            cc = helper.create(u);
        }
        return cc;
    }
}
