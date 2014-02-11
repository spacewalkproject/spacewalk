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
package com.redhat.rhn.frontend.action;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;

/**
 * SearchAction
 * @version $Rev$
 */
public class SearchAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response)
                                  throws BadParameterException {

        RequestContext requestContext = new RequestContext(request);

        User user = requestContext.getLoggedInUser();
        DynaActionForm daForm = (DynaActionForm) formIn;

        if (isSubmitted(daForm)) {
            String searchString = daForm.getString(BaseSearchAction.SEARCH_STR);
            String searchType = daForm.getString("search_type");

            if (searchType == null) {
                return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
            }
            else if (searchType.equals("systems") && systemSearchAllowed(user)) {
                return doSystemSearch(mapping, request, searchString);
            }
            else if (searchType.equals("errata")) {
                return doErrataSearch(mapping, request, searchString);
            }
            else if (searchType.equals("packages")) {
                return doPackageSearch(mapping, request, searchString);
            }
            else if (searchType.equals("docs")) {
                return doDocsSearch(mapping, request, searchString);
            }
            else {
                return mapping.findForward("error");
            }
        }
        return mapping.findForward("error");
    }

    private ActionForward doErrataSearch(ActionMapping mapping, HttpServletRequest request,
                    String searchString) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put(BaseSearchAction.VIEW_MODE, BaseSearchAction.OPT_ALL_FIELDS);
        params.put(BaseSearchAction.SEARCH_STR, searchString);
        params.put(BaseSearchAction.OPT_ISSUE_DATE, Boolean.FALSE);
        params.put(BaseSearchAction.ERRATA_BUG, Boolean.TRUE);
        params.put(BaseSearchAction.ERRATA_SEC, Boolean.TRUE);
        params.put(BaseSearchAction.ERRATA_ENH, Boolean.TRUE);
        params.put(BaseSearchAction.FINE_GRAINED, true);
        return StrutsDelegate.getInstance().forwardParams(
                        mapping.findForward("errata"), params);
    }

    private boolean systemSearchAllowed(User user) {
        return user.getOrg().getEntitlements().contains(
                OrgFactory.getEntitlementSwMgrPersonal()) ||
        user.getOrg().getEntitlements().contains(
                OrgFactory.getEntitlementEnterprise());
    }

    private ActionForward doSystemSearch(ActionMapping mapping, HttpServletRequest request,
                    String searchString) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put(BaseSearchAction.WHERE_TO_SEARCH, BaseSearchAction.WHERE_ALL);
        params.put(BaseSearchAction.VIEW_MODE,
                        "systemsearch_name_and_description");
        params.put(BaseSearchAction.SEARCH_STR, searchString);
        params.put(BaseSearchAction.FINE_GRAINED, true);
        return StrutsDelegate.getInstance().forwardParams(
                        mapping.findForward("systems"), params);
    }

    private ActionForward doDocsSearch(ActionMapping mapping, HttpServletRequest request,
                    String searchString) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put(BaseSearchAction.VIEW_MODE, "search_content_title");
        params.put(BaseSearchAction.SEARCH_STR, searchString);
        return StrutsDelegate.getInstance().forwardParams(
                        mapping.findForward("docs"), params);
    }

    private ActionForward doPackageSearch(ActionMapping mapping,
                    HttpServletRequest request, String searchString) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put(BaseSearchAction.VIEW_MODE,
                        BaseSearchAction.OPT_NAME_AND_SUMMARY);
        params.put(BaseSearchAction.SEARCH_STR, searchString);
        params.put(BaseSearchAction.WHERE_CRITERIA, "architecture");
        params.put(BaseSearchAction.CHANNEL_ARCH,
                        BaseSearchAction.DEFAULT_ARCHES);
        params.put(BaseSearchAction.FINE_GRAINED, true);

        return StrutsDelegate.getInstance().forwardParams(
                        mapping.findForward("packages"), params);
    }
}
