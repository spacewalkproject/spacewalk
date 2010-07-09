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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.rhnpackage.profile.Profile;
import com.redhat.rhn.domain.server.NetworkInterface;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.systems.sdc.SdcHelper;
import com.redhat.rhn.frontend.dto.OrgProxyServer;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.frontend.struts.wizard.RhnWizardAction;
import com.redhat.rhn.frontend.struts.wizard.WizardStep;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.kickstart.KickstartScheduleCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerSystemCreateCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.util.LabelValueBean;
import org.cobbler.CobblerConnection;
import org.cobbler.CobblerObject;
import org.cobbler.Distro;
import org.cobbler.SystemRecord;

import java.lang.reflect.Method;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * blah blah
 *
 * @version $Rev $
 */
public class ScheduleKickstartWizardAction extends RhnWizardAction {

    /**
     * Logger for this class
     */
    private static Logger log = Logger
            .getLogger(ScheduleKickstartWizardAction.class);

    public static final String SYNCH_PACKAGES = "syncPackages";
    public static final String SYNCH_SYSTEMS = "syncSystems";
    public static final String HAS_PROFILES = "hasProfiles";
    public static final String HAS_PROXIES = "hasProxies";
    public static final String SYNC_PACKAGE_DISABED = "syncPackageDisabled";
    public static final String SYNC_SYSTEM_DISABLED = "syncSystemDisabled";
    public static final String PROXIES = "proxies";
    public static final String KERNEL_PARAMS = "kernelParams";
    public static final String KERNEL_PARAMS_TYPE = "kernelParamsType";
    public static final String KERNEL_PARAMS_DISTRO = "distro";
    public static final String KERNEL_PARAMS_PROFILE = "profile";
    public static final String KERNEL_PARAMS_CUSTOM = "custom";
    private static final String COBBLER_ONLY_PROFILE = "cobblerOnlyProfile";
    public static final String POST_KERNEL_PARAMS = "postKernelParams";
    public static final String POST_KERNEL_PARAMS_TYPE = "postKernelParamsType";
    public static final String PROXY_HOST = "proxyHost";
    public static final String IS_VIRTUAL_GUEST = "isVirtualGuest";
    public static final String HOST_SID = "hostSid";
    public static final String VIRT_HOST_IS_REGISTERED = "virtHostIsRegistered";
    public static final String TARGET_PROFILE_TYPE = "targetProfileType";
    public static final String NETWORK_TYPE = "networkType";
    public static final String NETWORK_INTERFACE = "networkInterface";
    public static final String NETWORK_INTERFACES = "networkInterfaces";
    /**
     * {@inheritDoc}
     */
    protected void generateWizardSteps(Map wizardSteps) {
        List methods = findMethods("run");
        for (Iterator iter = methods.iterator(); iter.hasNext();) {
            Method m = (Method) iter.next();
            String stepName = m.getName().substring(3).toLowerCase();
            WizardStep wizStep = new WizardStep();
            wizStep.setWizardMethod(m);
            log.debug("Step name: " + stepName);
            if (stepName.equals("first")) {
                wizStep.setNext("second");
                wizardSteps.put(RhnWizardAction.STEP_START, wizStep);
            }
            else if (stepName.equals("second")) {
                wizStep.setPrevious("first");
                wizStep.setNext("third");
            }
            else if (stepName.equals("third")) {
                wizStep.setPrevious("second");
            }
            else if (stepName.equals("fourth")) {
                wizStep.setPrevious("first");
            }
            wizardSteps.put(stepName, wizStep);
        }
    }

    private class Profiles implements Listable {

        /**
         * {@inheritDoc}
         */
        public List getResult(RequestContext ctx) {
            Long sid = ctx.getParamAsLong(RequestContext.SID);
            User user = ctx.getCurrentUser();

            KickstartScheduleCommand cmd = getKickstartScheduleCommand(sid,
                    user);
            DataResult profiles = cmd.getKickstartProfiles();
            if (profiles.size() == 0) {
                addMessage(ctx.getRequest(), "kickstart.schedule.noprofiles");
                ctx.getRequest().setAttribute(HAS_PROFILES,
                        Boolean.FALSE.toString());
            }
            else {
                ctx.getRequest().setAttribute(HAS_PROFILES,
                        Boolean.TRUE.toString());
            }
            return profiles;
        }
    }


    /**
     * Sets up the proxy information for the wizard.
     * its public in this class because we reuse this in SSM
     * and only this class knows how to format the name nicely.
     * @param ctx the request context needed for user info and
     *                   things to bind to the request
     */
    public static void setupProxyInfo(RequestContext ctx) {
        List<OrgProxyServer> proxies = SystemManager.
                        listProxies(ctx.getLoggedInUser().getOrg());
        if (proxies != null && proxies.size() > 0) {
            List<LabelValueBean> formatted = new LinkedList<LabelValueBean>();

            formatted.add(lvl10n("kickstart.schedule.default.proxy.jsp", ""));
            for (OrgProxyServer serv : proxies) {
                formatted.add(lv(serv.getName() + " (" + serv.getCheckin() + ")",
                        serv.getId().toString()));
            }
            ctx.getRequest().setAttribute(HAS_PROXIES, Boolean.TRUE.toString());
            ctx.getRequest().setAttribute(PROXIES, formatted);
        }
        else {
            ctx.getRequest().setAttribute(HAS_PROXIES, Boolean.FALSE.toString());
        }
    }

    private void setupNetworkInfo(DynaActionForm form,
                    RequestContext context, KickstartScheduleCommand cmd) {
        Server server = cmd.getServer();
        List<NetworkInterface> nics = new LinkedList<NetworkInterface>
                                                (server.getNetworkInterfaces());

        if (nics.isEmpty()) {
            return;
        }

        for (Iterator<NetworkInterface> itr = nics.iterator(); itr.hasNext();) {
            NetworkInterface nic = itr.next();
            if (nic.isDisabled() || "127.0.0.1".equals(nic.getIpaddr())) {
                itr.remove();
            }
        }
        context.getRequest().setAttribute(NETWORK_INTERFACES, nics);

        if (StringUtils.isBlank(form.getString(NETWORK_INTERFACE))) {
            String defaultInterface = ConfigDefaults.get().
                            getDefaultKickstartNetworkInterface();
            for (NetworkInterface nic : nics) {
                if (nic.getName().equals(defaultInterface)) {
                    form.set(NETWORK_INTERFACE, ConfigDefaults.get().
                            getDefaultKickstartNetworkInterface());
                }
            }
            if (StringUtils.isBlank(form.getString(NETWORK_INTERFACE))) {
                form.set(NETWORK_INTERFACE, server.
                            findPrimaryNetworkInterface().getName());
            }
        }
    }

    /**
     * The first step in the wizard
     * @param mapping ActionMapping for struts
     * @param form DynaActionForm representing the form
     * @param ctx RequestContext request context
     * @param response HttpServletResponse response object
     * @param step WizardStep what step are we on?
     *
     * @return ActionForward struts action forward
     * @throws Exception if something goes amiss
     */
    public ActionForward runFirst(ActionMapping mapping, DynaActionForm form,
            RequestContext ctx, HttpServletResponse response, WizardStep step)
        throws Exception {
        log.debug("runFirst");
        Long sid = (Long) form.get(RequestContext.SID);
        User user = ctx.getCurrentUser();

        KickstartScheduleCommand cmd = getKickstartScheduleCommand(sid, user);

        Server system = SystemManager.lookupByIdAndUser(sid, user);
        if (system.isVirtualGuest()) {
            ctx.getRequest().setAttribute(IS_VIRTUAL_GUEST,
                    Boolean.TRUE.toString());

            ctx.getRequest().setAttribute(VIRT_HOST_IS_REGISTERED,
                    Boolean.FALSE.toString());
            if (system.getVirtualInstance().getHostSystem() != null) {
                Long hostSid = system.getVirtualInstance().getHostSystem()
                        .getId();
                ctx.getRequest().setAttribute(VIRT_HOST_IS_REGISTERED,
                        Boolean.TRUE.toString());
                ctx.getRequest().setAttribute(HOST_SID, hostSid);
            }
        }
        else {
            ctx.getRequest().setAttribute(IS_VIRTUAL_GUEST,
                    Boolean.FALSE.toString());
        }

        addRequestAttributes(ctx, cmd, form);
        checkForKickstart(form, cmd, ctx);
        setupProxyInfo(ctx);
        if (StringUtils.isBlank(form.getString(PROXY_HOST))) {
            form.set(PROXY_HOST, "");
        }
        // create and prepopulate the date picker.
        getStrutsDelegate().prepopulateDatePicker(
                ctx.getRequest(), form, "date", DatePicker.YEAR_RANGE_POSITIVE);

        SdcHelper.ssmCheck(ctx.getRequest(), system.getId(), user);
        Map params = new HashMap<String, String>();
        params.put(RequestContext.SID, sid);
        ListHelper helper = new ListHelper(new Profiles(), ctx.getRequest(),
                params);
        helper.execute();
        if (!StringUtils.isBlank(form.getString(RequestContext.COBBLER_ID))) {
            ListTagHelper.selectRadioValue(ListHelper.LIST,
                    form.getString(RequestContext.COBBLER_ID), ctx.getRequest());
        }
        else if (system.getCobblerId() != null) {
            //if nothing is selected by the user yet, use the cobbler
            //  system record to pre-select something.
            SystemRecord rec = SystemRecord.lookupById(
                    CobblerXMLRPCHelper.getConnection(
                            ConfigDefaults.get().getCobblerAutomatedUser()),
                    system.getCobblerId());
            if (rec != null) {
                ListTagHelper.selectRadioValue(ListHelper.LIST,
                        rec.getProfile().getId(), ctx.getRequest());
            }
        }

        ActionForward retval = mapping.findForward("first");
        return retval;
    }

    /**
     * The second step in the wizard
     * @param mapping ActionMapping for struts
     * @param form DynaActionForm representing the form
     * @param ctx RequestContext request context
     * @param response HttpServletResponse response object
     * @param step WizardStep what step are we on?
     *
     * @return ActionForward struts action forward
     * @throws Exception if something goes amiss
     */
    public ActionForward runSecond(ActionMapping mapping, DynaActionForm form,
            RequestContext ctx, HttpServletResponse response, WizardStep step)
        throws Exception {
        log.debug("runSecond");
        Long sid = (Long) form.get(RequestContext.SID);
        User user = ctx.getCurrentUser();

        if (!validateFirstSelections(form, ctx)) {
            return runFirst(mapping, form, ctx, response, step);
        }
        KickstartScheduleCommand cmd = getScheduleCommand(form, ctx, null, null);

        checkForKickstart(form, cmd, ctx);
        addRequestAttributes(ctx, cmd, form);
        if (!cmd.isCobblerOnly()) {
            List packageProfiles = cmd.getProfiles();
            form.set(SYNCH_PACKAGES, packageProfiles);
            List systemProfiles = cmd.getCompatibleSystems();
            form.set(SYNCH_SYSTEMS, systemProfiles);

            // Disable the package/system sync radio buttons if no profiles are
            // available:
            String syncPackageDisabled = "false";
            if (packageProfiles.size() == 0) {
                syncPackageDisabled = "true";
            }
            String syncSystemDisabled = "false";
            if (systemProfiles.size() == 0) {
                syncSystemDisabled = "true";
            }
            ctx.getRequest()
                    .setAttribute(SYNC_PACKAGE_DISABED, syncPackageDisabled);
            ctx.getRequest().setAttribute(SYNC_SYSTEM_DISABLED, syncSystemDisabled);

            if (StringUtils.isEmpty(form.getString(TARGET_PROFILE_TYPE))) {
                form.set(TARGET_PROFILE_TYPE,
                            KickstartScheduleCommand.TARGET_PROFILE_TYPE_NONE);
            }
        }
        else {
            ctx.getRequest().setAttribute(COBBLER_ONLY_PROFILE, Boolean.TRUE);
        }

        if (StringUtils.isEmpty(form.getString(KERNEL_PARAMS_TYPE))) {
            form.set(KERNEL_PARAMS_TYPE, KERNEL_PARAMS_DISTRO);
        }

        if (StringUtils.isEmpty(form.getString(POST_KERNEL_PARAMS_TYPE))) {
            form.set(POST_KERNEL_PARAMS_TYPE, KERNEL_PARAMS_DISTRO);
        }

        SdcHelper.ssmCheck(ctx.getRequest(), sid, user);
        return mapping.findForward("second");
    }

    protected void addRequestAttributes(RequestContext ctx,
            KickstartScheduleCommand cmd, DynaActionForm form) {
        ctx.getRequest().setAttribute(RequestContext.SYSTEM, cmd.getServer());
        ctx.getRequest()
                .setAttribute(RequestContext.KICKSTART, cmd.getKsdata());
        if (cmd.getKsdata() != null) {
            ctx.getRequest().setAttribute("profile", cmd.getKsdata());
            ctx.getRequest().setAttribute("distro", cmd.getKsdata().getTree());
            CobblerConnection con = CobblerXMLRPCHelper.
                                    getConnection(ctx.getLoggedInUser());

            Distro distro = Distro.lookupById(con,
                                cmd.getKsdata().getTree().getCobblerId());

            ctx.getRequest().setAttribute("distro_kernel_params",
                                            distro.getKernelOptionsString());
            ctx.getRequest().setAttribute("distro_post_kernel_params",
                                                distro.getKernelPostOptionsString());

            org.cobbler.Profile profile = org.cobbler.Profile.
                                lookupById(con, cmd.getKsdata().getCobblerId());
            ctx.getRequest().setAttribute("profile_kernel_params",
                                    profile.getKernelOptionsString());
            ctx.getRequest().setAttribute("profile_post_kernel_params",
                                        profile.getKernelPostOptionsString());
            if (cmd.getServer().getCobblerId() != null) {
                SystemRecord rec = SystemRecord.
                        lookupById(con, cmd.getServer().getCobblerId());
                if (rec != null && profile.getName().equals(rec.getProfile().getName())) {
                    if (StringUtils.isBlank(form.getString(KERNEL_PARAMS_TYPE))) {
                        form.set(KERNEL_PARAMS_TYPE, KERNEL_PARAMS_CUSTOM);
                        form.set(KERNEL_PARAMS, rec.getKernelOptionsString());
                    }
                    if (StringUtils.isBlank(form.getString(POST_KERNEL_PARAMS_TYPE))) {
                        form.set(POST_KERNEL_PARAMS_TYPE, KERNEL_PARAMS_CUSTOM);
                        form.set(POST_KERNEL_PARAMS, rec.getKernelPostOptionsString());
                    }
                }
            }
        }
        setupNetworkInfo(form, ctx, cmd);
    }



    /**
     * The third step in the wizard
     * @param mapping ActionMapping for struts
     * @param form DynaActionForm representing the form
     * @param ctx RequestContext request context
     * @param response HttpServletResponse response object
     * @param step WizardStep what step are we on?
     *
     * @return ActionForward struts action forward
     * @throws Exception if something goes amiss
     */
    public ActionForward runThird(ActionMapping mapping, DynaActionForm form,
            RequestContext ctx, HttpServletResponse response, WizardStep step)
        throws Exception {
        log.debug("runThird");
        if (!validateFirstSelections(form, ctx)) {
            return runFirst(mapping, form, ctx, response, step);
        }
        String scheduleAsap = form.getString("scheduleAsap");
        Date scheduleTime = null;
        if (scheduleAsap != null && scheduleAsap.equals("false")) {
            scheduleTime = getStrutsDelegate().readDatePicker(form, "date",
                    DatePicker.YEAR_RANGE_POSITIVE);
        }
        else {
            scheduleTime = new Date();
        }
        KickstartHelper helper = new KickstartHelper(ctx.getRequest());
        KickstartScheduleCommand cmd = getScheduleCommand(form, ctx,
                scheduleTime, helper.getKickstartHost());

        cmd.setNetworkDevice(form.getString(NETWORK_TYPE),
                                            form.getString(NETWORK_INTERFACE));
        cmd.setKernelOptions(parseKernelOptions(form, ctx.getRequest(),
                            form.getString(RequestContext.COBBLER_ID), false));
        cmd.setPostKernelOptions(parseKernelOptions(form, ctx.getRequest(),
                            form.getString(RequestContext.COBBLER_ID), true));

        if (!cmd.isCobblerOnly()) {
            // now setup system/package profiles for kickstart to sync
            Profile pkgProfile = cmd.getKsdata().getKickstartDefaults()
                    .getProfile();
            Long packageProfileId = pkgProfile != null ? pkgProfile.getId() : null;

            // if user did not override package profile, then grab from ks
            // profile if avail
            if (packageProfileId != null) {
                cmd.setProfileId(packageProfileId);
                cmd.setProfileType(KickstartScheduleCommand.TARGET_PROFILE_TYPE_PACKAGE);
            }
            else {
                /*
                 * NOTE: these values are essentially ignored if user did not go
                 * through advanced config and there is no package profile to
                 * sync in the kickstart profile
                 */
                cmd.setProfileType(form.getString(TARGET_PROFILE_TYPE));
                cmd.setServerProfileId((Long) form.get("targetProfile"));
                cmd.setProfileId((Long) form.get("targetProfile"));
            }
        }

        storeProxyInfo(form, ctx, cmd);

        // Store the new KickstartSession to the DB.
        ValidatorError ve = cmd.store();
        if (ve != null) {
            ActionErrors errors = RhnValidationHelper
                    .validatorErrorToActionErrors(ve);
            if (!errors.isEmpty()) {
                getStrutsDelegate().saveMessages(ctx.getRequest(), errors);
                return runFirst(mapping, form, ctx, response, step);
            }
        }
        Map params = new HashMap();
        params.put(RequestContext.SID, form.get(RequestContext.SID));

        if (cmd.isCobblerOnly()) {
            createSuccessMessage(ctx.getRequest(),
                    "kickstart.cobbler.schedule.success", LocalizationService
                            .getInstance().formatDate(scheduleTime));
            return getStrutsDelegate().forwardParams(
                    mapping.findForward("cobbler-success"), params);
        }
        createSuccessMessage(ctx.getRequest(), "kickstart.schedule.success",
                LocalizationService.getInstance().formatDate(scheduleTime));
        return getStrutsDelegate().forwardParams(
                mapping.findForward("success"), params);
    }

    /**
     * Setup the system for provisioning with cobbler.
     *
     * @param mapping ActionMapping for struts
     * @param form DynaActionForm representing the form
     * @param ctx RequestContext request context
     * @param response HttpServletResponse response object
     * @param step WizardStep what step are we on?
     *
     * @return ActionForward struts action forward
     * @throws Exception if something goes amiss
     */
    public ActionForward runFourth(ActionMapping mapping, DynaActionForm form,
            RequestContext ctx, HttpServletResponse response, WizardStep step)
        throws Exception {

        log.debug("runFourth");
        if (!validateFirstSelections(form, ctx)) {
            return runFirst(mapping, form, ctx, response, step);
        }
        Long sid = (Long) form.get(RequestContext.SID);
        String cobblerId = form.getString(RequestContext.COBBLER_ID);

        log.debug("runFourth.cobblerId: " + cobblerId);

        User user = ctx.getCurrentUser();
        Server server = SystemManager.lookupByIdAndUser(sid, user);

        Map params = new HashMap();
        params.put(RequestContext.SID, sid);

        log.debug("Creating cobbler system record");
        org.cobbler.Profile profile = org.cobbler.Profile.lookupById(
                CobblerXMLRPCHelper.getConnection(user), cobblerId);

        KickstartData data = KickstartFactory.lookupKickstartDataByCobblerIdAndOrg(
                    user.getOrg(), profile.getUid());

        CobblerSystemCreateCommand cmd = new CobblerSystemCreateCommand(server,
                profile.getName(), data);
        cmd.store();
        log.debug("cobbler system record created.");
        String[] args = new String[2];
        args[0] = server.getName();
        args[1] = profile.getName();
        createMessage(ctx.getRequest(), "kickstart.schedule.cobblercreate",
                args);
        return getStrutsDelegate().forwardParams(
                mapping.findForward("cobbler-success"), params);
    }

    /**
     * Returns the kickstart schedule command
     * @param form the dyna aciton form
     * @param ctx the request context
     * @param scheduleTime the schedule time
     * @param host the host url.
     * @return the Ks schedule command
     */
    protected KickstartScheduleCommand getScheduleCommand(DynaActionForm form,
            RequestContext ctx, Date scheduleTime, String host) {
        String cobblerId = form.getString(RequestContext.COBBLER_ID);
        User user = ctx.getLoggedInUser();
        KickstartScheduleCommand cmd;
        KickstartData data = KickstartFactory
                .lookupKickstartDataByCobblerIdAndOrg(user.getOrg(), cobblerId);
        if (data != null) {
            cmd = new KickstartScheduleCommand((Long) form
                    .get(RequestContext.SID), data, ctx.getCurrentUser(),
                    scheduleTime, host);
        }
        else {
            org.cobbler.Profile profile = org.cobbler.Profile.lookupById(
                    CobblerXMLRPCHelper.getConnection(user), cobblerId);
            cmd = KickstartScheduleCommand.createCobblerScheduleCommand(
                    (Long) form.get(RequestContext.SID), profile.getName(),
                    user, scheduleTime, host);
        }
        return cmd;
    }

    /**
     * @param form the form containing the proxy info
     * @param ctx the request context associated to this request
     * @param cmd the kicktstart command to which the proxy info will be
     * copied..
     */
    protected void storeProxyInfo(DynaActionForm form, RequestContext ctx,
            KickstartScheduleCommand cmd) {
        // if we need to go through a proxy, do it here.
        String phost = form.getString(PROXY_HOST);

        if (!StringUtils.isEmpty(phost)) {
            cmd.setProxy(SystemManager.lookupByIdAndOrg(new Long(phost), ctx
                    .getCurrentUser().getOrg()));
        }
    }

    protected boolean validateFirstSelections(DynaActionForm form,
            RequestContext ctx) {
        String cobblerId = ListTagHelper.getRadioSelection(ListHelper.LIST,
                                                            ctx.getRequest());
        if (StringUtils.isBlank(cobblerId)) {
            cobblerId = ctx.getParam(RequestContext.COBBLER_ID, true);
        }

        boolean retval = false;
        form.set(RequestContext.COBBLER_ID, cobblerId);
        ctx.getRequest().setAttribute(RequestContext.COBBLER_ID, cobblerId);
        if (form.get("scheduleAsap") != null) {
            retval = true;
        }
        else if (form.get(RequestContext.COBBLER_ID) != null) {
            return true;
        }
        return retval;
    }

    private void checkForKickstart(DynaActionForm form,
            KickstartScheduleCommand cmd, RequestContext ctx) {
        if (ActionFactory.doesServerHaveKickstartScheduled((Long) form
                .get(RequestContext.SID))) {
            String[] params = { cmd.getServer().getName() };
            getStrutsDelegate().saveMessage(
                    "kickstart.schedule.already.scheduled.jsp", params,
                    ctx.getRequest());
        }
    }

    protected KickstartScheduleCommand getKickstartScheduleCommand(Long sid,
            User currentUser) {
        return new KickstartScheduleCommand(sid, currentUser);
    }

    /**
     * Parses the kernel options or Post kernel options
     * from the given form. Called after the advanced options page
     * is typically set..
     *  This is a handy method used in both SSM and SDC KS scheduling.
     * @param form the kickstartScheduleWizardForm that holds the form fields.
     * @param request the servlet request
     * @param profileCobblerId the cobbler profile id
     * @param isPost true if caller is interested in getting the
     *              post kernel options and not the pre.
     * @return the kernel options selected by the user.
     */
    public static String parseKernelOptions(DynaActionForm form,
                                                HttpServletRequest request,
                                                String profileCobblerId,
                                                boolean isPost) {
        RequestContext context = new RequestContext(request);
        String typeKey = !isPost ? KERNEL_PARAMS_TYPE : POST_KERNEL_PARAMS_TYPE;
        String customKey = !isPost ? KERNEL_PARAMS : POST_KERNEL_PARAMS;
        String type = form.getString(typeKey);

        return parseKernelOptions(form.getString(customKey), type, profileCobblerId,
                                            isPost, context.getCurrentUser());
    }


    /**
     * Parses the kernel options or Post kernel options
     * from the given set of params
     *  This is a handy method used in both SSM and SDC KS scheduling.
     * @param customOptions the kickstartScheduleWizardForm that holds the form fields.
     * @param paramsType  either KERNEL_PARAMS_CUSTOM _DISTRO or _PROFILE
     * @param cobblerId the cobbler profile id
     * @param isPost true if caller is interested in getting the
     *              post kernel options and not the pre.
     * @param user the user doing the request
     * @return the kernel options selected by the user.
     */
    public static String parseKernelOptions(String customOptions,
                                                String paramsType,
                                                String cobblerId,
                                                boolean isPost, User user) {

        CobblerConnection con  = CobblerXMLRPCHelper.
                            getConnection(user);
        if (KERNEL_PARAMS_CUSTOM.equals(paramsType)) {
            return customOptions;
        }
        org.cobbler.Profile profile = org.cobbler.Profile.lookupById(con,
                cobblerId);
        CobblerObject ret = profile;

        if (KERNEL_PARAMS_DISTRO.equals(paramsType)) {
            ret = profile.getDistro();
        }
        if (!isPost) {
            return ret.getKernelOptionsString();
        }
        else {
            return ret.getKernelPostOptionsString();
        }

    }
}
