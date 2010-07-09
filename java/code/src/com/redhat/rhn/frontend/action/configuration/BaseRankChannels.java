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
package com.redhat.rhn.frontend.action.configuration;

import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnLookupDispatchAction;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.util.LabelValueBean;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * BaseRankChannels, Abstract class for config channel rankings in ssm and sdc.
 * @version $Rev$
 */
public abstract class BaseRankChannels extends RhnLookupDispatchAction {

    protected static final String POSSIBLE_CHANNELS = "possibleChannels";
    protected static final String SELECTED_CHANNEL = "selectedChannel";
    protected static final String NO_SCRIPT = "noScript";
    protected static final String RANKED_VALUES = "rankedValues";

    /**
     * Sets up the rangling widget.
     * @param context the request context of the current request
     * @param form the dynaform  related to the current request.
     * @param set the rhnset holding the channel ids.
     */
    protected void setupWidget(RequestContext context,
                                     DynaActionForm form,
                                     RhnSet set) {
        User user = context.getLoggedInUser();
        LinkedHashSet labelValues = new LinkedHashSet();
        populateWidgetLabels(labelValues, context);
        for (Iterator itr = set.getElements().iterator(); itr.hasNext();) {
            Long ccid = ((RhnSetElement) itr.next()).getElement();
            ConfigChannel channel = ConfigurationManager.getInstance()
                                        .lookupConfigChannel(user, ccid);
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
     * Extension point for each of the subclasses to add content
     * LabelValues before more content is added to it using rhn sets
     *  to the RankWidget check box..
     * The subclasses should update the labelValues
     * @param labelValues a LinkedHashSet/List in some sense that
     *                     holds a bunch of lv(Channel labels, Channel ids).
     *                     This is a Linked Hash Set becasue we needed to
     *                     throw away duplicate insertions while maintaining
     *                     the correct order of insertion.
     * @param context the request context of the current request
     */
    protected abstract void populateWidgetLabels(LinkedHashSet labelValues,
                                        RequestContext context);


    /**
     * Returns the the channel Ids info retrieved after one
     * has clicked Update Channel Rankings or Apply Subscriptions.
     * @param form the submitted form..
     * @return List containing the channel ids in the order of
     *                   their new  rankings.
     */
    protected List getChannelIds(DynaActionForm form) {
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
     * returns the Rhn Set used to store the sets..
     * @param user The Loggin User
     * @return rhn set used to store channel ids.
     */
    protected RhnSet getRhnSet(User user) {
        return  RhnSetDecl.CONFIG_CHANNELS_RANKING.get(user);
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
    public ActionForward handleNoScript(ActionMapping mapping,
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
        User user = context.getLoggedInUser();
        RhnSet set = getRhnSet(user);
        setup(context, (DynaActionForm)formIn, set);
        return getStrutsDelegate().forwardParams
                                    (mapping.findForward(RhnHelper.DEFAULT_FORWARD),
                                                        map);
    }

    /**
     * Extension points for each of the BaseRankChannel sub classses
     * to add params to forwarding page..
     * @param context the request context of the current request.
     * @param params the params to be updated
     */
    protected abstract void processParams(RequestContext context, Map params);

    /**
     * Extension point for doing additional setup stuff
     * before the jsp is loaded...
     * @param context the request context of the current request.
     * @param form the action form for setting up form contents on the new page
     * @param set the set storing the rank contents
     */
    protected abstract void setup(RequestContext context,
                                            DynaActionForm form,
                                            RhnSet set);

}
