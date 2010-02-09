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
package com.redhat.rhn.frontend.action.configuration.files;

import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.ActionType;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListDispatchAction;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * GlobalRevisionDeployConfirmSubmit
 * @version $Rev$
 */
public class GlobalRevisionDeployConfirmSubmit extends RhnListDispatchAction {

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(
            ActionForm form, HttpServletRequest request, Map params) {
        ConfigActionHelper.processParamMap(request, params);
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("deployconfirm.jsp.deploybutton", "scheduleDeploy");
    }

    /**
     * Actually schedules a deploy of the specified file, to the specified machines
     * @param mapping structs action-mapping
     * @param form form (it's a date-picker)
     * @param request incoming request
     * @param response outgoing response
     * @return where we're supposed to go next, depending on whether we succeeded or failed
     */
    public ActionForward scheduleDeploy(
            ActionMapping mapping,
            ActionForm form, 
            HttpServletRequest request,
            HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        
        //schedule diff actions
        User user = requestContext.getLoggedInUser();
        ConfigRevision cr = ConfigActionHelper.findRevision(request);
        
        RhnSet systems = RhnSetDecl.CONFIG_FILE_DEPLOY_SYSTEMS.get(user);

        int successes = 0;
        
        Date earliest = getEarliestAction(form);
        
        //create the set needed for the action
        Set revisions = new HashSet();
        revisions.add(cr.getId());
        
        ActionType deploy = ActionFactory.TYPE_CONFIGFILES_DEPLOY;
        
        //go through all of the selected systems
        Iterator itr = systems.getElements().iterator();
        while (itr.hasNext()) {
            // Each server-deploy should succeed or fail on its own merits (?)
            Set servers = new HashSet();
            //the current system
            Long sid = ((RhnSetElement)itr.next()).getElement();
            servers.add(sid);
            //created the action.  One action per server.
            if (revisions.size() > 0 && 
                    ActionManager.createConfigAction(
                            user, revisions, servers, deploy, earliest) != null) {
                successes++;
            }
        }
        
        //create the message
        if (successes > 0) {
            RhnSetManager.remove(systems);
            createSuccessMessage(successes, request, "deployconfirm.jsp");
            Map params = makeParamMap(form, request);
            return getStrutsDelegate().forwardParams(
                    mapping.findForward("success"), params);
        }
        else {
            createFailureMessage(request, "deployconfirm.jsp");
            Map params = makeParamMap(form, request);
            return getStrutsDelegate().forwardParams(
                    mapping.findForward("failure"), params);
        }
    }
    
    private Date getEarliestAction(ActionForm formIn) {
        if (formIn == null) {
            return new Date();
        }
        DynaActionForm form = (DynaActionForm) formIn;
        return getStrutsDelegate().readDatePicker(form, "date",
                DatePicker.YEAR_RANGE_POSITIVE);
    }

    private void createSuccessMessage(int successes, HttpServletRequest request,
            String prefix) {
        ActionMessages msg = new ActionMessages();
        if (successes == 1) {
            msg.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage(prefix + ".success"));
        }
        else {
            msg.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage(prefix + ".successes", new Integer(successes)));
        }
        getStrutsDelegate().saveMessages(request, msg);
    }
    
    private void createFailureMessage(HttpServletRequest request, String prefix) {
        ActionMessages msg = new ActionMessages();
        msg.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage(prefix + ".failure"));
        getStrutsDelegate().saveMessages(request, msg);
    }
}
