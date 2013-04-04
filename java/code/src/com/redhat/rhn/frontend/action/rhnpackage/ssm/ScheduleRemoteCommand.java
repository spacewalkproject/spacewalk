/**
 * Copyright (c) 2009--2013 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.rhnpackage.ssm;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.messaging.EventMessage;
import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.action.script.ScriptActionDetails;
import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.rhnpackage.PackageEvrFactory;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.frontend.events.SsmInstallPackagesEvent;
import com.redhat.rhn.frontend.events.SsmRemovePackagesEvent;
import com.redhat.rhn.frontend.events.SsmUpgradePackagesEvent;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.SessionSetHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.ssm.SsmManager;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * ScheduleRemoteCommand
 *
 * @version $Rev$
 */
public class ScheduleRemoteCommand extends RhnAction {
    public static final String BEFORE       = "before";
    public static final String MODE_REMOVAL = "remove";
    public static final String MODE_UPGRADE = "upgrade";
    public static final String MODE_INSTALL = "install";

    public static final String CAPABLE      = "capable";
    public static final String ENTITLED     = "entitled";

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        StrutsDelegate strutsDelegate = getStrutsDelegate();

        ActionForward forward = null;
        DynaActionForm f = (DynaActionForm) form;
        String mode = (String) f.get("mode");

        RequestContext requestContext = new RequestContext(request);
        Long cid = null;
        if (MODE_INSTALL.equals(mode)) {
            cid = requestContext.getRequiredParam("cid");
        }
        User user = requestContext.getLoggedInUser();

        Map reqMap = new HashMap();
        reqMap.putAll(request.getParameterMap());

        if (!isSubmitted(f)) {
            ActionErrors errs = checkAllowed(user);
            if (!errs.isEmpty()) {
                strutsDelegate.saveMessages(request, errs);
            }
            setup(request, f);
            forward = strutsDelegate.forwardParams(
                    mapping.findForward(RhnHelper.DEFAULT_FORWARD), reqMap);
        }
        else {
            ActionErrors errs = checkAllowed(user);
            if (!errs.isEmpty()) {
                strutsDelegate.saveMessages(request, errs);
                forward = strutsDelegate.forwardParams(
                        mapping.findForward(RhnHelper.DEFAULT_FORWARD), reqMap);
            }
            else {
                ActionMessages msgs = processForm(user, cid, f, request);
                strutsDelegate.saveMessages(request, msgs);
                forward = strutsDelegate.forwardParams(mapping.findForward("confirm"),
                        reqMap);
            }
        }

        return forward;
    }

    private ActionErrors checkAllowed(User u) {
        List<Long> notCapable = new ArrayList<Long>();
        List<Long> notEntitled = new ArrayList<Long>();

        for (Long sid : SsmManager.listServerIds(u)) {
            if (!SystemManager.clientCapable(sid, "script.run")) {
                notCapable.add(sid);
            }

            if (!SystemManager.hasEntitlement(sid, EntitlementManager.PROVISIONING)) {
                notEntitled.add(sid);
            }
        }

        ActionErrors errs = new ActionErrors();
        if (!notCapable.isEmpty()) {
            errs.add(ActionErrors.GLOBAL_MESSAGE, new ActionMessage(
                    "message.capability.missing", "script.run"));
        }
        if (!notEntitled.isEmpty()) {
            errs.add(ActionErrors.GLOBAL_MESSAGE,
                    new ActionMessage("message.entitlement.missing",
                            EntitlementManager.PROVISIONING.getHumanReadableLabel()));
        }
        return errs;
    }

    private ActionMessages processForm(User user,
                                       Long cid,
                                       DynaActionForm f,
                                       HttpServletRequest request) {

        RequestContext ctxt = new RequestContext(request);
        String runBefore = (String) f.get("run_script");
        String username = (String) f.get("username");
        String group = (String) f.get("group");
        Long timeout = (Long) f.get("timeout");
        String script = (String) f.get("script");
        String sessionSetLabel = (String) f.get("session_set_label");

        String mode = (String) f.get("mode");

        // The earliest time to perform the action.
        Date earliest = getStrutsDelegate().readDatePicker(f, "date",
                DatePicker.YEAR_RANGE_POSITIVE);

        ScriptActionDetails sad = ActionManager.createScript(username, group, timeout,
                script);
        boolean isBefore = (BEFORE.equals(runBefore));

        ActionMessages msgs = new ActionMessages();

        // Fire off the request on the message queue
        EventMessage event;
        if (MODE_INSTALL.equals(mode)) {
            Set<String> pkgNames = SessionSetHelper.lookupAndBind(request, sessionSetLabel);
            event = new SsmInstallPackagesEvent(user.getId(), earliest, pkgNames, cid, sad,
                    isBefore);
            MessageQueue.publish(event);
            SessionSetHelper.obliterate(request, sessionSetLabel);

            msgs.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                    "ssm.package.install.message.packageinstalls"));
        }
        else if (MODE_UPGRADE.equals(mode)) {
            List<Map> result = getUpgradeResult(ctxt, sessionSetLabel);

            Map<Long, List<Map<String, Long>>> sysPackageSet =
                    new HashMap<Long, List<Map<String, Long>>>();
            for (Map sys : result) {
                Long sysId = (Long) sys.get("id");
                List<Map<String, Long>> pkgSet = new ArrayList<Map<String, Long>>();
                sysPackageSet.put(sysId, pkgSet);
                for (Map pkg : (List<Map>) sys.get("elaborator0")) {
                    Map<String, Long> newPkg = new HashMap();
                    newPkg.put("name_id", (Long) pkg.get("name_id"));
                    newPkg.put("evr_id", (Long) pkg.get("evr_id"));
                    newPkg.put("arch_id", (Long) pkg.get("arch_id"));
                    pkgSet.add(newPkg);
                }
            }

            event = new SsmUpgradePackagesEvent(user.getId(), earliest, sysPackageSet, sad,
                    isBefore);

            MessageQueue.publish(event);
            SessionSetHelper.obliterate(request, sessionSetLabel);
            RhnSetManager.deleteByLabel(user.getId(),
                    RhnSetDecl.SSM_UPGRADE_PACKAGES_LIST.getLabel());

            msgs.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                    "ssm.package.upgrade.message.packageupgrade"));
        }
        else if (MODE_REMOVAL.equals(mode)) {
            List<Map> result = getRemoveResult(ctxt, sessionSetLabel);

            event = new SsmRemovePackagesEvent(user.getId(), earliest, result, sad,
                    isBefore);

            MessageQueue.publish(event);
            SessionSetHelper.obliterate(request, sessionSetLabel);
            RhnSetManager.deleteByLabel(user.getId(),
                    RhnSetDecl.SSM_REMOVE_PACKAGES_LIST.getLabel());

            msgs.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                    "ssm.package.remove.message.packageremovals"));
        }

        return msgs;
    }

    private void setup(HttpServletRequest request, DynaActionForm form) {
        form.set("run_script", "before");
        form.set("username", "root");
        form.set("group", "root");
        form.set("timeout", new Long(600));
        form.set("script", "#!/bin/sh");
        form.set("mode", request.getParameter("mode"));
        form.set("session_set_label", request.getParameter("packagesDecl"));

        Date date = getStrutsDelegate().readDatePicker(form, "date",
                DatePicker.YEAR_RANGE_POSITIVE);

        request.setAttribute("scheduledDate",
                LocalizationService.getInstance().formatDate(date));
    }

    private List getUpgradeResult(RequestContext context, String setLabel) {

        HttpServletRequest request = context.getRequest();
        User user = context.getLoggedInUser();

        // Stuff packages into an RhnSet to be used in the query
        if (setLabel != null) {
            Set<String> data = SessionSetHelper.lookupAndBind(request, setLabel);

            // bz465892 - As the selected packages are parsed, remove duplicates
            // keeping the highest EVR
            Map<String, PackageListItem> packageNameIdsToItems =
                    new HashMap<String, PackageListItem>(data.size());

            for (String idCombo : data) {
                PackageListItem item = PackageListItem.parse(idCombo);

                PackageListItem existing = packageNameIdsToItems.get(item.getIdOne() + "|" +
                        item.getIdThree());
                if (existing != null) {
                    String[] existingParts = splitEvr(existing.getNvre());
                    String[] itemParts = splitEvr(item.getNvre());

                    PackageEvr existingEvr = PackageEvrFactory.lookupOrCreatePackageEvr(
                            existingParts[0], existingParts[1], existingParts[2]);

                    PackageEvr itemEvr = PackageEvrFactory.lookupOrCreatePackageEvr(
                            itemParts[0], itemParts[1], itemParts[2]);

                    if (existingEvr.compareTo(itemEvr) < 0) {
                        packageNameIdsToItems.put(
                                item.getIdOne() + "|" + item.getIdThree(), item);
                    }
                }
                else {
                    packageNameIdsToItems.put(item.getIdOne() + "|" + item.getIdThree(),
                            item);
                }
            }

            RhnSet packageSet = RhnSetManager.createSet(user.getId(),
                    RhnSetDecl.SSM_UPGRADE_PACKAGES_LIST.getLabel(), SetCleanup.NOOP);

            for (PackageListItem item : packageNameIdsToItems.values()) {
                packageSet.addElement(item.getIdOne(), item.getIdTwo(), item.getIdThree());
            }

            RhnSetManager.store(packageSet);
        }

        DataResult results = SystemManager.ssmSystemPackagesToUpgrade(user,
                RhnSetDecl.SSM_UPGRADE_PACKAGES_LIST.getLabel());

        TagHelper.bindElaboratorTo("groupList", results.getElaborator(), request);
        results.elaborate();

        return results;
    }

    private String[] splitEvr(String evr) {
        String[] values = StringUtils.split(evr, "-");
        for (int i = 0; i < values.length; i++) {
            if ("null".equals(values[i])) {
                values[i] = null;
            }
        }
        return values;
    }

    private List getRemoveResult(RequestContext context, String setLabel) {
        HttpServletRequest request = context.getRequest();
        User user = context.getLoggedInUser();

        // Stuff packages into an RhnSet to be used in the query
        String packagesDecl = (String) request.getAttribute("packagesDecl");
        if (packagesDecl != null) {
            Set<String> data = SessionSetHelper.lookupAndBind(request, packagesDecl);

            RhnSet packageSet = RhnSetManager.createSet(user.getId(),
                    RhnSetDecl.SSM_REMOVE_PACKAGES_LIST.getLabel(), SetCleanup.NOOP);

            for (String idCombo : data) {
                PackageListItem item = PackageListItem.parse(idCombo);
                packageSet.addElement(item.getIdOne(), item.getIdTwo(), item.getIdThree());
            }

            RhnSetManager.store(packageSet);
        }

        DataResult results = SystemManager.ssmSystemPackagesToRemove(user,
                RhnSetDecl.SSM_REMOVE_PACKAGES_LIST.getLabel(), true);

        TagHelper.bindElaboratorTo("groupList", results.getElaborator(), request);
        results.elaborate();

        return results;
    }

}
