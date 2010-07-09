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
package com.redhat.rhn.frontend.action.configuration.ssm;

import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.BaseRankChannels;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * RankChannels, for ssm configuration management
 * @version $Rev$
 */
public class RankChannels extends BaseRankChannels {
    public static final String PRIORITY = "priority";

    /**
     * {@inheritDoc}
     */
    protected Map getKeyMethodMap() {
        Map keys = new HashMap();
        keys.put("ssm.config.rank.jsp.apply", "apply");
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
        setup(context, (DynaActionForm)form, set);
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /**
     * Updates the set and then moves the user to the confirm page.
     * @param mapping struts ActionMapping
     * @param formIn struts ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return ActionForward to the confirm page.
     */
    public ActionForward apply(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        // if its not javascript enabled, can't do much report error
        if (!context.isJavaScriptEnabled()) {
            return handleNoScript(mapping, formIn, request, response);
        }
        String position = ((DynaActionForm)formIn).getString(PRIORITY);
        User user = context.getLoggedInUser();

        DynaActionForm form = (DynaActionForm) formIn;
        RhnSet set = getRhnSet(user);

        //update the set and go to confirm.
        updateSet(form, set);
        return getStrutsDelegate().forwardParam(mapping.findForward("confirm"),
                "position", position);
    }

    protected void setup(RequestContext context,
                             DynaActionForm form,
                             RhnSet set) {
        setupWidget(context, form, set);
        if (!isSubmitted(form)) {
            form.set(PRIORITY, "lowest");
        }
    }

    /**
     *
     * {@inheritDoc}
     */
    protected void populateWidgetLabels(LinkedHashSet labelValues,
                                            RequestContext context) {
        // TODO Auto-generated method stub

    }

    private void updateSet(DynaActionForm form, RhnSet set) {
        List channelIds = getChannelIds(form);
        if (!channelIds.isEmpty()) {
            set.clear();
            for (int i = 0; i < channelIds.size(); i++) {
                set.addElement((Long)channelIds.get(i), new Long(i));
            }
            RhnSetManager.store(set);
        }
    }

    protected void processParams(RequestContext context, Map map) {
        // TODO Auto-generated method stub

    }

}
