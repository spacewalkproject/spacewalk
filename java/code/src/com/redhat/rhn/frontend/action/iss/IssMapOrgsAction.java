/**
 * Copyright (c) 2013 Red Hat, Inc.
 * All Rights Reserved.
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
 *
 */
package com.redhat.rhn.frontend.action.iss;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
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
import com.redhat.rhn.domain.iss.IssOrgCatalogue;
import com.redhat.rhn.domain.iss.IssSyncOrg;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.frontend.dto.OrgDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.acl.AclManager;

/**
 * IssMapOrgsAction extends RhnAction - Class representation of the table
 * ###TABLE###.
 *
 * @version $Rev: 1 $
 */
public class IssMapOrgsAction extends RhnAction {
    private static final String DATA_SET = "all";
    private static final String SLAVES = "slave_org_list";

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

        if (request.getParameter("dispatch") != null) {
            return handleDispatchAction(mapping, ctxt);
        }

        // Get all the known-orgs from the selected Master
        List<IssSyncOrg> result = new ArrayList<IssSyncOrg>(
                        IssFactory.lookupMasterById(mid).getSourceOrgs());
        // Get all of our orgs and turn into OrgDtos
        List<OrgDto> infos = fromOrgs(OrgFactory.lookupAllOrgs());

        Map params = makeParamMap(request);
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI() +
                        "?mid=" + mid.toString());

        request.setAttribute(DATA_SET, result);
        request.setAttribute(SLAVES, infos);

        return StrutsDelegate.getInstance().forwardParams(mapping.findForward("default"),
                        params);
    }

    protected ActionForward handleDispatchAction(
                    ActionMapping mapping, RequestContext ctxt) {
        //TODO: Figure out what we're doing, and how, and then DO IT
        return null;
    }

    protected void setupForm(ActionForm formIn, IssOrgCatalogue master) {
        DynaActionForm form = (DynaActionForm) formIn;
        form.set(IssOrgCatalogue.ID, master.getId());
        form.set(IssOrgCatalogue.LABEL, master.getLabel());
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
        OrgDto noMap = createOrgDto(IssSyncOrg.NO_MAP_ID, "NOT MAPPED");

        outList.add(noMap);
        Collections.sort(outList, new OrgComparator());

        return outList;
    }

}

/**
 * Compares OrgDtos by ID
 * @author ggainey
 *
 */
class OrgComparator implements Comparator<OrgDto> {

    @Override
    public int compare(OrgDto o1, OrgDto o2) {
        if (o1 == null || o2 == null) {
            throw new NullPointerException("Can't compare OrgDto with null");
        }
        return o1.getId().compareTo(o2.getId());
    }

}
