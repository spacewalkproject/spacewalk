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
package com.redhat.rhn.frontend.taglibs.list.decorators;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.taglibs.list.ListTag;
import com.redhat.rhn.manager.system.SystemManager;

import java.util.HashMap;
import java.util.List;

import javax.servlet.http.HttpServletRequest;


/**
 * ElaborationDecorator
 * @version $Rev$
 */
public class SystemHealthIconDecorator extends BaseListDecorator {


    /**
     * {@inheritDoc}
     */
    public void setCurrentList(ListTag current) {
        super.setCurrentList(current);
        if (current != null) {
            elaborateContents();    
        }
    }
    
    private void elaborateContents() {
        List<SystemOverview> systems = getCurrentList().getPageData();
        
        RequestContext context = new RequestContext(
                (HttpServletRequest)getCurrentList().getContext().getRequest());
        
        for (SystemOverview next : systems) {
            DataResult result = SystemManager.getMonitoringStatus(
                    context.getLoggedInUser(), next.getId().longValue());
            if (result != null && result.size() == 1) {
                next.setMonitoringStatus((String)
                        ((HashMap) result.get(0)).values().iterator().next());              
            }
        }
    }
}
