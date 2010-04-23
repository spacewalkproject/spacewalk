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
package com.redhat.rhn.manager.system;

import com.redhat.rhn.frontend.dto.NetworkDto;

import java.util.ArrayList;
import java.util.List;

/**
 * 
 * DuplicateSystemBucket
 * @version $Rev$
 */
public class DuplicateSystemGrouping {

    private String key;
    private List<NetworkDto> systems;
    
    /**
     * Constructor
     * @param net networkDto Object 
     */
    public DuplicateSystemGrouping(NetworkDto net) {
        key = net.getKey();
        systems = new ArrayList<NetworkDto>();
        systems.add(net);
    }
    
    
    /**
     * @return Returns the key.
     */
    public String getKey() {
        return key;
    }

    /**
     * Add a object to the bucket if there is a match
     *  
     * @param net the object to add
     * @return true if added, false otherwise
     */
    public boolean addIfMatch(NetworkDto net) {
        if (net.getKey().equals(key)) {
            systems.add(net);
            return true;
        }
        return false;
    }

    
    /**
     * @return Returns the systems.
     */
    public List<NetworkDto> getSystem() {
        return systems;
    }
    
}
