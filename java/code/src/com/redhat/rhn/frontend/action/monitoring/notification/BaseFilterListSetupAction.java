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
package com.redhat.rhn.frontend.action.monitoring.notification;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.BaseSetListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

/**
 * BaseFilterListSetupAction - base class for the Active and Expired
 * FilterSetupActions
 * @version $Rev: 55183 $
 */
public abstract class BaseFilterListSetupAction extends BaseSetListAction {
    
    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(RequestContext rctx, PageControl pc) {
        Org org = rctx.getCurrentUser().getOrg();
        DataResult dr = MonitoringManager.
            getInstance().filtersInOrg(org, pc, getActive());
        return dr;
    }
    
    /**
     * Subclass indicates if it wants active or expired filters.
     * @return active or not.
     */
    public abstract boolean getActive();

    /**
     * {@inheritDoc}
     */
    protected void processRequestAttributes(RequestContext rctx) {
        super.processRequestAttributes(rctx);
        rctx.getRequest().setAttribute("allowSelection", Boolean.valueOf(getActive()));
    }

    /**
     * {@inheritDoc}
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.FILTER_EXPIRE;
    }
    
}
