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
package com.redhat.rhn.frontend.action.configuration.sdc;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.BaseRankChannels;
import com.redhat.rhn.frontend.action.systems.sdc.SdcHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * RankChannelsAction
 * @version $Rev$
 */
public class RankChannelsAction extends BaseRankChannels {

    /**
     * {@inheritDoc}
     */
    protected Map getKeyMethodMap() {
        Map keys = new HashMap();
        keys.put("sdc.config.rank.jsp.update", "update");
        keys.put("ssm.config.rank.jsp.up", "handleNoScript");
        keys.put("ssm.config.rank.jsp.down", "handleNoScript");
        return keys;
    }


    /**
     * {@inheritDoc}
     */
    protected ActionForward unspecified(ActionMapping mapping,
            ActionForm form, HttpServletRequest request,
            HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        User user = context.getLoggedInUser();
        RhnSet set = getRhnSet(user);
        SdcHelper.ssmCheck(request, context.lookupAndBindServer().getId(), user);
        setup(context, (DynaActionForm)form, set);
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }


    /**
     * Updates the set and then applies changes to the server
     * @param mapping struts ActionMapping
     * @param formIn struts ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return An action forward to the success page
     */
    public ActionForward update(ActionMapping mapping,
            ActionForm formIn, HttpServletRequest request,
            HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        // if its not javascript enabled, can't do much report error
        if (!context.isJavaScriptEnabled()) {
            return handleNoScript(mapping, formIn, request, response);
        }

        User user = context.getLoggedInUser();
        DynaActionForm form = (DynaActionForm) formIn;
        Server server = context.lookupAndBindServer();

        List channelIds = getChannelIds(form);
        if (!channelIds.isEmpty()) {
            for (Iterator itr = channelIds.iterator(); itr.hasNext();) {
                ConfigChannel channel = ConfigurationManager.getInstance()
                                 .lookupConfigChannel(user, (Long)itr.next());
                server.subscribe(channel);
            }
        }

        RhnSet set = getRhnSet(user);
        set.clear();
        RhnSetManager.store(set);

        // bz 444517 - Create a snapshot to capture this change
        String message =
            LocalizationService.getInstance().getMessage("snapshots.configchannel");
        SystemManager.snapshotServer(server, message);

        String[] params = {server.getName()};
        getStrutsDelegate().saveMessage("sdc.config.rank.jsp.success",
                                                    params, request);
        return getStrutsDelegate().forwardParam(mapping.findForward("success"),
                RequestContext.SID, server.getId().toString());
    }

    protected void setup(RequestContext context, DynaActionForm form,
                            RhnSet set) {
        //This happens if the rank channels page is used without the
        //subscribe page.
        if (!isWizardMode(context)) {
            set.clear();
        }

        //add things to the form so the widget can read them
        setupWidget(context, form, set);
    }

    /**
     *
     * {@inheritDoc}
     */
    protected void populateWidgetLabels(LinkedHashSet labelValues,
                                            RequestContext context) {
        Server server = context.lookupAndBindServer();
        for (Iterator itr = server.getConfigChannels().iterator();
                                                    itr.hasNext();) {
            ConfigChannel channel = (ConfigChannel) itr.next();
            labelValues.add(lv(channel.getName(),
                                        channel.getId().toString()));
        }
    }

    protected void processParams(RequestContext context, Map map) {
        Server server = context.lookupAndBindServer();
        map.put(RequestContext.SID, server.getId().toString());

        if (isWizardMode(context)) {
            map.put(SubscriptionsSubmitAction.WIZARD_MODE, Boolean.TRUE.toString());
        }
    }

    /**
     * @param request
     * @return
     */
    private boolean isWizardMode(RequestContext context) {
        return  Boolean.TRUE.toString().equals(context.getParam
                         (SubscriptionsSubmitAction.WIZARD_MODE, false));
    }

}
