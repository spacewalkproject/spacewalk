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
package com.redhat.rhn.frontend.action.monitoring;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.monitoring.TemplateProbe;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Iterator;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ProbeSuiteListProbesAction - Action to handle removing probes from the suite
 * @version $Rev: 51639 $
 */
public class ProbeSuiteListProbesAction extends RhnSetAction {

    /**
     * Delete probes from the ProbeSuite
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward deleteProbes(ActionMapping mapping,
                                       ActionForm formIn,
                                       HttpServletRequest request,
                                       HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        
        RhnSet selectedProbes = updateSet(request);
        User user = requestContext.getLoggedInUser();
        ProbeSuite suite = requestContext.lookupProbeSuite();
        Iterator i = selectedProbes.getElements().iterator();
        int updatedCount = 0;
        while (i.hasNext()) {
            RhnSetElement element = (RhnSetElement) i.next();
            TemplateProbe probe = (TemplateProbe)
                MonitoringManager.getInstance().lookupProbe(user, element.getElement());
            if (probe != null) {
                MonitoringManager.getInstance().deleteProbe(probe, user);
                updatedCount++;
            }
            i.remove();
        }
        RhnSetManager.store(selectedProbes);
        MonitoringManager.getInstance().storeProbeSuite(suite, user);

        Map params = makeParamMap(formIn, request);
        createSuccessMessage(request, "probes.jsp.probesdeleted",
                new Integer(updatedCount).toString());
        return getStrutsDelegate().forwardParams(mapping.findForward("default"), params);
    }

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User userIn, 
                                       ActionForm formIn, 
                                       HttpServletRequest request) {
        RequestContext rctx = new RequestContext(request);
        ProbeSuite suite = rctx.lookupProbeSuite();
        return (new DataResult(suite.getProbes()));
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("probes.jsp.deleteprobe", "deleteProbes");
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
        return RhnSetDecl.SUITE_PROBES_TO_DELETE;
    }

}
