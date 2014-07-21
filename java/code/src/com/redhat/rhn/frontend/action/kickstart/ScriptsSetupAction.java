/**
 * Copyright (c) 2009--2013 Red Hat, Inc.
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

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartScript;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.kickstart.KickstartLister;

/**
 * KickstartsSetupAction.
 * @version $Rev: 1 $
 */
public class ScriptsSetupAction extends RhnAction {

    public static final String LIST_NAME = "kickstart_scripts";

    /**
     *
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response) {
        RequestContext rctx = new RequestContext(request);
        Org org = rctx.getCurrentUser().getOrg();
        KickstartData ksdata = KickstartFactory.lookupKickstartDataByIdAndOrg(org,
                rctx.getRequiredParam(RequestContext.KICKSTART_ID));
        DataResult<KickstartScript> dataSet = getDataResult(ksdata.getId(), org);

        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        request.setAttribute(LIST_NAME, dataSet);
        request.setAttribute(RequestContext.KICKSTART, ksdata);

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /**
     *
     * {@inheritDoc}
     */
    protected DataResult<KickstartScript> getDataResult(Long ksid, Org org) {
        return KickstartLister.getInstance().scriptsInKickstartWithFakeEntry(org, ksid);
    }
}
