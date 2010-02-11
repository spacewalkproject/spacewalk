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
import com.redhat.rhn.domain.monitoring.satcluster.SatClusterFactory;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.BaseSetListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

/**
 * ProbeSuiteSystemsEditSetupAction - lists systems that we *can* add to a 
 * ServerProbe Suite. Only monitoring entitled systems included in this list.
 * @version $Rev: 55183 $
 */
public class ProbeSuiteSystemsEditSetupAction extends BaseSetListAction {
    
    /**
     * Check to make sure this Suite has probes assigned, of not, bounce back
     * {@inheritDoc}
     */
    protected String checkPreConditions(RequestContext rctx) {
        ProbeSuite suite = rctx.lookupProbeSuite();
        if (suite.getProbes().size() == 0) {
            rctx.getRequest().setAttribute("probeSuite", suite);
            return "probesuitesystemsedit.jsp.addprobesfirst";
        } 
        else {
            return null;
        }
    }

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(RequestContext rctx, PageControl pc) {
        
        rctx.getRequest().setAttribute("satClusters", 
                SatClusterFactory.findSatClusters());
        
        User u = rctx.getCurrentUser();
        setupPageControl(pc);
        DataResult retval = MonitoringManager.getInstance().
            systemsNotInSuite(u, rctx.lookupProbeSuite(), pc);
        return retval;
    }
    
    /**
     * Set the values for the PageControl:
     * size: 10
     * filter; true
     * index: false
     * filter column: name
     * @param pc we want to setup
     */
    protected void setupPageControl(PageControl pc) {
        pc.setPageSize(10);
        pc.setFilter(true);
        pc.setIndexData(false);
        pc.setFilterColumn("name");
    }

    /**
     * {@inheritDoc}
     */
    protected void processRequestAttributes(RequestContext rctx) {
        super.processRequestAttributes(rctx);
        ProbeSuite probeSuite = rctx.lookupProbeSuite();
        rctx.getRequest().setAttribute("probeSuite", probeSuite);
    }

    /**
     * {@inheritDoc}
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.PROBE_SUITE_SYSTEMS_EDIT;
    }
}
