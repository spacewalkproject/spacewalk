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
package com.redhat.rhn.frontend.action.systems;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.VirtualSystemOverview;
import com.redhat.rhn.frontend.filter.TreeFilter;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;

import java.util.Iterator;

import javax.servlet.http.HttpServletRequest;

/**
 * VirtualSystemsListSetupAction
 * @version $Rev$
 */
public class VirtualSystemsListSetupAction extends BaseSystemListSetupAction {

    /**
     * Sets the status and entitlementLevel variables of each System Overview
     * @param dr The list of System Overviews
     * @param user The user viewing the System List
     */
    public void setStatusDisplay(DataResult dr, User user) {
        Iterator i = dr.iterator();

        while (i.hasNext()) {

            VirtualSystemOverview next = (VirtualSystemOverview) i.next();

            // If the system is not registered with RHN, we cannot show a status
            if (next.getSystemId() != null) {
                Long instanceId = next.getId();
                next.setId(next.getSystemId());
                SystemListHelper.setSystemStatusDisplay(user, next);
                next.setId(instanceId);
            }
        }
    }

    protected DataResult getDataResult(User user, PageControl pc, ActionForm formIn) {
        DataResult dr = SystemManager.virtualSystemsList(user, pc);

        for (int i = 0; i < dr.size(); i++) {
            VirtualSystemOverview current = (VirtualSystemOverview) dr.get(i);
            if (current.getUuid() == null) {
                current.setSystemId(current.getHostSystemId());
            }
            else {
                current.setSystemId(current.getVirtualSystemId());

                // If we do not know the host for a virtual system,
                // insert a 'fake' system into the list before the
                // current one.

                if (current.getHostSystemId() == null) {
                    VirtualSystemOverview fakeSystem = new VirtualSystemOverview();
                    fakeSystem.setServerName("(Unknown Host)");
                    fakeSystem.setHostSystemId(new Long("0"));
                    dr.add(i, fakeSystem);
                    i++;
                }
            }
        }

        return dr;
    }

    /**
     *
     * {@inheritDoc}
     */
    public void clampListBounds(PageControl pc,
                                HttpServletRequest request,
                                    User viewer) {
       TreeFilter filter = new TreeFilter();
       filter.setMatcher(new VirtualSystemsFilterMatcher());
       pc.setCustomFilter(filter);
       super.clampListBounds(pc, request, viewer);
    }

}
