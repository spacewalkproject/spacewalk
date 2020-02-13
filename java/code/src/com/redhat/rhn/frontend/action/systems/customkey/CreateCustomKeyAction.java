/**
 * Copyright (c) 2009--2018 Red Hat, Inc.
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

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import com.redhat.rhn.domain.org.CustomDataKey;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;

/**
 * Handles the validation of custom system info key data and the creation of the keys.
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
        User user =  requestContext.getCurrentUser();

        if (requestContext.isSubmitted()) {
            String label = request.getParameter(LABEL_PARAM);
            String description = request.getParameter(DESC_PARAM);

            ActionErrors errors = validateLabelAndDescription(label, description, user);
            if (!errors.isEmpty()) {
                request.setAttribute("old_label", label);
                request.setAttribute("old_description", description);
                addErrors(request, errors);
                return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
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

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    private void bindMessage(RequestContext requestContext, String error) {
        ActionMessages msg = new ActionMessages();
        String[] actionParams = {};
        msg.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage(error, actionParams));
        getStrutsDelegate().saveMessages(requestContext.getRequest(), msg);
    }

    /**
     * Validates the user specified label and descriptions are acceptable values.
     *
     * @param label       label given to the new key
     * @param description description of the key
     * @param user        user creating the key
     * @return message key corresponding to the validation error if one was encountered;
     *         <code>null</code> if the values are valid
     */
    private ActionErrors validateLabelAndDescription(String label,
                    String description,
                    User user) {
        /* Validation proceeds according to the following:

           I.  Key does not already exist; do not allow duplicate keys
          II.  Label is at least 2 characters long
         III.  Description is at least 2 characters long
          IV.  Label only contains valid characters (these need to match what is allowed
               in a macro argument)
           V.  Label is shorter/equal than 64
          VI.  Description is shorter/equal than 4000

          It is possible to fall into more than one of these states at the same time -
          return all the errors we can at once
         */

        ActionErrors errors = new ActionErrors();

        // I
        if (OrgFactory.lookupKeyByLabelAndOrg(label, user.getOrg()) != null) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                       new ActionMessage("system.customkey.error.alreadyexists"));
        }

        // II, III
        if (label == null || label.length() < 2 || description.length() < 2) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                            new ActionMessage("system.customkey.error.tooshort"));
        }

        // IV
        if (!label.trim().matches("[\\w-]*")) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                            new ActionMessage("system.customkey.error.invalid"));
        }

        // V
        if (label.length() > 64) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                            new ActionMessage("system.customkey.error.toolong"));
        }

        // VI
        if (description.length() > 4000) {
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                            new ActionMessage("system.customkey.error.descr_toolong"));
        }

        return errors;
    }

}
