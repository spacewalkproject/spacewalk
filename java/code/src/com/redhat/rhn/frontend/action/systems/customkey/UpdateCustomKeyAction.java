/**
 * Copyright (c) 2009--2011 Red Hat, Inc.
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
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Handles the deletion of a key.
 */
public class UpdateCustomKeyAction extends RhnAction implements Listable {

    private final String CIKID_PARAM = "cikid";
    private final String LABEL_PARAM = "label";
    private final String DESC_PARAM = "description";
    private final String CREATE_PARAM = "created";
    private final String MODIFY_PARAM = "modified";
    private final String CREATOR_PARAM = "creator";
    private final String MODIFIER_PARAM = "modifier";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext context = new RequestContext(request);
        DynaActionForm form = (DynaActionForm)formIn;
        User loggedInUser  = context.getLoggedInUser();

        Long cikid = context.getParamAsLong(CIKID_PARAM);
        CustomDataKey key = OrgFactory.lookupKeyById(cikid);

        request.setAttribute(CIKID_PARAM, cikid);
        request.setAttribute(LABEL_PARAM, key.getLabel());
        if (context.isSubmitted()) {
            request.setAttribute(DESC_PARAM, request.getParameter(DESC_PARAM));
        }
        else {
            request.setAttribute(DESC_PARAM, key.getDescription());
        }

        request.setAttribute(CREATE_PARAM, key.getCreated());
        request.setAttribute(MODIFY_PARAM, key.getModified());
        request.setAttribute(CREATOR_PARAM, key.getCreator().getLogin());

        if (key.getLastModifier() != null) {
            request.setAttribute(MODIFIER_PARAM, key.getLastModifier().getLogin());
        }
        else {
            request.setAttribute(MODIFIER_PARAM, key.getCreator().getLogin());
        }

        Map params = new HashMap();
        params.put(CIKID_PARAM, cikid);
        ListHelper helper = new ListHelper(this, request, params);
        helper.execute();

        if (context.wasDispatched("system.jsp.customkey.updatebutton")) {

            String description = (String)form.get(DESC_PARAM);
            if (description.length() < 2) {
                createErrorMessage(request, "system.customkey.error.tooshort", null);
                return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
            }

            key.setDescription(description);
            key.setLastModifier(loggedInUser);
            ServerFactory.saveCustomKey(key);
            return mapping.findForward("updated");
        }

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /** {@inheritDoc} **/
    public  List getResult(RequestContext context) {
        User user  = context.getLoggedInUser();
        Long cikid = context.getParamAsLong(CIKID_PARAM);
        List servers = ServerFactory.lookupServersWithCustomKey(user.getId(), cikid);

        return servers;
    }

}
