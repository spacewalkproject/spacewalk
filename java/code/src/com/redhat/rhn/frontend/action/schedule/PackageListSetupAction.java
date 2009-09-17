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
package com.redhat.rhn.frontend.action.schedule;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.ActionFormatter;
import com.redhat.rhn.domain.action.ActionType;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.action.ActionManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * PackageListSetupAction
 * @version $Rev$
 */
public class PackageListSetupAction extends RhnAction implements Listable {
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        Long actionId = requestContext.getRequiredParam("aid");
        User user = requestContext.getLoggedInUser();                
        Action action = ActionManager.lookupAction(user, actionId);
        
        
        ActionType type = action.getActionType();
        if (type.equals(ActionFactory.TYPE_PACKAGES_UPDATE) ||
                type.equals(ActionFactory.TYPE_PACKAGES_REMOVE) ||
                type.equals(ActionFactory.TYPE_SOLARISPKGS_INSTALL) ||
                type.equals(ActionFactory.TYPE_SOLARISPKGS_REMOVE)) {
            request.setAttribute("type", "packages");
        }
        else if (type.equals(ActionFactory.TYPE_SOLARISPKGS_PATCHINSTALL) ||
                type.equals(ActionFactory.TYPE_SOLARISPKGS_PATCHREMOVE)) {
            request.setAttribute("type", "patches");
        }
        else if (type.equals(ActionFactory.TYPE_SOLARISPKGS_PATCHCLUSTERINSTALL) ||
                type.equals(ActionFactory.TYPE_SOLARISPKGS_PATCHCLUSTERREMOVE)) {
            request.setAttribute("type", "patchsets");
        }
        

        ListHelper helper = new ListHelper(this, request);
        helper.execute();


        ActionFormatter af = action.getFormatter();
        request.setAttribute("actionname", af.getName());
        request.setAttribute("user", user);
        request.setAttribute("aid", actionId);
        
        return mapping.findForward("default");
    }

    /**
     *
     * {@inheritDoc}
     */
    public List getResult(RequestContext context) {
        Long actionId = context.getParamAsLong("aid");
        return ActionManager.getPackageList(actionId, null);
    }
}
