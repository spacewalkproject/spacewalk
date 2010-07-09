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
package com.redhat.rhn.frontend.action.errata;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ListPackagesSetupAction
 * @version $Rev$
 */
public class ListPackagesSetupAction extends BaseErrataSetupAction {

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);

        //Get the errata from the eid in the request
        Errata errata = requestContext.lookupErratum();
        //Get the logged in user
        User user = requestContext.getLoggedInUser();



        //Setup the page control for this user
        PageControl pc = new PageControl();
        pc.setIndexData(true);
        pc.setFilterColumn("package_nvre");
        pc.setFilter(true);
        clampListBounds(pc, request, user);

        DataResult dr = PackageManager.packagesInErrata(errata, pc);

        RhnSet set = RhnSetDecl.PACKAGES_TO_REMOVE.get(user);
        request.setAttribute("pageList", dr);
        request.setAttribute("set", set);

       if (!requestContext.isSubmitted()) {
            set.clear();
            RhnSetFactory.save(set);
        }

        return super.execute(mapping, formIn, request, response);
    }
}
