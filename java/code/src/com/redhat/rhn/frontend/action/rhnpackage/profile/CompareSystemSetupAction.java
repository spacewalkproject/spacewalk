/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.rhnpackage.profile;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.BaseSetListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.profile.ProfileManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * CompareSystemSetupAction
 * @version $Rev$
 */
public class CompareSystemSetupAction extends BaseSetListAction {

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(RequestContext requestContext, PageControl pc) {
        
        Long sid = requestContext.getRequiredParam("sid");
        Long sid1 = requestContext.getRequiredParam("sid_1");
        
        DataResult dr = ProfileManager.compareServerToServer(sid,
                sid1, requestContext.getCurrentUser().getOrg().getId(), pc);
        
        return dr;
    }

    /**
     * {@inheritDoc}
     */
    protected void processRequestAttributes(RequestContext requestContext) {
        super.processRequestAttributes(requestContext);
        Long sid1 = requestContext.getRequiredParam("sid_1");
        
        requestContext.lookupAndBindServer();
        Server server1 = SystemManager.lookupByIdAndUser(sid1,
                requestContext.getCurrentUser());
        requestContext.getRequest().setAttribute("systemname", server1.getName());
    }

    /**
     * {@inheritDoc}
     */
    protected void processPageControl(PageControl pc) {
        pc.setIndexData(true);
        pc.setFilterColumn("name");
        pc.setFilter(true);
    }

    /**
     * {@inheritDoc}
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.PACKAGES_FOR_SYSTEM_SYNC;
    }

}
