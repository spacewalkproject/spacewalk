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
package com.redhat.rhn.frontend.action;

import com.redhat.rhn.common.db.ConstraintViolationException;
import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.domain.user.legacy.LegacyRhnUserImpl;
import com.redhat.rhn.frontend.events.UpdateErrataCacheEvent;
import com.redhat.rhn.frontend.servlets.PxtSessionDelegate;
import com.redhat.rhn.frontend.servlets.PxtSessionDelegateFactory;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.satellite.CertificateManager;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.commons.lang.time.StopWatch;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.io.IOException;

import javax.security.auth.login.LoginException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * LoginAction
 * @version $Rev$
 */
public class SwitchOrgsAction extends RhnAction {
    
    private static Logger log = Logger.getLogger(SwitchOrgsAction.class);
    public static final String DEFAULT_URL_BOUNCE = "/rhn/YourRhn.do";
    
    // It is OK to maintain a PxtSessionDelegate instance because PxtSessionDelegate
    // objects do not maintain client state.
    private PxtSessionDelegate pxtDelegate;
    
    /**
     * Initialize the action.
     */
    public SwitchOrgsAction() {
        PxtSessionDelegateFactory pxtDelegateFactory = 
            PxtSessionDelegateFactory.getInstance();
        
        pxtDelegate = pxtDelegateFactory.newPxtSessionDelegate();
    }
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm form, HttpServletRequest request,
            HttpServletResponse response) {
    
       RequestContext ctx = new RequestContext(request);
       User oldUser = ctx.getLoggedInUser();
       
       Long oid = Long.parseLong(request.getParameter("selected_org"));
       
       Org newOrg = OrgFactory.lookupById(oid);
       
       if (!oldUser.getUserOrgs().contains(newOrg)) {
         throw new PermissionException("BLAH");   
       }
       User user = UserFactory.getInstance().lookupUserForOrg(newOrg, oldUser.getLogin());
        
        pxtDelegate.updateWebUserId(request, response, user.getId());
        
        return mapping.findForward("default");
    }
    
    
    
}
