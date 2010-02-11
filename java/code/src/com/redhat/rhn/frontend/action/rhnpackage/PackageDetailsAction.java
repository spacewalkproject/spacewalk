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
package com.redhat.rhn.frontend.action.rhnpackage;

import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnpackage.PackageSource;
import com.redhat.rhn.domain.rhnpackage.Patch;
import com.redhat.rhn.domain.rhnpackage.PatchSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.xmlrpc.NoSuchPackageException;
import com.redhat.rhn.manager.download.DownloadManager;
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
 * ChannelPackagesAction
 * @version $Rev$
 */
public class PackageDetailsAction extends RhnAction {

    private final String PACKAGE_NAME = "package_name";
    private final String PACKAGE_KEY = "package_key";
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getLoggedInUser();

        //If this is an easy one and we have the pid
        if (request.getParameter("pid") != null) {
            long pid = requestContext.getRequiredParam("pid");
            Package pkg = PackageFactory.lookupByIdAndUser(pid, user);

            // show permission error if pid is invalid like we did before
            if (pkg == null) {
                throw new PermissionException("Invalid pid");
            }

            if (pkg instanceof Patch) {
                request.setAttribute("type", "patch");
                request.setAttribute(PACKAGE_NAME, pkg.getPackageName().getName());
                request.setAttribute("readme_url",
                        DownloadManager.getPatchReadmeDownloadPath(
                                (Patch) pkg, user));
            }
            else if (pkg instanceof PatchSet) {
                request.setAttribute("type", "patchset");
                request.setAttribute(PACKAGE_NAME, pkg.getNameEvra());
                request.setAttribute("readme_url",
                        DownloadManager.getPatchSetReadmeDownloadPath(
                                (PatchSet) pkg, user));
            }
            else {
                request.setAttribute("type", "rpm");
                request.setAttribute(PACKAGE_NAME, pkg.getFilename());
                if (!pkg.getPackageKeys().isEmpty()) {
                    request.setAttribute(PACKAGE_KEY,
                            pkg.getPackageKeys().iterator().next().getKey());
                }
            }

            if (DownloadManager.isFileAvailable(pkg.getPath())) {
                request.setAttribute("url",
                        DownloadManager.getPackageDownloadPath(pkg, user));
            }

            List<PackageSource> src = PackageFactory.lookupPackageSources(pkg);

            if (!src.isEmpty() && DownloadManager.isFileAvailable(src.get(0).getPath())) {
                request.setAttribute("srpm_url",
                   DownloadManager.getPackageSourceDownloadPath(pkg, src.get(0), user));
                request.setAttribute("srpm_path", src.get(0).getFile());
            }

            request.setAttribute("pack", pkg);
            // description can be null.
            if (pkg.getDescription() != null) {
                request.setAttribute("description",
                        pkg.getDescription().replace("\n", "<BR>\n"));
            }
            else {
                request.setAttribute("description",
                        pkg.getDescription());
            }
            request.setAttribute("packArches",
                    PackageFactory.findPackagesWithDifferentArch(pkg));
            request.setAttribute("pid", pid);

            return mapping.findForward("default");
        }
        else { //we have to guess
            PackageListItem item = PackageListItem.parse(request.getParameter("id_combo"));
            Package pkg;
            long nameId = item.getIdOne();
            long evrId = item.getIdTwo();
            long archId = 0;
            if (item.getIdThree() != null) {
                archId = item.getIdThree();
            }
           
            Long cid = requestContext.getParamAsLong("cid");
            Long sid = requestContext.getParamAsLong("sid");
            if (cid != null) {
                pkg = PackageManager.guestimatePackageByChannel(
                   cid, nameId, evrId, user.getOrg());
                
            }
            else if (sid != null) {
                pkg = PackageManager.guestimatePackageBySystem(
                   sid, nameId, evrId, archId, user.getOrg());
                
            }
            else {
                throw new BadParameterException("pid, cid, or sid");
            }

            // show permission error if pid is invalid like we did before
            if (pkg == null) {
                throw new NoSuchPackageException();
            }
            
            Map params = new HashMap();
            params.put("pid", pkg.getId());
            return getStrutsDelegate().forwardParams(mapping.findForward("package"),
                    params);
        }
    }
}

