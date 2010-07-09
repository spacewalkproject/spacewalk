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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.frontend.struts.BaseSetListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.acl.AclManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Iterator;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * BaseKickstartListSetupAction - base class for Kickstart Details list pages that show
 * a list of items to associate with the kickstart.
 *
 * @version $Rev: 76571 $
 */
public abstract class BaseKickstartListSetupAction extends BaseSetListAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {

        if (!AclManager.hasAcl("user_role(org_admin) or user_role(config_admin)",
            request, null)) {
            //Throw an exception with a nice error message so the user
            //knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex =
                new PermissionException(
                    "Only Org Admins or Configuration Admins can list kickstarts");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.summary.acl.header"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.acl.reason5"));
            throw pex;
        }

        return super.execute(mapping, formIn, request, response);
    }
    /**
     * {@inheritDoc}
     */
    protected void processForm(RequestContext rctx, ActionForm form) {
        super.processForm(rctx, form);
        KickstartData ksdata = KickstartFactory
            .lookupKickstartDataByIdAndOrg(rctx.getCurrentUser().getOrg(),
                    rctx.getRequiredParam(RequestContext.KICKSTART_ID));
        rctx.getRequest().setAttribute(RequestContext.KICKSTART, ksdata);

        if (!rctx.isSubmitted()) {
            populateNewSet(rctx, getCurrentItemsIterator(ksdata));
        }
    }

    /**
     * Get the Iterator for a Collection of Objects
     * that implement the Identifiable interface.
     * @param ksdata KickstartData to fetch info from
     * @return Iterator containing Identifiable objects.
     */
    protected abstract Iterator getCurrentItemsIterator(KickstartData ksdata);


}
