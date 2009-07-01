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
package com.redhat.rhn.frontend.action.kickstart.ssm;

import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.kickstart.ScheduleKickstartWizardAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.kickstart.KickstartLister;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * ScheduleKickstartAction
 * @version $Rev$
 */
public class SsmKSScheduleAction extends RhnAction implements Listable {
    private static final String SCHEDULE_TYPE_IP = "isIP";

    private boolean isIP(HttpServletRequest request) {
        return Boolean.TRUE.equals(request.getAttribute(SCHEDULE_TYPE_IP));
    }
    
    /**
     * ${@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form, 
            HttpServletRequest request, HttpServletResponse response) throws Exception {
        RequestContext context = new RequestContext(request);
        User user = context.getLoggedInUser();
        
        if ("ip".equals(mapping.getParameter())) {
            request.setAttribute(SCHEDULE_TYPE_IP, Boolean.TRUE);
        }
        if (!isIP(request)) {
            ListHelper helper = new ListHelper(this, request);
            helper.execute();
        }
        ScheduleKickstartWizardAction.setupProxyInfo(context);
        // create and prepopulate the date picker.
        getStrutsDelegate().prepopulateDatePicker(
                request, (DynaActionForm)form, "date", DatePicker.YEAR_RANGE_POSITIVE);
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }
    /**
     * {@inheritDoc}
     */
    public List getResult(RequestContext ctx) {
        User user = ctx.getLoggedInUser();
        List profiles = KickstartLister.getInstance().listProfilesForSsm(user);
        
        if (profiles.isEmpty()) {
            addMessage(ctx.getRequest(), "kickstart.schedule.noprofiles");
        }
        else {
            ctx.getRequest().setAttribute(ScheduleKickstartWizardAction.HAS_PROFILES,
                    Boolean.TRUE);
        }
        return profiles;
    }
    
}
