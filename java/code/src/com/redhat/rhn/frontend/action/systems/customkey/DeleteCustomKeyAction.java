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
package com.redhat.rhn.frontend.action.systems.customkey;

import com.redhat.rhn.domain.org.CustomDataKey;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Handles the deletion of a key.
 */
public class DeleteCustomKeyAction extends RhnAction {

    private final String CIKID_PARAM = "cikid";
    private final String LABEL_PARAM = "label";
    private final String DESC_PARAM = "description";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        Long cikid = requestContext.getParamAsLong(CIKID_PARAM);

        CustomDataKey key = OrgFactory.lookupKeyById(cikid);

        String label = key.getLabel();
        String desc  = key.getDescription();

        request.setAttribute(CIKID_PARAM, cikid);
        request.setAttribute(LABEL_PARAM, label);
        request.setAttribute(DESC_PARAM, desc);

        if (requestContext.isSubmitted()) {
            ServerFactory.removeCustomKey(key);

            bindMessage(requestContext, "system.customkey.deletesuccess");
            return mapping.findForward("deleted");
        }

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    private void bindMessage(RequestContext requestContext, String error) {
        ActionMessages msg = new ActionMessages();
        String[] actionParams = {};
        msg.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage(error, actionParams));
        getStrutsDelegate().saveMessages(requestContext.getRequest(), msg);
    }

}
