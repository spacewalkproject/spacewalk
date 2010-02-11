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
import com.redhat.rhn.domain.monitoring.satcluster.SatCluster;
import com.redhat.rhn.domain.monitoring.satcluster.SatClusterFactory;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ProbeSuiteSystemsEditAction - Action to handle adding/removing systems
 * from the ProbeSuite.
 * @version $Rev: 51639 $
 */
public class ProbeSuiteSystemsEditAction extends RhnSetAction {

    /**
     * 
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward addSystems(ActionMapping mapping,
                                       ActionForm formIn,
                                       HttpServletRequest request,
                                       HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        
        User user = requestContext.getLoggedInUser();
        Set selectedSystems = updateSet(request).getElements();
        ProbeSuite suite = requestContext.lookupProbeSuite();
        Iterator i = selectedSystems.iterator();
        while (i.hasNext()) {
            RhnSetElement element = (RhnSetElement) i.next();
            Server serverToAdd = 
                SystemManager.lookupByIdAndUser(element.getElement(), user);
            SatCluster sCluster = 
                lookupSatCluster(request, user);
            MonitoringManager.getInstance().
                addSystemToProbeSuite(suite, serverToAdd, sCluster, user);
        }
        MonitoringManager.getInstance().storeProbeSuite(suite, user);
        ActionMessages msg = new ActionMessages();
        msg.add(ActionMessages.GLOBAL_MESSAGE, 
                new ActionMessage("probesuitesystemsedit.jsp.systemsadded"));

        // Gotta make sure we clear the set now that 
        // we added all the systems to the Suite
        getSetDecl().clear(user);
        
        Map params = makeParamMap(formIn, request);
        strutsDelegate.saveMessages(request, msg);
        return strutsDelegate.forwardParams(mapping.findForward("added"), params);
    }

    // Lookup satcluster from chosen form val
    private SatCluster lookupSatCluster(HttpServletRequest request, User user) {
        String param = request.getParameter("satCluster");
        Long sId = new Long(param);
        SatCluster cluster = SatClusterFactory.findSatClusterById(sId);
        if (cluster != null) {
            return cluster;
        }
        throw new IllegalArgumentException("SatCluster not found in Org, " +
                "something is wrong");
    }

    
    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User userIn, 
                                       ActionForm formIn, 
                                       HttpServletRequest request) {
        RequestContext rctx = new RequestContext(request);
        return ProbeSuiteHelper.getServersNotInSuite(rctx, null);
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("probesuitesystemsedit.jsp.addsystem", "addSystems");
        map.put("probesuitesystemsedit.jsp.search", "search");
          
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
        return RhnSetDecl.PROBE_SUITE_SYSTEMS_EDIT;
    }
}
