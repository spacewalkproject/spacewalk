/**
 * Copyright (c) 2009--2013 Red Hat, Inc.
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

import java.util.HashMap;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.dto.VirtualSystemOverview;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;

/**
 * VirtualSystemSetupAction
 * @version $Rev$
 */
public class VirtualSystemSetupAction extends BaseSystemsAction {

    protected DataResult<SystemOverview> getDataResult(User user, PageControl pc,
            ActionForm formIn) {
        DataResult<SystemOverview> systems = SystemManager.systemList(user, pc);
        HashMap<Long, SystemOverview> systemMap = new HashMap<>();
        for (SystemOverview sys: systems) {
            systemMap.put(sys.getId(), sys);
        }
        DataResult<VirtualSystemOverview> dr = SystemManager.virtualSystemsList(user, null);
        for (VirtualSystemOverview current : dr) {
            if (current.isFakeNode()) {
                continue;
            }
            else if (current.getUuid() == null && current.getHostSystemId() != null) {
                current.setSystemId(current.getHostSystemId());
            }
            else {
                current.setSystemId(current.getVirtualSystemId());
            }
            // Filter works on name field
            if (current.getServerName() != null) {
                current.setName(current.getServerName());
            }

        }
        systems.clear();
        for (VirtualSystemOverview current : dr) {
            systems.add(systemMap.get(current.getSystemId()));
        }
        return systems;
    }
}

