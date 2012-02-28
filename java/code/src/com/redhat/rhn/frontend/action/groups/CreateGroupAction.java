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

package com.redhat.rhn.frontend.action.groups;

import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.system.ServerGroupManager;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * @author paji
 * @version $Rev$
 */
public class CreateGroupAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm form,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext context = new RequestContext(request);
        User user = context.getLoggedInUser();
        DynaActionForm daForm = (DynaActionForm)form;
        Boolean errors = false;

        if (isSubmitted(daForm)) {
            String name = daForm.getString("name");
            String desc = daForm.getString("description");

            if (StringUtils.isEmpty(name) || StringUtils.isEmpty(desc)) {
                request.setAttribute("emptynameordesc", "1");
                errors = true;
            }

            ManagedServerGroup newGroup = ServerGroupFactory.lookupByNameAndOrg(name,
                    user.getOrg());

            if (newGroup != null) {
                request.setAttribute("alreadyexists", "1");
                errors = true;
            }

            if (!errors) {
                ServerGroupManager manager = ServerGroupManager.getInstance();
                ManagedServerGroup sg = manager.create(user, name, desc);

                createSuccessMessage(request, "systemgroups.create.successmessage", name);

                return mapping.findForward("success");
            }
            request.setAttribute("name", daForm.getString("name"));
            request.setAttribute("description",
                   daForm.getString("description"));

            return mapping.findForward("error");
        }

        return mapping.findForward("default");
    }

}
