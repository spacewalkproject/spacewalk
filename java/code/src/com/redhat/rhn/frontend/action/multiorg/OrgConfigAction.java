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
package com.redhat.rhn.frontend.action.multiorg;

import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * OrgDetailsAction extends RhnAction - Class representation of the table
 * web_customer
 * @version $Rev: 1 $
 */
public class OrgConfigAction extends RhnAction {

    /** {@inheritDoc} */
    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response)
    throws Exception {
        RequestContext ctx = new RequestContext(request);
        Org org = ctx.lookupAndBindOrg();
        if (ctx.isSubmitted()) {
            org.setStagingContentEnabled(request.
                    getParameter("staging_content_enabled") != null);
            ActionMessages msg = new ActionMessages();
            msg.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("message.org_name_updated", org.getName()));
            getStrutsDelegate().saveMessages(request, msg);
            return getStrutsDelegate().forwardParam(mapping.findForward("success"),
                    RequestContext.ORG_ID,
                    org.getId().toString());
        }
        return mapping.findForward("default");
    }
}
