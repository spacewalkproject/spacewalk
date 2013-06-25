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
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.iss.IssFactory;
import com.redhat.rhn.domain.iss.IssSlave;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.frontend.dto.OrgDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.SessionSetHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.acl.AclManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;


/**
 * EditSlaveSetupAction extends RhnAction
 * @version $Rev: 1 $
 */
public class EditSlaveSetupAction extends RhnAction {

    private static final String LIST_NAME = "localOrgsList";

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

        DynaActionForm dynaForm = (DynaActionForm) formIn;
        setupFormValues(request, dynaForm);
        setupOrgList(mapping, request, response);

        ActionForward retval = mapping.findForward(RhnHelper.DEFAULT_FORWARD);
        return retval;
    }

    private void setupOrgList(ActionMapping mapping, HttpServletRequest request,
                    HttpServletResponse response) {
        RequestContext ctxt = new RequestContext(request);
        Long sid = ctxt.getParamAsLong(IssSlave.SID);
        if (sid == null) {
            return;
        }

        request.setAttribute(ListTagHelper.PARENT_URL,
                        "/rhn/admin/iss/AllowSlaveOrgs.do?sid=" + sid);

         IssSlave theSlave = IssFactory.lookupSlaveById(sid);
        Set<Long> mappedOrgs = mappedLocalOrgs(
                        new ArrayList<Org>(theSlave.getAllowedOrgs()));
        List<OrgDto> locals = fromOrgs(OrgFactory.lookupAllOrgs());

        Set sessionSet = SessionSetHelper.lookupAndBind(request, getSetDecl()
                        .getLabel());
        SessionSetHelper helper = new SessionSetHelper(request);

        // if I have a previous set selections populate data using it
        if (!sessionSet.isEmpty()) {
            helper.syncSelections(sessionSet, locals);
            ListTagHelper.setSelectedAmount(LIST_NAME, sessionSet.size(), request);
        }
        else {
            for (OrgDto o : locals) {
                o.setSelected(mappedOrgs.contains(o.getId()));
            }
        }
        request.setAttribute(LIST_NAME, locals);
        ListTagHelper.bindSetDeclTo(LIST_NAME, getSetDecl(), request);
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

    protected OrgDto createOrgDto(Long id, String name) {
        OrgDto oi = new OrgDto();
        oi.setId(id);
        oi.setName(name);
        return oi;
    }

    protected List<OrgDto> fromOrgs(List<Org> orgs) {
        List<OrgDto> outList = new ArrayList<OrgDto>();
        for (Org o : orgs) {
            outList.add(createOrgDto(o.getId(), o.getName()));
        }

        Collections.sort(outList, new OrgComparator());

        return outList;
    }

    protected Set<Long> mappedLocalOrgs(List<Org> orgs) {
        Set<Long> outIds = new HashSet<Long>();
        for (Org o : orgs) {
            outIds.add(o.getId());
        }

        return outIds;
    }

    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.ISS_LOCAL_ORGS;
    }

}
