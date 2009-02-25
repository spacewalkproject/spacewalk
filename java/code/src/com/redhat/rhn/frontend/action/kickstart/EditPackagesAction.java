/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnpackage.PackageName;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.kickstart.KickstartEditCommand;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.StringTokenizer;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Manages displaying/updating package names 
 * associated with Kickstarts
 * 
 * @version $Rev $
 */
public class EditPackagesAction extends RhnAction {
    
    private static final String PACKAGE_LIST = "packageList";
    
    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, 
            ActionForm form, 
            HttpServletRequest request, 
            HttpServletResponse response) throws Exception {
        DynaActionForm dynaForm = (DynaActionForm) form;
        RequestContext ctx = new RequestContext(request);
        KickstartEditCommand cmd = new KickstartEditCommand(
                ctx.getRequiredParam(RequestContext.KICKSTART_ID),
                ctx.getCurrentUser());
        KickstartData ksdata = cmd.getKickstartData();  
        request.setAttribute(RequestContext.KICKSTART, ksdata);
        if (isSubmitted(dynaForm)) {
            ActionForward returnForward = save(mapping, dynaForm, request, response, 
                    ctx, ksdata);
            addMessage(request, "kickstart.edit.pkgs.updated");
            return returnForward;
        }
        else {
            return display(mapping, dynaForm, request, response, ctx, ksdata);
        }
    }
    
    /**
     * Handles form submission and database update
     * @param mapping from Struts
     * @param form from Struts
     * @param request from Struts
     * @param response from Struts
     * @param ctx RequestContext corresponding to the request
     * @param ksdata KickstartData 
     * @return pointer to jsp page
     * @throws Exception signalling error
     */
    public ActionForward save(ActionMapping mapping, 
            DynaActionForm form, 
            HttpServletRequest request, 
            HttpServletResponse response,
            RequestContext ctx,
            KickstartData ksdata) throws Exception {
        transferEdits(ksdata, form,  ctx);
        StringBuffer redirectUrl = new StringBuffer();
        redirectUrl.append(request.getContextPath());
        redirectUrl.append(mapping.getPath());
        redirectUrl.append(".do?ksid=").append(form.get("ksid"));
        response.sendRedirect(redirectUrl.toString());
        return null;
    }

    /**
     * Handles display
     * @param mapping from Struts
     * @param form from Struts
     * @param request from Struts
     * @param response from Struts
     * @param ctx RequestContext corresponding to the request
     * @param ksdata KickstartData 
     * @return pointer to jsp page
     * @throws Exception signalling error
     */
    public ActionForward display(ActionMapping mapping, 
            DynaActionForm form, 
            HttpServletRequest request, 
            HttpServletResponse response,
            RequestContext ctx,
            KickstartData ksdata) throws Exception {
        prepareForm(ksdata, form);
        return mapping.findForward("display");
    }
    
    private void prepareForm(KickstartData ksdata, DynaActionForm form) {
        List packageNames = ksdata.getPackageNames();
        if (packageNames != null && packageNames.size() > 0) {
            StringBuffer buf = new StringBuffer();
            StringBuffer buf2 = new StringBuffer();
            int i = 0;
            for (Iterator iter = packageNames.iterator(); iter.hasNext();) {
                PackageName pn = (PackageName) iter.next();
                buf.append(pn.getName());
                buf.append("\n");
                i++;
            }
            form.set(PACKAGE_LIST, buf.toString());
        }
        form.set("submitted", Boolean.TRUE);
    }
    
    private void transferEdits(KickstartData ksdata, DynaActionForm form, 
            RequestContext ctx) {
        List packageNames = ksdata.getPackageNames();
        if (packageNames == null) {
            packageNames = new ArrayList();
            ksdata.setPackageNames(packageNames);
        }
        packageNames.clear();
        String newPackages = form.getString(PACKAGE_LIST);
        if (newPackages != null && newPackages.length() > 0) {
            for (StringTokenizer strtok = new StringTokenizer(newPackages, "\n");
                    strtok.hasMoreTokens();) {
                String pkg = strtok.nextToken();
                pkg = pkg.trim();
                if (pkg.length() == 0) {
                    continue;
                }
                PackageName pn = PackageFactory.lookupOrCreatePackageByName(pkg);
                packageNames.add(pn);
            }
        }
        KickstartFactory.saveKickstartData(ksdata);
    }
}
