/**
 * Copyright (c) 2004-2006 Red Hat, Inc.
 * All Rights Reserved.
 *
 * This software is the confidential and proprietary information of
 * Red Hat, Inc. ("Confidential Information").  You shall not
 * disclose such Confidential Information and shall use it only in
 * accordance with the terms of the license agreement you entered into
 * with Red Hat.
 */
package com.redhat.rhn.frontend.action.channel.manage;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelArch;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.channel.CreateChannelCommand;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * EditChannelAction
 * @version $Rev: 1 $
 */
public class EditChannelAction extends RhnAction {


    /** {@inheritDoc} */
    public ActionForward execute (ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {
    
        DynaActionForm form = (DynaActionForm)formIn;
        Map params = makeParamMap(request);
        RequestContext ctx = new RequestContext(request);
        User loggedInUser = ctx.getLoggedInUser();

        if (!isSubmitted(form)) {
            setupForm(request, form);
            return getStrutsDelegate().forwardParams(
                    mapping.findForward("default"),
                    request.getParameterMap());
        }

        // handle submission
        CreateChannelCommand ccc = new CreateChannelCommand();
        ccc.setArchLabel((String)form.get(""));
        ccc.setLabel((String)form.get(""));
        ccc.setName((String)form.get("name"));
        ccc.setSummary((String)form.get("summary"));
        //ccc.setParentLabel((String)form.get("summary"));
        ccc.setUser(loggedInUser);

        params.put("cid", "1");
        return getStrutsDelegate().forwardParams(mapping.findForward("default"), params);
    }
    
    private void setupForm(HttpServletRequest request, DynaActionForm form) {
        RequestContext ctx = new RequestContext(request);
        User loggedInUser = ctx.getLoggedInUser();
        // populate parent base channels
        List baseChannels = new ArrayList();
        List<Channel> bases = ChannelManager.findAllBaseChannelsForOrg(loggedInUser.getOrg());
        LocalizationService ls = LocalizationService.getInstance();
        addOption(baseChannels, ls.getMessage("generic.jsp.none"), "");
        for (Channel c : bases) {
            addOption(baseChannels, c.getName(), c.getId().toString());
        }
        request.setAttribute("parentChannels", baseChannels);
        
        // base channel arches
        List channelArches = new ArrayList();
        List<ChannelArch> arches = ChannelManager.getChannelArchitectures();
        for (ChannelArch arch : arches) {
            addOption(channelArches, arch.getName(), arch.getLabel());
        }
        request.setAttribute("channelArches", channelArches);
    }
    
    /**
     * Utility function to create options for the dropdown.
     * @param options list containing all options.
     * @param key resource bundle key used as the display value.
     * @param value value to be submitted with form.
     */
    private void addOption(List options, String key, String value) {
        Map selection = new HashMap();
        selection.put("label", key);
        selection.put("value", value);
        options.add(selection);
    }

}
