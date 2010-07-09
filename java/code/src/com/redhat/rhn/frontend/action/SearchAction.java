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
package com.redhat.rhn.frontend.action;

import com.redhat.rhn.common.util.ServletUtils;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.channel.PackageSearchAction;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.action.systems.SystemSearchSetupAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

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
            String searchString = daForm.getString("search_string");
            String searchType = daForm.getString("search_type");

            if (searchType == null) {
                return mapping.findForward("default");
            }
            else if (searchType.equals("systems") &&
                    (user.getOrg().getEntitlements().contains(
                            OrgFactory.getEntitlementSwMgrPersonal()) ||
                    user.getOrg().getEntitlements().contains(
                            OrgFactory.getEntitlementEnterprise()))) {
                HashMap attributes = new HashMap();
                attributes.put(RhnAction.SUBMITTED, "true");
                attributes.put(SystemSearchSetupAction.WHERE_TO_SEARCH, "all");
                attributes.put(SystemSearchSetupAction.VIEW_MODE,
                               "systemsearch_name_and_description");
                attributes.put(SystemSearchSetupAction.SEARCH_STRING, searchString);
                performRedirect("/systems/Search.do",
                                request.getContextPath(),
                                response,
                                attributes);

                return null;
            }
            else if (searchType.equals("errata")) {
                HashMap attributes = new HashMap();
                attributes.put("view_mode", "errata_search_by_all_fields");
                attributes.put(SystemSearchSetupAction.SEARCH_STRING, searchString);
                attributes.put("optionIssueDateSearch", Boolean.FALSE);
                attributes.put("errata_type_bug", Boolean.TRUE);
                attributes.put("errata_type_security", Boolean.TRUE);
                attributes.put("errata_type_enhancement", Boolean.TRUE);
                performRedirect("/errata/Search.do",
                                request.getContextPath(),
                                response,
                                attributes);

                return null;
            }
            else if (searchType.equals("packages")) {
                HashMap attributes = new HashMap();
                attributes.put("view_mode", "search_name_and_summary");
                attributes.put(SystemSearchSetupAction.SEARCH_STRING, searchString);
                attributes.put(PackageSearchAction.WHERE_CRITERIA, "architecture");

                // select all the arches to make a better search
                List<String> defaultArches = new ArrayList<String>();
                defaultArches.add("channel-ia32");
                defaultArches.add("channel-ia64");
                defaultArches.add("channel-x86_64");
                defaultArches.add("channel-s390");
                defaultArches.add("channel-s390x");
                defaultArches.add("channel-ppc");
                defaultArches.add("channel-sparc-sun-solaris");
                defaultArches.add("channel-i386-sun-solaris");

                attributes.put("channel_arch", defaultArches);

                performRedirect("/channels/software/Search.do",
                                request.getContextPath(),
                                response,
                                attributes);

                return null;
            }
            else if (searchType.equals("docs")) {
                HashMap attributes = new HashMap();
                attributes.put("view_mode", "search_content_title");
                attributes.put(SystemSearchSetupAction.SEARCH_STRING, searchString);
                performRedirect("/help/Search.do",
                                request.getContextPath(),
                                response,
                                attributes);

                return null;
            }
            else {
                return mapping.findForward("error");
            }
        }
        else {
            return mapping.findForward("error");
        }
    }

    protected void performRedirect(String url,
                                   String contextPath,
                                   HttpServletResponse response,
                                   Map attributes) {
        try {
            response.sendRedirect(
                    ServletUtils.pathWithParams(contextPath + url, attributes));
        }
        catch (IOException ioe) {
            throw new RuntimeException(
                    "Exception while trying to redirect: " + ioe);
        }
    }
}
