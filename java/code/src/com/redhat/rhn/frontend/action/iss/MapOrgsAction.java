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
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.iss.IssFactory;
import com.redhat.rhn.domain.iss.IssMaster;
import com.redhat.rhn.domain.iss.IssMasterOrg;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.frontend.dto.OrgDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.acl.AclManager;

/**
 * MapOrgsAction extends RhnAction
 *
 * @version $Rev: 1 $
 */
public class MapOrgsAction extends RhnAction {
    private static final String DATA_SET = "all";
    private static final String SLAVES = "slave_org_list";
    private static final String MASTER = "master";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
                    HttpServletRequest request, HttpServletResponse response) {

        if (!AclManager.hasAcl("user_role(satellite_admin)", request, null)) {
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException(
                            "Only satellite admins can work with org-mappings");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.iss.master"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.general"));
            throw pex;
        }

        RequestContext ctxt = new RequestContext(request);

        Long mid = ctxt.getRequiredParam("mid");
        request.setAttribute("mid", mid);

        // Get all the known-orgs from the selected Master
        IssMaster oc = IssFactory.lookupMasterById(mid);
        if (request.getParameter("dispatch") != null) {
            return handleDispatchAction(mapping, ctxt, oc);
        }

        List<IssMasterOrg> result = new ArrayList<IssMasterOrg>(
                        oc.getMasterOrgs());
        Collections.sort(result, new IssSyncOrgComparator());

        // Get all of our orgs and turn into OrgDtos
        List<OrgDto> locals = fromOrgs(OrgFactory.lookupAllOrgs());

        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI() +
                        "?mid=" + mid.toString());

        request.setAttribute(DATA_SET, result);
        request.setAttribute(SLAVES, locals);
        request.setAttribute(MASTER, oc.getLabel());

        return mapping.findForward("default");
    }

    protected ActionForward handleDispatchAction(
                    ActionMapping mapping,
                    RequestContext ctxt,
                    IssMaster master) {
        //TODO: Figure out what we're doing, and how, and then DO IT
        List<IssMasterOrg> masterOrgs =
                        new ArrayList<IssMasterOrg>(master.getMasterOrgs());
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
        return mapping.findForward("success");
    }

    protected void setupForm(ActionForm formIn, IssMaster master) {
        DynaActionForm form = (DynaActionForm) formIn;
        form.set(IssMaster.ID, master.getId());
        form.set(IssMaster.LABEL, master.getLabel());
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

        OrgDto noMap = createOrgDto(IssMasterOrg.NO_MAP_ID, "NOT MAPPED");
        outList.add(0, noMap);

        return outList;
    }

}

/**
 * Compares OrgDtos by name
 * @author ggainey
 *
 */
class OrgComparator implements Comparator<OrgDto> {

    public int compare(OrgDto o1, OrgDto o2) {
        if (o1 == null || o2 == null) {
            throw new NullPointerException("Can't compare OrgDto with null");
        }
        return o1.getName().compareTo(o2.getName());
    }
}

    /**
     * Compares IssSyncOrg by Catalogue/source-org-name
     * @author ggainey
     *
     */
    class IssSyncOrgComparator implements Comparator<IssMasterOrg> {

        public int compare(IssMasterOrg so1, IssMasterOrg so2) {
            if (so1 == null || so2 == null) {
                throw new NullPointerException("Can't compare IssSyncOrg with null");
            }
            return so1.getMasterOrgName().compareTo(so2.getMasterOrgName());
        }

}
