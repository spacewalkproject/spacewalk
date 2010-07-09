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
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BaseSetOperateOnSelectedItemsAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.monitoring.ModifyFilterCommand;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;

/**
 * FilterListAction - expire the filters
 * @version $Rev: 51639 $
 */
public class FilterListAction extends BaseSetOperateOnSelectedItemsAction {


    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User userIn,
                                       ActionForm formIn,
                                       HttpServletRequest request) {
        RequestContext rctx = new RequestContext(request);
        Org org = rctx.getCurrentUser().getOrg();
        // We only have "select all" on the Active list so we can just
        // pass in true here
        return MonitoringManager.getInstance().filtersInOrg(org, null, true);
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("filters.jsp.expirefilters", "operateOnSelectedSet");
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm formIn,
                                   HttpServletRequest request,
                                   Map params) {
        // no-op
    }

    /**
     * Expire the Filter
     * {@inheritDoc}
     */
    public Boolean operateOnElement(ActionForm form,
                                    HttpServletRequest request,
                                    RhnSetElement elementIn,
                                    User userIn) {
        ModifyFilterCommand cmd = new ModifyFilterCommand(elementIn.getElement(),
                userIn);
        cmd.expireFilter();
        cmd.storeFilter();
        return Boolean.TRUE;
    }

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.FILTER_EXPIRE;
    }
}
