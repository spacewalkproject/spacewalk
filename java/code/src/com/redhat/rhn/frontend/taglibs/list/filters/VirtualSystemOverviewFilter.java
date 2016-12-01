/**
 * Copyright (c) 2016 Red Hat, Inc.
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
package com.redhat.rhn.frontend.taglibs.list.filters;

import com.redhat.rhn.frontend.dto.VirtualSystemOverview;

import java.util.HashMap;
import java.util.List;

/**
 * VirtualSystemOverviewFilter
 * @version $Rev$
 */
public class VirtualSystemOverviewFilter extends SystemOverviewFilter {

    private HashMap<Long, VirtualSystemOverview> virtHostMap =
            new HashMap<Long, VirtualSystemOverview>();

    @Override
    public boolean filter(Object object, String field, String criteria) {
        if (object instanceof VirtualSystemOverview) {
            VirtualSystemOverview vso = (VirtualSystemOverview)object;
            if (vso.getIsVirtualHost()) {
                // add host node to map for later retrieval in postFilter()
                getVirtHostMap().put(vso.getSystemId(), vso);
            }
        }
        return super.filter(object, field, criteria);
    }

    @Override
    public void postFilter(List filteredList) {
        if (filteredList != null && filteredList.size() > 0 &&
                filteredList.get(0) instanceof VirtualSystemOverview) {
            VirtualSystemOverview parentHost = null;
            for (int i = 0; i < filteredList.size(); i++) {
                VirtualSystemOverview current = (VirtualSystemOverview) filteredList.get(i);
                if (current.getIsVirtualHost()) {
                    parentHost = current;
                }
                else {
                    if (current.getHostSystemId() == null) {
                        // add fake host node, just like in
                        // VirtualSystemOverview.processList()
                        VirtualSystemOverview fakeSystem = new VirtualSystemOverview();
                        fakeSystem.setServerName(VirtualSystemOverview.FAKENODE_LABEL);
                        fakeSystem.setHostSystemId(new Long(0));
                        filteredList.add(i, fakeSystem);
                        i++;
                    }
                    else {
                        // add actual host node to list if its not already there
                        if (parentHost == null || !parentHost.getSystemId()
                                .equals(current.getHostSystemId())) {
                            parentHost = getVirtHostMap().get(current.getHostSystemId());
                            if (parentHost != null) {
                                filteredList.add(i, parentHost);
                                i++;
                            }
                        }
                    }
                }
            }
        }
        super.postFilter(filteredList);
        virtHostMap.clear();
    }

    private HashMap<Long, VirtualSystemOverview> getVirtHostMap() {
        return virtHostMap;
    }
}
