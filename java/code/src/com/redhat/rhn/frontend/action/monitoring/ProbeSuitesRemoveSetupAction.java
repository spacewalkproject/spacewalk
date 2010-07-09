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
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.BaseSetListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * ProbeSuiteListSetupAction
 * @version $Rev: 55183 $
 */
public class ProbeSuitesRemoveSetupAction extends BaseSetListAction {

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(RequestContext rctx, PageControl pc) {

        RhnSet set = getSetDecl().get(rctx.getCurrentUser());
        List selectedSuites = new LinkedList();
        Iterator i = set.getElements().iterator();
        while (i.hasNext()) {
            RhnSetElement elem = (RhnSetElement) i.next();
            ProbeSuite suite = MonitoringManager.getInstance().
                lookupProbeSuite(elem.getElement(), rctx.getCurrentUser());
            Map suiteRow = new HashMap();
            suiteRow.put("suite_name", suite.getSuiteName());
            suiteRow.put("suite_id", suite.getId());
            selectedSuites.add(suiteRow);
        }
        DataResult retval = new DataResult(selectedSuites);
        return retval;
    }

    /**
     * {@inheritDoc}
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.PROBE_SUITES_TO_DELETE;
    }

    /** {@inheritDoc} */
    protected boolean preClearSet() {
        return false;
    }

}
