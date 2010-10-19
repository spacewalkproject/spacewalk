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
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.helper.ListSessionSetHelper;
import com.redhat.rhn.manager.system.ServerGroupManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

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
        ActionErrors errors = new ActionErrors();

//        Map params = new HashMap();
//        StrutsDelegate strutsDelegate = getStrutsDelegate();

        if (isSubmitted(daForm)) {
//        if (isSubmitted(daForm) && request.getParameter("dispatch") != null) {
System.out.println("submitted");
            String name = daForm.getString("name");
            String desc = daForm.getString("description");

            if (name.equals("") || name == null || desc.equals("") || desc == null) {
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("create.group.emptynameordesc"));
            }

            ServerGroupManager manager = ServerGroupManager.getInstance();
//            ManagedServerGroup newGroup = manager.lookup(name, user);
            ManagedServerGroup newGroup = ServerGroupFactory.lookupByNameAndOrg(name, user.getOrg());

            if (newGroup != null) {
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("create.group.alreadyexists"));
            }

            if (errors.isEmpty()) {
System.out.println("no errors");
                ManagedServerGroup sg = manager.create(user, name, desc);

//                return strutsDelegate.forwardParams (mapping.findForward("success"),
//                        params);
                  return mapping.findForward("success");
            }
            else {
System.out.println("have errors");
                request.setAttribute("name", (String) daForm.getString("name"));
                request.setAttribute("description", (String) daForm.getString("desc"));

//                return strutsDelegate.forwardParams (mapping.findForward("error"),
//                        params);
                return mapping.findForward("error");
            }
        }

System.out.println("forwarding to default");
//        return strutsDelegate.forwardParams (mapping.findForward("default"), params);
        return mapping.findForward("default");
    }

}
