/**
 * Copyright (c) 2013 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.iss;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.iss.IssSlave;
import com.redhat.rhn.domain.iss.IssFactory;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.acl.AclManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;


/**
 * EditSlaveAction extends RhnAction
 * @version $Rev: 1 $
 */
public class EditSlaveAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) throws Exception {

        if (!AclManager.hasAcl("user_role(satellite_admin)", request, null)) {
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex =
                new PermissionException("Only satellite admins can modify allowed-slaves");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.iss.slave"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.general"));
            throw pex;
        }

        ActionForward retval = mapping.findForward(RhnHelper.DEFAULT_FORWARD);

        DynaActionForm dynaForm = (DynaActionForm) formIn;
        if (isSubmitted(dynaForm)) {
            Long sid = updateSlaveDetails(mapping, dynaForm, request, response);
            retval = mapping.findForward("success");
            retval = getStrutsDelegate().forwardParam(retval, IssSlave.SID, sid.toString());
        }
        else {
            setupFormValues(request, dynaForm);
        }
        return retval;
    }

    private void setupFormValues(HttpServletRequest request,
            DynaActionForm daForm) {

        RequestContext requestContext = new RequestContext(request);
        Long sid = requestContext.getParamAsLong(IssSlave.SID);

        if (sid == null) { // Creating new
            daForm.set(IssSlave.ID, IssSlave.NEW_SLAVE_ID);
            daForm.set(IssSlave.ENABLED, true);
            daForm.set(IssSlave.ALLOWED_ALL_ORGS, true);
        }
        else {
            IssSlave slave = IssFactory.lookupSlaveById(sid);

            daForm.set(IssSlave.ID, sid);
            daForm.set(IssSlave.SLAVE, slave.getSlave());
            daForm.set(IssSlave.ENABLED, "Y".equals(slave.getEnabled()));
            daForm.set(IssSlave.ALLOWED_ALL_ORGS, "Y".equals(slave.getAllowAllOrgs()));

            request.setAttribute(IssSlave.SID, sid);
        }
    }

    private Long updateSlaveDetails(ActionMapping mapping,
            DynaActionForm dynaForm,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        Long sid = null;
        if (validateForm(request, dynaForm)) {
            sid = (Long) dynaForm.get(IssSlave.ID);
            boolean isNew = (IssSlave.NEW_SLAVE_ID == sid);

            IssSlave slave = null;
            if (isNew) {
                slave = new IssSlave();
            }
            else {
                slave = IssFactory.lookupSlaveById(sid);
            }

            String fqdn = dynaForm.getString(IssSlave.SLAVE);
            slave.setSlave(fqdn);
            Boolean enabled = (Boolean) dynaForm.get(IssSlave.ENABLED);
            if (enabled == null) {
                enabled = Boolean.FALSE;
            }
            slave.setEnabled(enabled ? "Y" : "N");
            Boolean allowAll = (Boolean) dynaForm.get(IssSlave.ALLOWED_ALL_ORGS);
            if (allowAll == null) {
                allowAll = Boolean.FALSE;
            }
            slave.setAllowAllOrgs(allowAll ? "Y" : "N");

            if (isNew) {
                IssFactory.save(slave);
                slave = (IssSlave)IssFactory.reload(slave);
                sid = slave.getId();
            }

            ActionMessages msg = new ActionMessages();
            if (isNew) {
                msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                                "message.iss_slave_created", fqdn));
            }
            else {
                msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                                "message.iss_slave_updated", fqdn));
            }
            getStrutsDelegate().saveMessages(request, msg);
        }
        return sid;
   }

    private boolean validateForm(HttpServletRequest request, DynaActionForm form) {
        boolean retval = true;
        return retval;
    }

    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.ISS_LOCAL_ORGS;
    }

}
