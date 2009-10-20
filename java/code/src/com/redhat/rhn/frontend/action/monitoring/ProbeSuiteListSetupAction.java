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
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.monitoring.ProbeSuiteDto;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.BaseSetListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import java.util.Iterator;

/**
 * ProbeSuiteListSetupAction
 * @version $Rev: 55183 $
 */
public class ProbeSuiteListSetupAction extends BaseSetListAction {
    
    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(RequestContext rctx, PageControl pc) {
        User user = rctx.getCurrentUser();
        DataResult result = MonitoringManager.getInstance().listProbeSuites(user, pc);
        boolean containsNonSelectable = false;
        for (Iterator i = result.iterator(); i.hasNext();) {
            ProbeSuiteDto dto = (ProbeSuiteDto) i.next();
            if (!dto.isSelectable()) {
                containsNonSelectable = true;
                break;
            }
        }
        rctx.getRequest().setAttribute("containsNonSelectable", 
                Boolean.valueOf(containsNonSelectable));
        return result;
    }

    /**
     * {@inheritDoc}
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.PROBE_SUITES_TO_DELETE;
    }
}
