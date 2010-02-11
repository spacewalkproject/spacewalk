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
package com.redhat.rhn.frontend.action.kickstart.ssm;

import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
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
import com.redhat.rhn.manager.profile.ProfileManager;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;
import org.cobbler.Profile;

import java.util.Collections;
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
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response) throws Exception {
        RequestContext context = new RequestContext(request);
        User user = context.getLoggedInUser();
        DynaActionForm form = (DynaActionForm)formIn;
        if ("ip".equals(mapping.getParameter())) {
            request.setAttribute(SCHEDULE_TYPE_IP, Boolean.TRUE);
        }

        if (context.wasDispatched("kickstart.schedule.button2.jsp")) {
            List list = schedule(request, form, context);

            ActionMessages msg = new ActionMessages();
            String[] params = {list.size() + ""};
            msg.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("ssm.provision.scheduled",
                            params));
            getStrutsDelegate().saveMessages(context.getRequest(), msg);
            return mapping.findForward("success");
        }

        ListHelper helper = new ListHelper(this, request);
        helper.execute();
        ScheduleKickstartWizardAction.setupProxyInfo(context);
        form.set(ScheduleKickstartWizardAction.SYNCH_PACKAGES,
                    ProfileManager.listProfileOverviews(user.getOrg().getId()));
        // create and prepopulate the date picker.
        getStrutsDelegate().prepopulateDatePicker(
                request, form, "date", DatePicker.YEAR_RANGE_POSITIVE);
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }


    private List<Action> schedule(HttpServletRequest request, ActionForm form,
                                            RequestContext context) {
        SSMScheduleCommand com  = null;
        User user = context.getLoggedInUser();


        DynaActionForm dynaForm = (DynaActionForm) form;
        DatePicker picker = getStrutsDelegate().prepopulateDatePicker(context.getRequest(),
                dynaForm, "date", DatePicker.YEAR_RANGE_POSITIVE);

        List<SystemOverview> systems =
            KickstartManager.getInstance().kickstartableSystemsInSsm(user);

        if (isIP(request)) {
            com = SSMScheduleCommand.initIPKickstart(user,
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
                com = SSMScheduleCommand.initCobblerOnly(user, systems,
                                                picker.getDate(), prof.getName());
            }
            else {
                com = SSMScheduleCommand.init(user, systems, picker.getDate(), data);
            }
        }


        String proxyId = (String) dynaForm.getString(
                ScheduleKickstartWizardAction.PROXY_HOST);
        if (!StringUtils.isEmpty(proxyId)) {
            Server proxy = ServerFactory.lookupById(Long.parseLong(proxyId));
            com.setProxy(proxy);
        }
        com.setProfileType(dynaForm.getString(
                ScheduleKickstartWizardAction.TARGET_PROFILE_TYPE));
        com.setServerProfileId((Long) dynaForm.get("targetProfile"));
        com.setPackageProfileId((Long) dynaForm.get("targetProfile"));

        //do kernel params
        com.setKernelParamType(dynaForm.getString(
                ScheduleKickstartWizardAction.KERNEL_PARAMS_TYPE));
        com.setCustomKernelParams(dynaForm.getString(
                ScheduleKickstartWizardAction.KERNEL_PARAMS));

        //do post kernel params
        com.setPostKernelParamType(dynaForm.getString(
                ScheduleKickstartWizardAction.POST_KERNEL_PARAMS_TYPE));
        com.setCustomPostKernelParams(dynaForm.getString(
                ScheduleKickstartWizardAction.POST_KERNEL_PARAMS));
        com.setNetworkDevice(dynaForm.getString(ScheduleKickstartWizardAction.NETWORK_TYPE),
                            dynaForm.getString(
                                    ScheduleKickstartWizardAction.NETWORK_INTERFACE));
        List<ValidatorError> errors = com.store();
        return com.getScheduledActions();
    }


    /**
     * {@inheritDoc}
     */
    public List getResult(RequestContext ctx) {
        if (isIP(ctx.getRequest())) {
            return Collections.EMPTY_LIST;
        }

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
