/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.util.MD5Crypt;
import com.redhat.rhn.domain.kickstart.KickstartCommand;
import com.redhat.rhn.domain.kickstart.KickstartCommandName;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartDefaults;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.acl.AclManager;
import com.redhat.rhn.manager.kickstart.KickstartEditCommand;
import com.redhat.rhn.manager.kickstart.SystemDetailsCommand;

import org.apache.commons.lang.BooleanUtils;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Handles display and update of Kickstart -> System Details
 * 
 * @version $Rev $
 */
public class SystemDetailsEditAction extends RhnAction {
    
    public static final String SELINUX_MODE_PARAM = "selinux";
    public static final String SELINUX_MODE_ENFORCING = "enforcing";
    private static final String SELINUX_MODE_PERMISSIVE = "permissive";
    private static final String SELINUX_MODE_DISABLED = "disabled";
    
    public static final String DHCP_NETWORK_TYPE = "dhcp";
    public static final String NETWORK_TYPE_FORM_VAR = "networkType";
    public static final String DHCP_IF_FORM_VAR = "dhcpNetworkIf";
    private static final String STATIC_IF_FORM_VAR = "staticNetworkIf";
    private static final String DHCP_IF_DISABLED_PARAM = "dhcpIfDisabled";
    private static final String STATIC_IF_DISABLED_PARAM = "staticIfDisabled";
    private static final String PWD_CHANGED_PARAM = "pwdChanged";
    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, 
            ActionForm form, 
            HttpServletRequest request, 
            HttpServletResponse response) throws Exception {

        if (!AclManager.hasAcl("user_role(org_admin) or user_role(config_admin)",
            request, null)) {
            //Throw an exception with a nice error message so the user
            //knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex =
                new PermissionException(
                    "Only Org Admins or Configuration Admins can modify kickstarts");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.summary.acl.header"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.acl.reason5"));
            throw pex;
        }

        DynaActionForm dynaForm = (DynaActionForm) form;
        if (isSubmitted(dynaForm)) {
            return updateSystemDetails(mapping, dynaForm, request, response);
        }
        else {
            return viewSystemDetails(mapping, dynaForm, request, response);
        }
    }


    /**
     * Sets up the form bean for viewing
     * @param mapping Struts action mapping
     * @param dynaForm related form instance
     * @param request related request
     * @param response related response
     * @return jsp to render
     * @throws Exception when error occurs - this should be handled by the app framework
     */
    public ActionForward viewSystemDetails(ActionMapping mapping, 
            DynaActionForm dynaForm, 
            HttpServletRequest request, 
            HttpServletResponse response) throws Exception {
        
        RequestContext ctx = new RequestContext(request);        
        KickstartData ksdata = lookupKickstart(ctx, dynaForm);
        prepareForm(dynaForm, ksdata, ctx);
        setNetworkIfState(dynaForm, request);
        request.setAttribute(RequestContext.KICKSTART, ksdata);
        return mapping.findForward("display");
    }
    
    /**
     * Processes form submission and displays updated data
     * @param mapping Struts action mapping
     * @param dynaForm related form instance
     * @param request related request
     * @param response related response
     * @return jsp to render
     * @throws Exception when error occurs - this should be handled by the app framework
     */
    public ActionForward updateSystemDetails(ActionMapping mapping, 
            DynaActionForm dynaForm, 
            HttpServletRequest request, 
            HttpServletResponse response) throws Exception {
        RequestContext ctx = new RequestContext(request);
        KickstartData ksdata = lookupKickstart(ctx, dynaForm);
        request.setAttribute("ksdata", ksdata);
        if (validateForm(request, dynaForm)) {
            transferEdits(dynaForm, ksdata, ctx);
            ActionMessages msg = new ActionMessages();
            msg.add(ActionMessages.GLOBAL_MESSAGE, 
                    new ActionMessage("kickstart.systemdetails.update.confirm"));
            getStrutsDelegate().saveMessages(request, msg);
            Map params = new HashMap();
            params.put("ksid", ctx.getRequiredParam(RequestContext.KICKSTART_ID));
            return getStrutsDelegate().forwardParams(mapping.findForward("display"),
                    params);
        }
        else {
            setNetworkIfState(dynaForm, request);
            ActionMessages msg = new ActionMessages();
            getStrutsDelegate().saveMessages(request, msg);            
            request.setAttribute(RequestContext.KICKSTART, ksdata);
            return mapping.findForward("display");
        }
    }
    
    
    protected KickstartData lookupKickstart(RequestContext ctx, DynaActionForm form) {
        KickstartEditCommand cmd = 
            new KickstartEditCommand(ctx.getRequiredParam(RequestContext.KICKSTART_ID),
                    ctx.getCurrentUser());
        return cmd.getKickstartData();
    }
    
    private void setNetworkIfState(DynaActionForm dynaForm, HttpServletRequest request) {
        String networkType = dynaForm.getString(NETWORK_TYPE_FORM_VAR);
        if (networkType != null) {
            if (networkType.equals(DHCP_NETWORK_TYPE)) {
                request.setAttribute(DHCP_IF_DISABLED_PARAM, Boolean.FALSE.toString());
                request.setAttribute(STATIC_IF_DISABLED_PARAM, Boolean.TRUE.toString());
            }
            else {
                request.setAttribute(DHCP_IF_DISABLED_PARAM, Boolean.TRUE.toString());
                request.setAttribute(STATIC_IF_DISABLED_PARAM, Boolean.FALSE.toString());
            }
        }
    }
    
    
    private boolean validateForm(HttpServletRequest request, DynaActionForm form) {
        ActionErrors e = new ActionErrors();
        boolean retval = true;
        int passwdMin = 1;
        String pwdChangedFlag = form.getString(PWD_CHANGED_PARAM); 
        if (pwdChangedFlag != null && pwdChangedFlag.length() > 0) {
            String rootPw = form.getString("rootPassword");
            String rootPwConfirm = form.getString("rootPasswordConfirm");
            if (rootPw == null || rootPw.length() == 0 || rootPwConfirm == null || 
                    rootPwConfirm.length()  == 0) {
                ActionMessage msg = new ActionMessage(
                        "kickstart.systemdetails.passwords.jsp.minerror");
                e.add(ActionMessages.GLOBAL_MESSAGE, msg);
                retval = false;            
            }
            else if (!rootPw.equals(rootPwConfirm)) {
                ActionMessage msg = new ActionMessage(
                        "kickstart.systemdetails.root.password.jsp.error");
                e.add(ActionMessages.GLOBAL_MESSAGE, msg);
                retval = false;
            }
            else if (rootPw.length() < passwdMin || rootPwConfirm.length() < passwdMin) {
                ActionMessage msg = new ActionMessage(
                        "kickstart.systemdetails.passwords.jsp.minerror");
                e.add(ActionMessages.GLOBAL_MESSAGE, msg);
                retval = false;            
            }
        }
        else {
            form.set("rootPassword", null);
            form.set("rootPasswordConfirm", null);
        }
        String networkType = form.getString(NETWORK_TYPE_FORM_VAR);
        String interfaceProperty = null;
        if (networkType.equals(DHCP_NETWORK_TYPE)) {
            interfaceProperty = DHCP_IF_FORM_VAR;
        }
        else {
            interfaceProperty = STATIC_IF_FORM_VAR;
        }
        String networkIf = form.getString(interfaceProperty); 
        if (networkIf == null || networkIf.trim().length() == 0) {
            ActionMessage msg = new ActionMessage(
            "kickstart.systemdetails.missing.netdevice.jsp.error");
            e.add(ActionMessages.GLOBAL_MESSAGE, msg);
            retval = false;
        }
        if (e.size() > 0) {
            addErrors(request, e);
        }
        return retval;
    }

    private void transferEdits(DynaActionForm form, KickstartData ksdata, 
            RequestContext ctx) {
        transferNetworkEdits(form, ksdata);
        transferRootPasswordEdits(form, ksdata, ctx);
        if (!ksdata.isLegacyKickstart()) {
            transferSELinuxEdits(form, ksdata, ctx);
        }
        transferFlagEdits(form, ksdata);
        HibernateFactory.getSession().saveOrUpdate(ksdata);
    }
    
    private void prepareForm(DynaActionForm dynaForm, 
            KickstartData ksdata, RequestContext ctx) {
        prepareNetworkConfig(dynaForm, ksdata);
        prepareSELinuxConfig(dynaForm, ksdata);
        prepareFlags(dynaForm, ksdata);
        dynaForm.set("submitted", Boolean.TRUE);
    }
    
    private void prepareSELinuxConfig(DynaActionForm dynaForm, KickstartData ksdata) {
        KickstartCommand cmd = ksdata.getCommand(SELINUX_MODE_PARAM);
        String mode = null;
        if (cmd != null) {
            String args = cmd.getArguments();
            if (args != null) {
                if (args.endsWith(SELINUX_MODE_PERMISSIVE)) {
                    mode = SELINUX_MODE_PERMISSIVE;
                }
                else if (args.endsWith(SELINUX_MODE_ENFORCING)) {
                    mode = SELINUX_MODE_ENFORCING;
                }
                else if (args.endsWith(SELINUX_MODE_DISABLED)) {
                    mode = SELINUX_MODE_DISABLED;
                }
            }
        }
        // Default SELinux mode to enforcing
        if (mode == null) {
            mode = SELINUX_MODE_ENFORCING;
        }
        dynaForm.set("selinuxMode", mode);
    }
    
    private void prepareNetworkConfig(DynaActionForm dynaForm, KickstartData ksdata) {
        String staticDevice = ksdata.getStaticDevice();
        if (staticDevice != null) {
            int breakpos = staticDevice.indexOf(":");
            String networkType = staticDevice.substring(0, breakpos);
            networkType = networkType.trim().toLowerCase();
            dynaForm.set(NETWORK_TYPE_FORM_VAR, networkType);
            if ((breakpos + 1) < staticDevice.length()) {
                String device = staticDevice.substring(breakpos + 1);
                if (networkType.equals(DHCP_NETWORK_TYPE)) {
                    dynaForm.set(DHCP_IF_FORM_VAR, device);
                }
                else {
                    dynaForm.set(STATIC_IF_FORM_VAR, device);
                }
            }
        }        
    }
    
    private void prepareFlags(DynaActionForm dynaForm, KickstartData ksdata) {
        KickstartDefaults defaults = ksdata.getKsdefault();
        if (defaults == null) {
            return;
        }
        Boolean flag = defaults.getCfgManagementFlag();
        if (flag.booleanValue()) {
            dynaForm.set("configManagement", "on");    
        }
        else {
            dynaForm.set("configManagement",  null);
        }
        flag = defaults.getRemoteCommandFlag();
        if (flag.booleanValue()) {
            dynaForm.set("remoteCommands", "on");
        }
        else {
            dynaForm.set("remoteCommands", null);
        }
    }
    
    private void transferSELinuxEdits(DynaActionForm form, KickstartData ksdata,
            RequestContext ctx) {
        SystemDetailsCommand systemDetailsCommand = 
            new SystemDetailsCommand(ksdata.getId(), ctx.getCurrentUser());
        KickstartCommandName commandName = 
            systemDetailsCommand.findCommandName(SELINUX_MODE_PARAM);
        String selinuxMode = form.getString("selinuxMode");
        KickstartCommand cmd = new KickstartCommand();
        cmd.setCreated(new Date());
        cmd.setCommandName(commandName);
        cmd.setArguments("--" + selinuxMode);
        cmd.setKickstartData(ksdata);
        ksdata.removeCommand(SELINUX_MODE_PARAM, false);
        ksdata.getCommands().add(cmd);
        cmd = ksdata.getCommand(SELINUX_MODE_PARAM);
    }
    
    private void transferNetworkEdits(DynaActionForm form, KickstartData ksdata) {
        String networkType = form.getString(NETWORK_TYPE_FORM_VAR);
        String interfaceName = null;
        if (networkType.equals(DHCP_NETWORK_TYPE)) {
            interfaceName = form.getString(DHCP_IF_FORM_VAR);
            form.set(STATIC_IF_FORM_VAR, "");
        }
        else {
            interfaceName = form.getString(STATIC_IF_FORM_VAR);
            form.set(DHCP_IF_FORM_VAR, "");
        }
        ksdata.setStaticDevice(networkType + ":" + interfaceName);        
    }
    
    private void transferRootPasswordEdits(DynaActionForm form, KickstartData ksdata,
            RequestContext ctx) {
        String rootPw = form.getString("rootPassword");
        KickstartCommandName commandName = null;
        KickstartCommand cmd = null;
        SystemDetailsCommand systemDetailsCommand = 
            new SystemDetailsCommand(ksdata.getId(), ctx.getCurrentUser());
        if (rootPw != null && rootPw.length() > 0) {
            String rootPwConfirm = form.getString("rootPasswordConfirm");
            if (rootPw.equals(rootPwConfirm)) {
                ksdata.removeCommand("rootpw", true);
                commandName = systemDetailsCommand.findCommandName("rootpw");
                cmd = new KickstartCommand();
                cmd.setCreated(new Date());
                cmd.setKickstartData(ksdata);
                cmd.setCommandName(commandName);
                cmd.setArguments(MD5Crypt.crypt(rootPw));
                ksdata.getCommands().add(cmd);
            }
        }
    }
    
    private void transferFlagEdits(DynaActionForm form, KickstartData ksdata) {
        KickstartDefaults defaults = ksdata.getKsdefault();
        if (defaults == null) {
            defaults = new KickstartDefaults();
            defaults.setCreated(new Date());
        }
        String flag = form.getString("configManagement");
        defaults.setCfgManagementFlag(new 
                Boolean(BooleanUtils.toBoolean(flag)));
        flag = form.getString("remoteCommands");
        defaults.setRemoteCommandFlag(new 
                Boolean(BooleanUtils.toBoolean(flag)));
    }
}
