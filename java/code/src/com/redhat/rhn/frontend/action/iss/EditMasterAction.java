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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.iss.IssFactory;
import com.redhat.rhn.domain.iss.IssMaster;
import com.redhat.rhn.domain.iss.IssMasterOrg;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.acl.AclManager;

/**
 * EditMasterAction extends RhnAction
 *
 * @version $Rev: 1 $
 */
public class EditMasterAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
                    HttpServletRequest request, HttpServletResponse response)
                    throws Exception {

        if (!AclManager.hasAcl("user_role(satellite_admin)", request, null)) {
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException(
                            "Only satellite admins can modify masters");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.iss.master"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.general"));
            throw pex;
        }

        ActionForward retval = mapping.findForward(RhnHelper.DEFAULT_FORWARD);

        DynaActionForm dynaForm = (DynaActionForm) formIn;
        if (isSubmitted(dynaForm)) {

            if (validateForm(request, dynaForm)) {
                Long mid = updateMasterDetails(mapping, dynaForm, request, response);
                retval = mapping.findForward("success");
                retval = getStrutsDelegate().forwardParam(retval, IssMaster.ID,
                                mid.toString());
            }
        }
        else {
            setupFormValues(request, dynaForm);
        }
        return retval;
    }

    private void setupFormValues(HttpServletRequest request, DynaActionForm daForm) {

        RequestContext requestContext = new RequestContext(request);
        Long mid = requestContext.getParamAsLong(IssMaster.ID);

        IssMaster master = IssFactory.lookupMasterById(mid);

        daForm.set(IssMaster.ID, mid);
        daForm.set(IssMaster.LABEL, master.getLabel());
        daForm.set(IssMaster.DEFAULT_MASTER, master.isDefaultMaster());
        daForm.set(IssMaster.CA_CERT, master.getCaCert());

        request.setAttribute("mid", mid);
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI() +
                        "?id=" + mid.toString());
    }

    private Long updateMasterDetails(ActionMapping mapping, DynaActionForm dynaForm,
                    HttpServletRequest request, HttpServletResponse response)
                    throws Exception {

        RequestContext ctxt = new RequestContext(request);
        ActionMessages msg = new ActionMessages();
        Long mid = ctxt.getRequiredParam("id");

        if (IssMaster.NEW_MASTER_ID == mid) {
            IssMaster newMaster = new IssMaster();
            applyFormValues(dynaForm, newMaster);
            IssFactory.save(newMaster);
            newMaster = (IssMaster)IssFactory.reload(newMaster);
            mid = newMaster.getId();

            msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                            "message.iss_master_created", newMaster.getLabel()));
        }
        else {
            IssMaster master = IssFactory.lookupMasterById(mid);

            applyFormValues(dynaForm, master);

            List<IssMasterOrg> masterOrgs = new ArrayList<IssMasterOrg>(
                            master.getMasterOrgs());
            List<Org> locals = OrgFactory.lookupAllOrgs();
            Map<Long, Org> findLocals = new HashMap<Long, Org>();
            for (Org o : locals) {
                findLocals.put(o.getId(), o);
            }

            for (IssMasterOrg entry : masterOrgs) {
                Long targetId = ctxt.getParamAsLong(entry.getId().toString());
                if (targetId == null || targetId.equals(IssMasterOrg.NO_MAP_ID)) {
                    entry.setLocalOrg(null);
                }
                else {
                    entry.setLocalOrg(findLocals.get(targetId));
                }
                IssFactory.save(entry);
            }
            msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                            "message.iss_master_updated", master.getLabel()));
        }
        getStrutsDelegate().saveMessages(request, msg);
        return mid;
    }

    private boolean validateForm(HttpServletRequest request, DynaActionForm form) {
        boolean retval = true;
        String label = form.getString(IssMaster.LABEL);
        if (label == null || label.isEmpty()) {
            LocalizationService l = LocalizationService.getInstance();
            retval = false;
            ActionErrors errs = new ActionErrors();
            errs.add(ActionErrors.GLOBAL_MESSAGE, new ActionMessage(
                            "errors.required",
                            l.getMessage("iss.master.label")));
            getStrutsDelegate().saveMessages(request, errs);
        }
        return retval;
    }

    private void applyFormValues(DynaActionForm daForm, IssMaster master) {
        master.setLabel(daForm.getString(IssMaster.LABEL));

        Boolean isDefault = (Boolean) daForm.get(IssMaster.DEFAULT_MASTER);
        if (isDefault == null) {
            isDefault = Boolean.FALSE;
        }

        if (isDefault) {
            master.makeDefaultMaster();
        }
        else {
            master.unsetAsDefault();
        }
        master.setCaCert(daForm.getString(IssMaster.CA_CERT));
    }

}
