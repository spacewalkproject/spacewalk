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
package com.redhat.rhn.frontend.action.systems.sdc;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.org.MigrationManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * SystemDetailsEditAction
 * @version $Rev$
 */
public class SystemMigrateAction extends RhnAction {

    private static Logger log = Logger.getLogger(SystemMigrateAction.class);

    public static final String SID = "sid";
    public static final String ORG = "to_org";


    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
        RequestContext rctx = new RequestContext(request);
        DynaActionForm daForm = (DynaActionForm) form;
        User user = rctx.getLoggedInUser();
        String forwardName = "default";
        Integer trustedOrgCount = user.getOrg().getTrustedOrgs().size();

        if (isSubmitted(daForm)) {
            ActionErrors errors = RhnValidationHelper.validateDynaActionForm(this, daForm);

            Server s = SystemManager.lookupByIdAndUser(
                    rctx.getRequiredParam(RequestContext.SID), user);
            // As a pre-requisite to performing the actual migration, verify that each
            // server that is planned for migration passes the criteria that follows.
            // If any of the servers fails that criteria, none will be migrated.

            Org toOrg = OrgFactory.lookupByName(daForm.getString(ORG));
            Long sid = s.getId();      // Required because if the migration goes ahead we
            String name = s.getName(); // can't lookup the servers ID

            // Don't attempt migration to organisation "None"
            if (toOrg == null) {
                ValidatorError err = new ValidatorError("system.migrate.no_org_specified");
                getStrutsDelegate().saveMessages(request,
                        RhnValidationHelper.validatorErrorToActionErrors(err));
            }
            else {
                forwardName = "success";

                // unless the user is a satellite admin, they are not permitted to migrate
                // systems from an org that they do not belong to
                if ((!user.hasRole(RoleFactory.SAT_ADMIN)) &&
                    (!user.getOrg().equals(s.getOrg()))) {
                    ValidatorError err = new ValidatorError("system.migrate.user_no_perms");
                    getStrutsDelegate().saveMessages(request,
                            RhnValidationHelper.validatorErrorToActionErrors(err));
                forwardName = "error";
                }

                // do not allow the user to migrate systems to/from the same org.  doing so
                // would essentially remove entitlements, channels...etc from the systems
                // being migrated.
                if (toOrg.equals(s.getOrg())) {
                    ValidatorError err = new ValidatorError("system.migrate.same_org");
                    getStrutsDelegate().saveMessages(request,
                            RhnValidationHelper.validatorErrorToActionErrors(err));
                forwardName = "error";
                }

                // if the originating org is not defined within the destination org's trust
                // the migration should not be permitted.
                if (!toOrg.getTrustedOrgs().contains(s.getOrg())) {
                    ValidatorError err = new ValidatorError(
                            "system.migrate.org_not_trusted");
                    getStrutsDelegate().saveMessages(request,
                            RhnValidationHelper.validatorErrorToActionErrors(err));
                forwardName = "error";
                }

                if (trustedOrgCount == 0) {
                    ValidatorError err = new ValidatorError(
                            "system.migrate.no_trusted_orgs");
                    getStrutsDelegate().saveMessages(request,
                            RhnValidationHelper.validatorErrorToActionErrors(err));
                forwardName = "error";
                }
            }

            if (errors.isEmpty() && forwardName.equals("success")) {
                if (processSubmission(request, daForm, user, s, toOrg)) {
                    createSuccessMessage(request,
                            "sdc.details.migrate.success", name);

                    return mapping.findForward(forwardName);
                }
                else {
                    forwardName = "error";
                }

            }
            else {
                forwardName = "error";
                getStrutsDelegate().saveMessages(request, errors);
            }
        }

        if (forwardName.equals("default")) {
            Server s = SystemManager.lookupByIdAndUser(
                    rctx.getRequiredParam(RequestContext.SID), user);
            Org fromOrg = s.getOrg();
            setupPageAndFormValues(rctx.getRequest(), daForm, user, s, fromOrg,
                    trustedOrgCount);
        }

        return mapping.findForward(forwardName);
    }

    /**
     * Proccesses the system details edit form
     * @param request to add messages to.
     * @param daForm DynaActionForm to be processed
     * @param user User submitting the form
     * @param s Server whose details are being update
     * @return true if the submission process didnot produce any errors.
     */
    private boolean processSubmission(HttpServletRequest request,
            DynaActionForm daForm, User user, Server s, Org toOrg) {

        boolean success = true;
        boolean failure = false;

        List<Server> serverList = new ArrayList<Server>();
        serverList.add(s);

        List<Long> serversMigrated = MigrationManager.migrateServers(user,
                toOrg, serverList);

        Iterator it = serversMigrated.iterator();
        Long value = (Long)it.next();

        if (value != null) {
            return success;
        }
        return failure;
    }

    protected void setupPageAndFormValues(HttpServletRequest request,
            DynaActionForm daForm, User user, Server s, Org o, Integer trustedOrgCount) {

        List orgList = new ArrayList(user.getOrg().getTrustedOrgs());

        request.setAttribute("trustedOrgCount", trustedOrgCount);
        request.setAttribute("system", s);
        request.setAttribute("orgs", orgList);
        request.setAttribute("org", o);
    }

}
