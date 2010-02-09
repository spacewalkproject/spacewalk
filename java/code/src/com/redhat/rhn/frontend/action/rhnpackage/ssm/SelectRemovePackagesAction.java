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
package com.redhat.rhn.frontend.action.rhnpackage.ssm;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListSessionSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.rhnpackage.PackageManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Handles listing and selecting a number of packages to remove from systems in the SSM.
 *
 * @version $Revision$
 */
public class SelectRemovePackagesAction extends RhnAction implements Listable {

    private static final String DATA_SET = "pageList";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping actionMapping,
                                 ActionForm actionForm,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws Exception {
        request.setAttribute("parentUrl", request.getRequestURI());

        Map params = new HashMap();

        ListSessionSetHelper helper = new ListSessionSetHelper(this, request, params);
        helper.setDataSetName(DATA_SET);
        helper.execute();

        if (helper.isDispatched()) {
            request.setAttribute("packagesDecl", helper.getDecl());
            return actionMapping.findForward("confirm");
        }

        return actionMapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /** {@inheritDoc} */
    public List getResult(RequestContext context) {
        User user = context.getLoggedInUser();
        DataResult result = PackageManager.packagesFromServerSet(user);

        return result;
    }
}
