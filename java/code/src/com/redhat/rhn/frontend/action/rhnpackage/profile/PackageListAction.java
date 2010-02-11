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
package com.redhat.rhn.frontend.action.rhnpackage.profile;

import com.redhat.rhn.domain.rhnpackage.profile.Profile;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.profile.ProfileManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * This action will present the user with a list of all stored profiles
 * and allow one to be seleted.
 *
 * @version $Revision$
 */
public class PackageListAction extends RhnAction implements Listable {

    private static final String DATA_SET = "pageList";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping actionMapping,
                                 ActionForm actionForm,
                                 HttpServletRequest request,
                                 HttpServletResponse response)
        throws Exception {

        RequestContext context = new RequestContext(request);

        Profile profile = null;
        Long prid = context.getRequiredParam(RequestContext.PRID);
        if (prid != null) {
            profile = ProfileManager.lookupByIdAndOrg(prid,
                    context.getLoggedInUser().getOrg());
            
            request.setAttribute("profile", profile);
        }

        Map params = new HashMap();
        params.put(RequestContext.PRID, context.getRequiredParam(RequestContext.PRID));
        ListHelper helper = new ListHelper(this, request, params);
        helper.setDataSetName(DATA_SET);
        helper.execute();

        Map forwardParams = new HashMap();
        forwardParams.put(RequestContext.PRID,
                context.getRequiredParam(RequestContext.PRID));

        return getStrutsDelegate().forwardParams(
                actionMapping.findForward(RhnHelper.DEFAULT_FORWARD), forwardParams);
    }

    /** {@inheritDoc} */
    public List getResult(RequestContext context) {
        Long prid = context.getRequiredParam(RequestContext.PRID);
        return ProfileManager.listProfilePackages(prid);
    }
}

