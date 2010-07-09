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

package com.redhat.rhn.frontend.action.token.configuration;

import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigChannelListProcessor;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.token.BaseListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.SessionSetHelper;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.util.LabelValueBean;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * @author paji
 * RankChannelsAction
 * @version $Rev$
 */
public class RankChannelsAction  extends RhnAction {
    protected static final String POSSIBLE_CHANNELS = "possibleChannels";
    protected static final String SELECTED_CHANNEL = "selectedChannel";
    protected static final String NO_SCRIPT = "noScript";
    protected static final String RANKED_VALUES = "rankedValues";


    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        BaseListAction.setup(request);
        RequestContext context = new RequestContext(request);
        if (!context.isSubmitted()) {
            return init(mapping, formIn, request, response);
        }
        if (context.wasDispatched("sdc.config.rank.jsp.update")) {
            return update(mapping, formIn, request, response);
        }
        return handleNoScript(mapping, formIn, request, response);

    }

    /**
     * Sets up the rangling widget.
     * @param context the request context of the current request
     * @param form the dynaform  related to the current request.
     * @param set the set holding the channel ids.
     */
    private void setupWidget(RequestContext context,
                                     DynaActionForm form,
                                     Set<String> set) {
        LinkedHashSet labelValues = new LinkedHashSet();
        populateWidgetLabels(labelValues, context);
        for (String id : set) {
            Long ccid = Long.valueOf(id);
            ConfigChannel channel = ConfigurationFactory.lookupConfigChannelById(ccid);
            labelValues.add(lv(channel.getName(), channel.getId().toString()));
        }

        //set the form variables for the widget to read.
        form.set(POSSIBLE_CHANNELS, labelValues);
        if (!labelValues.isEmpty()) {
            if (form.get(SELECTED_CHANNEL) == null) {
                String selected = ((LabelValueBean)labelValues.iterator().next())
                                                        .getValue();
                form.set(SELECTED_CHANNEL, selected);
            }
        }
    }

    /**
     * Returns the the channel Ids info retrieved after one
     * has clicked Update Channel Rankings or Apply Subscriptions.
     * @param form the submitted form..
     * @return List containing the channel ids in the order of
     *                   their new  rankings.
     */
    private List<Long> getChannelIds(DynaActionForm form) {
        List channels = new ArrayList();
        String rankedValues = (String)form.get(RANKED_VALUES);
        if (StringUtils.isNotBlank(rankedValues)) {
            String [] values = rankedValues.split(",");
            for (int i = 0; i < values.length; i++) {
                channels.add(new Long(values[i]));
            }
        }
        return channels;
    }


    /**
     *
     * Raises an error message saying javascript is required
     * to process this page
     * @param mapping struts ActionMapping
     * @param formIn struts ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return An action forward to the default page with the error message
     */
    private ActionForward handleNoScript(ActionMapping mapping,
                            ActionForm formIn,
                            HttpServletRequest request,
                            HttpServletResponse response) {
        RequestContext context = new RequestContext(request);


        if (!context.isJavaScriptEnabled()) {
            getStrutsDelegate().
            saveMessage("common.config.rank.jsp.error.nojavascript", request);
        }

        Map map = new HashMap();
        processParams(context, map);
        Set<String> set = getSet(context);
        setup(context, (DynaActionForm)formIn, set);
        return getStrutsDelegate().forwardParams
                                    (mapping.findForward(RhnHelper.DEFAULT_FORWARD),
                                                        map);
    }

    /**
     * {@inheritDoc}
     */
    protected ActionForward init(ActionMapping mapping,
            ActionForm form, HttpServletRequest request,
            HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        Set<String> set = getSet(context);
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
        ActivationKey key = context.lookupAndBindActivationKey();

        for (Long id : getChannelIds(form)) {
            ConfigChannel channel = ConfigurationFactory.lookupConfigChannelById(id);
            ConfigChannelListProcessor proc = new ConfigChannelListProcessor();
            proc.add(key.getConfigChannelsFor(user), channel);
        }

        Set<String> set = getSet(context);
        set.clear();
        String[] params = {key.getNote()};
        getStrutsDelegate().saveMessage("sdc.config.rank.jsp.success",
                                                    params, request);
        SessionSetHelper.obliterate(request,
                        request.getParameter(SubscribeChannelsAction.DECL));
        return getStrutsDelegate().forwardParam(mapping.findForward("success"),
                RequestContext.TOKEN_ID, key.getId().toString());
    }

    private Set<String> getSet(RequestContext context) {
        return  SessionSetHelper.lookupAndBind(context.getRequest(),
                    context.getRequest().getParameter(SubscribeChannelsAction.DECL));

    }


    private void setup(RequestContext context, DynaActionForm form,
                            Set<String> set) {
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
    private void populateWidgetLabels(LinkedHashSet labelValues,
                                            RequestContext context) {

        ActivationKey key = context.lookupAndBindActivationKey();
        for (ConfigChannel channel :
                key.getConfigChannelsFor(context.getLoggedInUser())) {
            labelValues.add(lv(channel.getName(),
                                        channel.getId().toString()));
        }
    }

    private void processParams(RequestContext context, Map map) {
        ActivationKey key = context.lookupAndBindActivationKey();
        map.put(RequestContext.TOKEN_ID, key.getId().toString());

        if (isWizardMode(context)) {
            map.put(SubscribeChannelsAction.WIZARD_MODE, Boolean.TRUE.toString());
        }
    }

    /**
     * @param request
     * @return
     */
    private boolean isWizardMode(RequestContext context) {
        return  Boolean.TRUE.toString().equals(context.getParam
                         (SubscribeChannelsAction.WIZARD_MODE, false));
    }
}
