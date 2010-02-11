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
package com.redhat.rhn.frontend.action.user;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.security.user.StateChangeException;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.UserOverview;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.Collections;
import java.util.Iterator;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * EnableConfirmSetupAction
 * @version $Rev$
 */
public class EnableConfirmSetupAction extends RhnListAction {
    
    public static final String DISPATCH = "dispatch";
    public static final String LIST_NAME = "userConfirmList";
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getLoggedInUser();
        if (!user.hasRole(RoleFactory.ORG_ADMIN)) {
            //Throw an exception with a nice error message so the user
            //knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex =
                new PermissionException("Only org admin's can reactivate users");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.enableuser"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.enableuser"));
            throw pex;
        }
        
        RhnListSetHelper helper = new RhnListSetHelper(request);
        RhnSet set = getDecl().get(user);
        
        if (request.getParameter(DISPATCH) != null) {
            // if its one of the Dispatch actions handle it..            
            helper.updateSet(set, LIST_NAME);
            if (!set.isEmpty()) {
                return handleDispatchAction(mapping, requestContext);
            }
            else {
                RhnHelper.handleEmptySelection(request);
            }
        }    
        
        
        PageControl pc = new PageControl();

        clampListBounds(pc, request, user);
        DataResult dr = UserManager.usersInSet(user, "user_list", pc);
        dr.setElaborationParams(Collections.EMPTY_MAP);
        request.setAttribute("pageList", dr);
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        
        return mapping.findForward("default");
    }
    
    /**
     * Handles a dispatch action
     * Could be One of copy_to_sandbox,
     * copy_to_local, copy_to_global
     * &amp; delete_files
     * @param mapping the action mapping used for returning 'forward' url
     * @param context the request context
     * @return the forward url
     */
    private ActionForward handleDispatchAction(ActionMapping mapping, 
                                               RequestContext context) {
        
        User user = context.getLoggedInUser();
        HttpServletRequest request = context.getRequest();
        // don't need the result, but we do need this to run.
        getDecl().get(user);
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        
        if (!user.hasRole(RoleFactory.ORG_ADMIN)) {
            //Throw an exception with a nice error message so the user
            //knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex =
                new PermissionException("Only org admin's can reactivate users");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.enableuser"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.enableuser"));
            throw pex;
        }
        
        Iterator users = UserManager.usersInSet(user, "user_list", null).iterator();
        ActionErrors errors = new ActionErrors();
        int count = 0;
        
        while (users.hasNext()) {
            long id = ((UserOverview) users.next()).getId().longValue();
            User nextUser = UserManager.lookupUser(user, new Long(id));
            try {
                 UserManager.enableUser(user, nextUser);
                 count++;
                 }
            catch (StateChangeException e) {
                errors.add(ActionMessages.GLOBAL_MESSAGE, 
                        new ActionMessage(e.getMessage(), nextUser.getLogin()));
            }
        }
        
        RhnSetDecl.USERS.clear(user);
        
        ActionMessages msg = new ActionMessages();
        StringBuffer messageKey = new StringBuffer("enable.confirmed");
        if (count > 1) {
            messageKey = messageKey.append(".plural");
        }
        
        msg.add(ActionMessages.GLOBAL_MESSAGE, 
                new ActionMessage(messageKey.toString(), new Integer(count)));
        strutsDelegate.saveMessages(request, msg);
        
        if (errors.isEmpty()) {
            return mapping.findForward("enabled");
        }
        
        addErrors(request, errors);
        return strutsDelegate.forwardParams(mapping.findForward("default"),
                                       makeParamMap(request));
        
        
    }
    
    /**
     * 
     * @return the set declaration used to this action.. 
     */
    protected RhnSetDecl getDecl() {
        return RhnSetDecl.USERS;
    }

}
