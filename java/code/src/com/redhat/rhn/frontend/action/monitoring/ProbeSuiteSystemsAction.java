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
package com.redhat.rhn.frontend.action.monitoring;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ProbeSuiteListAction
 * @version $Rev: 51639 $
 */
public class ProbeSuiteSystemsAction extends RhnSetAction {
    
    /**
     * 
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward deleteFromSuite(ActionMapping mapping,
                                       ActionForm formIn,
                                       HttpServletRequest request,
                                       HttpServletResponse response) {
        return operateOnSystems(mapping, formIn, request, 
                "probesuitesystemsedit.jsp.systemsdeleted", true);
        
    }
    
    /**
     * 
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward detachFromSuite(ActionMapping mapping,
                                       ActionForm formIn,
                                       HttpServletRequest request,
                                       HttpServletResponse response) {

        return operateOnSystems(mapping, formIn, request, 
                "probesuitesystemsedit.jsp.systemsdetached", false);
    }

    // Loop over the selected systems and delete or detach
    private ActionForward operateOnSystems(ActionMapping mapping,
                                       ActionForm formIn,
                                       HttpServletRequest request,
                                       String successKey, 
                                       boolean deleteServer) {
        
        RequestContext requestContext = new RequestContext(request);
        
        User user = requestContext.getLoggedInUser();
        Set selectedSystems = updateSet(request).getElements();
        
        ProbeSuite suite = new RequestContext(request).lookupProbeSuite();
        Iterator i = selectedSystems.iterator();
        int updatedCount = 0;
        while (i.hasNext()) {
            RhnSetElement element = (RhnSetElement) i.next();
            Server serverToOperateOn = 
                SystemManager.lookupByIdAndUser(element.getElement(), user);
            if (deleteServer) {
                MonitoringManager.getInstance().
                    removeServerFromSuite(suite, serverToOperateOn, user);
            } 
            else {
                MonitoringManager.getInstance().
                    detatchServerFromSuite(suite, serverToOperateOn, user);
            }
            updatedCount++;
        }
        MonitoringManager.getInstance().storeProbeSuite(suite, user);
        
        Map params = makeParamMap(formIn, request);

        createSuccessMessage(request, successKey, 
                new Integer(updatedCount).toString());
        // Clear the selected set
        getSetDecl().clear(user);
        return getStrutsDelegate().forwardParams(mapping.findForward("default"), params);
    }

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User userIn, 
                                       ActionForm formIn, 
                                       HttpServletRequest request) {
        return ProbeSuiteHelper.getServersInSuite(request, null);
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("probesuitesystems.jsp.removesystem", "deleteFromSuite");
        map.put("probesuitesystems.jsp.detachsystem", "detachFromSuite");
          
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm formIn, 
                                   HttpServletRequest request, 
                                   Map params) {
        ProbeSuiteHelper.processParamMap(request, params);
    }

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.PROBE_SUITE_SYSTEMS;
    }
}
