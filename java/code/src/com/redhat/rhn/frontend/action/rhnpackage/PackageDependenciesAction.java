/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.rhnpackage;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.rhnpackage.PackageManager;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * PackageDependenciesAction
 * @version $Rev$
 */
public class PackageDependenciesAction extends RhnAction {

    private List<String> createDependenciesStrings(DataResult dr) {

        if (dr == null || dr.isEmpty()) {
            return null;
        }

        List<String> lines = new ArrayList<String>();

        // Loop through all items in data result
        for (Iterator resultItr = dr.iterator(); resultItr.hasNext();) {
            Map item = (Map) resultItr.next();

            String name = (String) item.get("name");
            String version = (String) item.get("version");
            Long sense = (Long) item.get("sense");

            String line = name;
            if (version != null) {
                line += " ";
                line += PackageManager.getDependencyModifier(sense, version);
            }

            lines.add(StringEscapeUtils.escapeHtml(line));
        }

        return lines;
    }

    /** {@inheritDoc} */
    @Override
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getCurrentUser();

        long pid = requestContext.getRequiredParam("pid");
        Package pkg = PackageFactory.lookupByIdAndUser(pid, user);

        // show permission error if pid is invalid like we did before
        if (pkg == null) {
            throw new PermissionException("Invalid pid");
        }

        request.setAttribute("requires", createDependenciesStrings(
                PackageManager.packageRequires(pid)));
        request.setAttribute("provides", createDependenciesStrings(
                PackageManager.packageProvides(pid)));
        request.setAttribute("obsoletes", createDependenciesStrings(
                PackageManager.packageObsoletes(pid)));
        request.setAttribute("conflicts", createDependenciesStrings(
                PackageManager.packageConflicts(pid)));
        request.setAttribute("recommends", createDependenciesStrings(
                PackageManager.packageRecommends(pid)));
        request.setAttribute("suggests", createDependenciesStrings(
                PackageManager.packageSuggests(pid)));
        request.setAttribute("supplements", createDependenciesStrings(
                PackageManager.packageSupplements(pid)));
        request.setAttribute("enhances", createDependenciesStrings(
                PackageManager.packageEnhances(pid)));

        request.setAttribute("pid", pid);
        request.setAttribute("package_name", pkg.getFilename());
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);

    }
}
