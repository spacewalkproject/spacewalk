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
package com.redhat.rhn.frontend.action.rhnpackage;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.domain.action.script.ScriptActionDetails;
import com.redhat.rhn.domain.action.script.ScriptRunAction;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.util.Date;

/**
 * ScheduleRemoteCommand
 * @version $Rev$
 */
public class ScheduleRemoteCommand extends RhnAction {
    public static final String BEFORE = "before";
    public static final String MODE_REMOVAL = "remove";
    public static final String MODE_UPGRADE = "upgrade";
    public static final String MODE_INSTALL = "install";
    
    private static Logger log = Logger.getLogger(ScheduleRemoteCommand.class);

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
        
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        
        ActionForward forward = null;
        DynaActionForm f = (DynaActionForm)form;
        RequestContext requestContext = new RequestContext(request);
        Long sid = requestContext.getRequiredParam("sid");
        User user = requestContext.getLoggedInUser();
        Server server = SystemManager.lookupByIdAndUser(sid, user);
        request.setAttribute("system", server);
        
        DynaActionForm dynaForm = (DynaActionForm) form;
        DatePicker picker = getStrutsDelegate().prepopulateDatePicker(request, dynaForm,
                "date", DatePicker.YEAR_RANGE_POSITIVE);
       
        request.setAttribute("date", picker);
        
        if (!isSubmitted(f)) {
            setup(request, f);
            forward =  strutsDelegate.forwardParams(mapping.findForward("default"),
                    request.getParameterMap());
        }
        else {
            ActionMessages msgs = processForm(user, server, f);
            strutsDelegate.saveMessages(request, msgs);
    
            String mode = (String) f.get("mode");
            forward = strutsDelegate.forwardParams(
                    mapping.findForward(getForward(mode)),
                    request.getParameterMap());
        }
        
        return forward;
    }
    
    private String getForward(String mode) {
        if (MODE_INSTALL.equals(mode)) {
            return "install";
        }
        else if (MODE_REMOVAL.equals(mode)) {
            return "removal";
        }
        else { // must be upgrade
            return "upgrade";
        }
    }
    
    private void showRemoteCommandMsg(ActionMessages msgs, boolean before) {
        if (before) {
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("message.remotecommandbefore"));
        }
        else {
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("message.remotecommandafter"));
        }
    }
    
    private void showMessages(ActionMessages msgs, Action action,
            Server server, int pkgcnt, String mode) {
        String key = null;
        
        if (MODE_INSTALL.equals(mode)) {
            key = "message.packageinstall";
        }
        else if (MODE_REMOVAL.equals(mode)) {
            key = "message.packageremoval";
        }
        else { // must be upgrade
            key = "message.packageupgrade";
        }
        
        /**
         * If there was only one action archived, display the "action" archived
         * message, else display the "actions" archived message.
         */
        if (pkgcnt == 1) {
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                     new ActionMessage(key,
                             LocalizationService.getInstance()
                                 .formatNumber(new Integer(pkgcnt)),
                             action.getId().toString(),
                             server.getId().toString(),
                             server.getName()));
        }
        else {
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                     new ActionMessage(key + "s", 
                             LocalizationService.getInstance()
                             .formatNumber(new Integer(pkgcnt)),
                         action.getId().toString(),
                         server.getId().toString(),
                         server.getName()));
        }
    }
    
    private PackageAction schedulePackageAction(User user, Server server,
            RhnSet pkgs, String mode, Date earliest) {
        if (MODE_INSTALL.equals(mode)) {
            return ActionManager.schedulePackageInstall(user, server, pkgs, earliest);
        }
        else if (MODE_REMOVAL.equals(mode)) {
            return ActionManager.schedulePackageRemoval(user, server, pkgs, earliest);
        }
        else { // must be upgrade
            return ActionManager.schedulePackageUpgrade(user, server, pkgs, earliest);
        }
    }
    
    private ActionMessages processForm(User user, Server server, DynaActionForm f) {
        if (log.isDebugEnabled()) {
            log.debug("Processing form.");
        }

        ActionMessages msgs = new ActionMessages();
        
        Boolean submitted = (Boolean) f.get("submitted");
        String runBefore = (String) f.get("run_script");
        String username = (String) f.get("username");
        String group = (String) f.get("group");
        Long timeout = (Long) f.get("timeout");
        String script = (String) f.get("script");
        String setLabel = (String) f.get("set_label");
        String mode = (String) f.get("mode");
        
        if (log.isDebugEnabled()) {
            log.debug("submitted [" + submitted + "]");
            log.debug("runBefore [" + runBefore + "]");
            log.debug("username [" + username + "]");
            log.debug("group [" + group + "]");
            log.debug("timeout [" + timeout + "]");
            log.debug("script [" + script + "]");
            log.debug("label [" + setLabel + "]");
            log.debug("mode [" + mode + "]");
        }
        
        //The earliest time to perform the action.
        Date earliest = getStrutsDelegate().readDatePicker(f, "date", 
                DatePicker.YEAR_RANGE_POSITIVE);
        
        if (BEFORE.equals(runBefore)) {
            ScriptActionDetails sad =
                ActionManager.createScript(username, group, timeout, script);
            ScriptRunAction sra = ActionManager.scheduleScriptRun(user, server,
                "", sad, earliest);
            RhnSetDecl decl = RhnSetDecl.findOrCreate(setLabel, SetCleanup.NOOP);
            RhnSet pkgs = decl.get(user);
            int numPackages = pkgs.size();
            PackageAction pa = schedulePackageAction(user, server, pkgs, mode, earliest);
            pa.setPrerequisite(sra.getId());
            ActionManager.storeAction(pa);
            showMessages(msgs, pa, server, numPackages, mode);
            showRemoteCommandMsg(msgs, true);
        }
        else {
            RhnSetDecl decl = RhnSetDecl.findOrCreate(setLabel, SetCleanup.NOOP);
            RhnSet pkgs = decl.get(user);
            int numPackages = pkgs.size();
            PackageAction pa = schedulePackageAction(user, server, pkgs, mode, earliest);
            ScriptActionDetails sad =
                ActionManager.createScript(username, group, timeout, script);
            ScriptRunAction sra = ActionManager.scheduleScriptRun(user, server,
                "", sad, earliest);
            sra.setPrerequisite(pa.getId());
            ActionManager.storeAction(sra);
            showMessages(msgs, sra, server, numPackages, mode);
            showRemoteCommandMsg(msgs, false);
        }
        
        return msgs;
    }
    
    private void setup(HttpServletRequest request, DynaActionForm form) {
        if (log.isDebugEnabled()) {
            log.debug("Setting up form with default values.");
        }
        
        form.set("run_script", "before");
        form.set("username", "root");
        form.set("group", "root");
        form.set("timeout", new Long(600));
        form.set("script", "#!/bin/sh");
        form.set("set_label", "foo");
        form.set("mode", request.getParameter("mode"));
    }
}
