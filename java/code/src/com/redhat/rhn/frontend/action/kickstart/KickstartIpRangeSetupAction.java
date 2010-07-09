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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.kickstart.KickstartLister;
import com.redhat.rhn.manager.kickstart.KickstartUrlHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.net.MalformedURLException;
import java.net.URL;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * KickstartsSetupAction.
 * @version $Rev: 1 $
 */
public class KickstartIpRangeSetupAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        User user =  requestContext.getLoggedInUser();

        String urlStr;
        try {
            URL url = new URL(
                    requestContext.getRequest().getRequestURL().toString());
            urlStr = "ks=" +
            KickstartUrlHelper.getKickstartFileUrlIpRange(user.getOrg(),
                    url.getHost(), url.getProtocol());
        }
        catch (MalformedURLException e) {
            throw new IllegalArgumentException("Bad argument when creating URL for " +
                    "Kickstart IP Ranges");
        }
        String urlRange =
            LocalizationService.getInstance().getMessage("kickstart.iprange.url", urlStr);
        request.setAttribute("urlrange", urlRange);

        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());

        request.setAttribute("pageList", getDataResult(requestContext, null));

        return mapping.findForward("default");

    }


    /**
     *
     * {@inheritDoc}
     */
    protected DataResult getDataResult(RequestContext rctx, PageControl pc) {
        Org org = rctx.getCurrentUser().getOrg();
        return KickstartLister.getInstance().kickstartIpRangesInOrg(org, pc);
    }

    /**
     *
     * @return the kickstart profile security label
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.KICSKTART_IPRANGES;
    }

}
