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
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.DateRangePicker;
import com.redhat.rhn.frontend.action.common.DateRangePicker.DatePickerResults;
import com.redhat.rhn.frontend.action.kickstart.ScheduleKickstartWizardAction;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.kickstart.KickstartLister;
import com.redhat.rhn.manager.kickstart.KickstartManager;
import com.redhat.rhn.manager.kickstart.SSMScheduleCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;
import org.cobbler.Profile;

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
        
        
        if (context.wasDispatched("kickstart.schedule.button2.jsp")) {
            schedule(request, form, context);
        }
        
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
    
    
    private void schedule(HttpServletRequest request, ActionForm form, RequestContext context) {        
        SSMScheduleCommand com  = null;
        User user = context.getLoggedInUser();
        
        
        DynaActionForm dynaForm = (DynaActionForm) form;
        DatePicker picker = getStrutsDelegate().prepopulateDatePicker(context.getRequest(),
                dynaForm, "date", DatePicker.YEAR_RANGE_POSITIVE);
        
        List<SystemOverview> systems = 
            KickstartManager.getInstance().kickstartableSystemsInSsm(user);
        
        if (isIP(request)) {
            com = SSMScheduleCommand.initCommandForIPKickstart(user, 
                    systems, picker.getDate());
        }
        else {
            ListHelper helper = new ListHelper(this, request);
            String cobblerId = ListTagHelper.getRadioSelection(helper.getListName(),
                    request);
            KickstartData data = KickstartFactory.lookupKickstartDataByCobblerIdAndOrg(
                                user.getOrg(), cobblerId);
            if (data == null) {
                Profile prof = Profile.lookupById(CobblerXMLRPCHelper.getConnection(user), 
                        cobblerId);
                com = new SSMScheduleCommand(user, systems, picker.getDate(), prof.getName());
            }
            else {
                com = new SSMScheduleCommand(user, systems, picker.getDate(), data);
            }
        }
        
        List<ValidatorError> errors = com.store();
        
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
