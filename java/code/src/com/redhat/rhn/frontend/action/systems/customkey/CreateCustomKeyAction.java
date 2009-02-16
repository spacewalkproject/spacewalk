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
package com.redhat.rhn.frontend.action.systems.customkey;

import com.redhat.rhn.domain.org.CustomDataKey;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
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
 * ChannelPackagesAction
 * @version $Rev$
 */
public class CreateCustomKeyAction extends RhnAction {


    private final String LABEL_PARAM = "label";
    private final String DESC_PARAM = "description";


    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        User user =  requestContext.getLoggedInUser();

        if (requestContext.isSubmitted()) {
            String label = request.getParameter(LABEL_PARAM);
            String description = request.getParameter(DESC_PARAM);


            String error = null;
            // if the key already exists
            if (OrgFactory.lookupKeyByLabelAndOrg(label, user.getOrg()) != null) {
                error = "system.customkey.error.alreadyexists";
            }
            //if the label is too short
            else if (label.length() < 2 || description.length() < 2) {
                error = "system.customkey.error.tooshort";
            }
            if (error != null) {
                request.setAttribute("old_label", label);
                request.setAttribute("old_description", description);
                bindMessage(requestContext, error);
                return mapping.findForward("default");
            }

            CustomDataKey key = new CustomDataKey();
            key.setLabel(label);
            key.setDescription(description);
            key.setCreator(user);
            key.setOrg(user.getOrg());
            key.setLastModifier(user);
            ServerFactory.saveCustomKey(key);
            bindMessage(requestContext, "system.customkey.addsuccess");
            return mapping.findForward("created");
        }

        return mapping.findForward("default");

    }


    private void bindMessage(RequestContext requestContext, String error) {
        ActionMessages msg = new ActionMessages();
        String[] actionParams = {};
        msg.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage(error, actionParams));
        getStrutsDelegate().saveMessages(requestContext.getRequest(), msg);
    }





}
