/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.systems.virtualization;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.server.InstalledPackage;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.kickstart.KickstartHelper;
import com.redhat.rhn.frontend.action.kickstart.ScheduleKickstartWizardAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.frontend.struts.wizard.WizardStep;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.kickstart.KickstartScheduleCommand;
import com.redhat.rhn.manager.kickstart.ProvisionVirtualInstanceCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.DynaActionForm;
import org.cobbler.Profile;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;
/**
 * ProvisionVirtualizationWizardAction extends ScheduleKickstartWizardAction
 * @version $Rev$
 */
public class ProvisionVirtualizationWizardAction extends ScheduleKickstartWizardAction {

    public static final String MEMORY_ALLOCATION = "memoryAllocation";
    public static final String VIRTUAL_CPUS = "virtualCpus";
    public static final String VIRTUAL_BRIDGE = "virtBridge";
    public static final String VIRTUAL_FILE_PATH = "diskPath";
    public static final String LOCAL_STORAGE_GB = "localStorageGigabytes";
    public static final String MAC_ADDRESS = "macAddress";
    public static final String PROFILE = "cobbler_profile";

    public static final String GUEST_NAME = "guestName";
    public static final int MIN_NAME_SIZE = 4;
    public static final int MAX_CPU = 32;

    /**
     * {@inheritDoc}
     */
    @Override
    public ActionForward runFirst(ActionMapping mapping, DynaActionForm form,
            RequestContext ctx, HttpServletResponse response,
            WizardStep step) throws Exception {
        Long sid = (Long) form.get(RequestContext.SID);
        User user = ctx.getCurrentUser();
        Server system = SystemManager.lookupByIdAndUser(sid, user);

        if (StringUtils.isEmpty(form.getString(MEMORY_ALLOCATION))) {
            form.set(MEMORY_ALLOCATION, "");
        }

        if (StringUtils.isEmpty(form.getString(VIRTUAL_CPUS))) {
            form.set(VIRTUAL_CPUS, "");
        }

        if (StringUtils.isEmpty(form.getString(LOCAL_STORAGE_GB))) {
            form.set(LOCAL_STORAGE_GB, "");
        }

        if (StringUtils.isEmpty(form.getString(MAC_ADDRESS))) {
            form.set(MAC_ADDRESS, "");
        }

        // Check if the server already has rhnVirtHost package installed.
        InstalledPackage rhnVirtHost = PackageFactory.lookupByNameAndServer(
                ChannelManager.RHN_VIRT_HOST_PACKAGE_NAME, system);

        if (rhnVirtHost == null) {
            // system does not have the package installed, tell them to get it.
            addMessage(ctx.getRequest(), "system.virtualization.help");
        }

        return super.runFirst(mapping, form, ctx, response, step);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public ActionForward runSecond(ActionMapping mapping, DynaActionForm form,
            RequestContext ctx, HttpServletResponse response,
            WizardStep step) throws Exception {
        if (!validateFirstSelections(form, ctx)) {
            return runFirst(mapping, form, ctx, response, step);
        }
        ActionErrors errors = validateInput(form);
        if (!errors.isEmpty()) {
            addErrors(ctx.getRequest(), errors);
            //saveMessages(ctx.getRequest(), errors);
            return runFirst(mapping, form, ctx, response, step);
        }
        ActionForward forward = super.runSecond(mapping, form, ctx, response, step);

        Profile pf = getCobblerProfile(ctx);
        KickstartData ksdata = ctx.lookupAndBindKickstartData();
        if (StringUtils.isEmpty(form.getString(VIRTUAL_FILE_PATH))) {
            form.set(VIRTUAL_FILE_PATH, ProvisionVirtualInstanceCommand.
                    makeDefaultVirtPath(form.getString(GUEST_NAME),
                            ksdata.getKickstartDefaults().getVirtualizationType()));
        }
        if (StringUtils.isEmpty(form.getString(MEMORY_ALLOCATION))) {
            form.set(MEMORY_ALLOCATION, String.valueOf(pf.getVirtRam()));
        }

        if (StringUtils.isEmpty(form.getString(VIRTUAL_CPUS))) {
            form.set(VIRTUAL_CPUS, String.valueOf(pf.getVirtCpus()));
        }

        if (StringUtils.isEmpty(form.getString(LOCAL_STORAGE_GB))) {
            form.set(LOCAL_STORAGE_GB, String.valueOf(pf.getVirtFileSize()));
        }

        if (StringUtils.isEmpty(form.getString(VIRTUAL_BRIDGE))) {
            form.set(VIRTUAL_BRIDGE, String.valueOf(pf.getVirtBridge()));
        }

        if (StringUtils.isEmpty(form.getString(TARGET_PROFILE_TYPE))) {
            form.set(TARGET_PROFILE_TYPE,
                    KickstartScheduleCommand.TARGET_PROFILE_TYPE_NONE);
        }
        return forward;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public ActionForward runThird(ActionMapping mapping, DynaActionForm form,
            RequestContext ctx, HttpServletResponse response,
            WizardStep step) throws Exception {
        if (!validateFirstSelections(form, ctx)) {
            return runFirst(mapping, form, ctx, response, step);
        }

        ActionErrors errors = validateInput(form);
        if (!errors.isEmpty()) {
            addErrors(ctx.getRequest(), errors);
            //saveMessages(ctx.getRequest(), errors);
            return runFirst(mapping, form, ctx, response, step);
        }

        String scheduleAsap = form.getString("scheduleAsap");
        Date scheduleTime = null;
        if (scheduleAsap != null && scheduleAsap.equals("false")) {
            scheduleTime = (Date) form.get("scheduleDate");
        }
        else {
            scheduleTime = new Date();
        }
        KickstartHelper helper = new KickstartHelper(ctx.getRequest());

        ProvisionVirtualInstanceCommand cmd = getScheduleCommand(form,
                ctx, scheduleTime, helper.getKickstartHost());

        cmd.setKernelOptions(form.getString(KERNEL_PARAMS));

        cmd.setProfileType(form.getString("targetProfileType"));
        cmd.setServerProfileId((Long) form.get("targetProfile"));
        cmd.setProfileId((Long) form.get("targetProfile"));

        cmd.setGuestName(form.getString(GUEST_NAME));


        //If the virt options are overridden use them, otherwise use
        // The profile's values
        if (!StringUtils.isEmpty(form.getString(MEMORY_ALLOCATION))) {
            cmd.setMemoryAllocation(new Long(form.getString(MEMORY_ALLOCATION)));
        }
        else {
            cmd.setMemoryAllocation(new Long(this.getCobblerProfile(ctx).getVirtRam()));
        }

        if (!StringUtils.isEmpty(form.getString(VIRTUAL_CPUS))) {
            cmd.setVirtualCpus(new Long(form.getString(VIRTUAL_CPUS)));
        }
        else {
            cmd.setVirtualCpus(new Long(this.getCobblerProfile(ctx).getVirtCpus()));
        }

        if (!StringUtils.isEmpty(form.getString(LOCAL_STORAGE_GB))) {
            cmd.setLocalStorageSize(new Long(form.getString(LOCAL_STORAGE_GB)));
        }
        else {
            cmd.setLocalStorageSize(new Long(
                    this.getCobblerProfile(ctx).getVirtFileSize()));
        }

        if (!StringUtils.isEmpty(form.getString(VIRTUAL_BRIDGE))) {
            cmd.setVirtBridge(form.getString(VIRTUAL_BRIDGE));
        }
        else {
            cmd.setVirtBridge(this.getCobblerProfile(ctx).getVirtBridge());
        }
        if (!StringUtils.isEmpty(form.getString(MAC_ADDRESS))) {
            String macAddress = form.getString(MAC_ADDRESS);
            macAddress = macAddress.replace(":", "");
            macAddress = macAddress.toLowerCase();
            macAddress = macAddress.substring(0, 2) + ":" +
                    macAddress.substring(2, 4) + ":" +
                    macAddress.substring(4, 6) + ":" +
                    macAddress.substring(6, 8) + ":" +
                    macAddress.substring(8, 10) + ":" +
                    macAddress.substring(10);
            cmd.setMacAddress(macAddress);
        }
        cmd.setFilePath(form.getString(VIRTUAL_FILE_PATH));
        storeProxyInfo(form, ctx, cmd);
        // Store the new KickstartSession to the DB.
        ValidatorError ve = cmd.store();
        if (ve != null) {
            errors = RhnValidationHelper.validatorErrorToActionErrors(ve);
            if (!errors.isEmpty()) {
                getStrutsDelegate().saveMessages(ctx.getRequest(), errors);
                return runFirst(mapping, form, ctx, response, step);
            }
        }

        createSuccessMessage(ctx.getRequest(), "kickstart.schedule.success",
                LocalizationService.getInstance().formatDate(scheduleTime));
        Map params = new HashMap();
        params.put(RequestContext.SID, form.get(RequestContext.SID));

        return getStrutsDelegate().forwardParams(mapping.findForward("success"), params);
    }
    @Override
    protected KickstartScheduleCommand getKickstartScheduleCommand(Long sid,
            User currentUser) {
        return new ProvisionVirtualInstanceCommand(sid, currentUser);
    }


    private ActionErrors  validateInput(DynaActionForm form) {
        ActionErrors errors = new ActionErrors();
        String name = form.getString(GUEST_NAME);

        if (name.length() < MIN_NAME_SIZE) {
            errors.add(ActionErrors.GLOBAL_MESSAGE, new ActionMessage(
                    "frontend.actions.systems.virt.invalidguestnamelength",
                    (MIN_NAME_SIZE)));
        }

        if (!StringUtils.isEmpty(form.getString(MEMORY_ALLOCATION))) {
            try {
                Long memory = Long.parseLong(form.getString(MEMORY_ALLOCATION));
                if (memory <= 0) {
                    throw new NumberFormatException();
                }
            }
            catch (NumberFormatException e) {
                errors.add(ActionErrors.GLOBAL_MESSAGE, new ActionMessage(
                        "frontend.actions.systems.virt.invalidmemvalue"));
            }
        }

        if (!StringUtils.isEmpty(form.getString(VIRTUAL_CPUS))) {
            try {
                Long cpus = Long.parseLong(form.getString(VIRTUAL_CPUS));
                if (cpus <= 0 || cpus > MAX_CPU) {
                    throw new NumberFormatException();
                }
            }
            catch (NumberFormatException e) {
                errors.add(ActionErrors.GLOBAL_MESSAGE, new ActionMessage(
                        "frontend.actions.systems.virt.invalidcpuvalue",
                        (MAX_CPU + 1)));
            }
        }

        if (!StringUtils.isEmpty(form.getString(LOCAL_STORAGE_GB))) {
            try {
                Long storage = Long.parseLong(form.getString(LOCAL_STORAGE_GB));
                if (storage <= 0) {
                    throw new NumberFormatException();
                }
            }
            catch (NumberFormatException e) {
                errors.add(ActionErrors.GLOBAL_MESSAGE, new ActionMessage(
                        "frontend.actions.systems.virt.invalidstoragevalue"));
                form.set(LOCAL_STORAGE_GB, "");
            }
        }

        if (!StringUtils.isEmpty(form.getString(MAC_ADDRESS))) {
            try {
                String macAddress = form.getString(MAC_ADDRESS);
                macAddress = macAddress.replace(":", "");
                if (macAddress.length() != 12 ||
                        !macAddress.matches("^[0-9a-fA-F]+$")) {
                    throw new NumberFormatException();
                }
            }
            catch (NumberFormatException e) {
                errors.add(ActionErrors.GLOBAL_MESSAGE, new ActionMessage(
                        "frontend.actions.systems.virt.invalidmacaddressvalue"));
                form.set(MAC_ADDRESS, "");
            }
        }

        return errors;
    }

    /**
     * Get the cobbler profile
     * @param context the request context
     * @return the cobbler profile
     */
    private Profile getCobblerProfile(RequestContext context) {
        if (context.getRequest().getAttribute(PROFILE) == null) {
            String cobblerId = (String) context.getRequest().getAttribute(
                    RequestContext.COBBLER_ID);
            User user = context.getLoggedInUser();
            Profile cobblerProfile = org.cobbler.Profile.lookupById(
                    CobblerXMLRPCHelper.getConnection(user), cobblerId);
            context.getRequest().setAttribute(PROFILE, cobblerProfile);
        }
        return (Profile) context.getRequest().getAttribute(PROFILE);
    }

    @Override
    protected ProvisionVirtualInstanceCommand getScheduleCommand(DynaActionForm form,
            RequestContext ctx, Date scheduleTime, String host) {
        Profile cobblerProfile = getCobblerProfile(ctx);
        User user = ctx.getLoggedInUser();
        ProvisionVirtualInstanceCommand cmd;
        KickstartData data = KickstartFactory.
                lookupKickstartDataByCobblerIdAndOrg(user.getOrg(), cobblerProfile.getId());

        if (data != null) {
            cmd =
                    new ProvisionVirtualInstanceCommand(
                            (Long) form.get(RequestContext.SID),
                            data,
                            ctx.getCurrentUser(),
                            scheduleTime,
                            host);
        }
        else {
            cmd = ProvisionVirtualInstanceCommand.createCobblerScheduleCommand((Long)
                    form.get(RequestContext.SID), cobblerProfile.getName(),
                    user, scheduleTime,  host);
        }
        return cmd;
    }
}
