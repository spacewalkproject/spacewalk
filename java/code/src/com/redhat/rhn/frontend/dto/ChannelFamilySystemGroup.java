/**
 * Copyright (c) 2010 Red Hat, Inc.
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
package com.redhat.rhn.frontend.dto;

import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.Identifiable;
import com.redhat.rhn.frontend.struts.Expandable;

import java.util.Date;
import java.util.LinkedList;
import java.util.List;


/**
 * ChannelSystemGrouping
 * @version $Rev$
 */
public class ChannelFamilySystemGroup implements Identifiable, Expandable {

    private String name;
    private Long id;
    private List<SystemInfo> systems = new LinkedList<SystemInfo>();
    
    /**
     * {@inheritDoc}
     */
    public Long getId() {
        return id;
    }
    
    /**
     * adds a system to the grouping
     * @param sys a System overview object
     */
    public void add(SystemInfo sys) {
        systems.add(sys);
    }

    
    /**
     * @return Returns the name.
     */
    public String getName() {
        return name;
    }

    
    /**
     * @param nameIn The name to set.
     */
    public void setName(String nameIn) {
        name = nameIn;
    }

    
    /**
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        id = idIn;
    }

    /**
     * 
     * {@inheritDoc}
     */
    public List<? extends Identifiable> expand() {
        return systems;
    }
    
    /**
     * 
     * SystemInfo
     * @version $Rev$
     */
    public static class SystemInfo  implements Identifiable {
        private String name;
        private Long id;
        private boolean active;
        private Date registered;
        
        
        /**
         * @return Returns the name.
         */
        public String getName() {
            return name;
        }
        
        /**
         * @param nameIn The name to set.
         */
        public void setName(String nameIn) {
            name = nameIn;
        }
        
        /**
         * @return Returns the active.
         */
        public boolean isActive() {
            return active;
        }
        
        /**
         * @param activeIn The active to set.
         */
        public void setActive(boolean activeIn) {
            active = activeIn;
        }
        
        /**
         * @return Returns the registered.
         */
        public Date getRegistered() {
            return registered;
        }
        
        /**
         * @return Returns the registered.
         */
        public String  getRegisteredString() {
            return StringUtil.categorizeTime(registered.getTime(), StringUtil.YEARS_UNITS);
        }        
        /**
         * @param registeredIn The registered to set.
         */
        public void setRegistered(Date registeredIn) {
            registered = registeredIn;
        }
        
        /**
         * @param idIn The id to set.
         */
        public void setId(Long idIn) {
            id = idIn;
        }

        /**
         * {@inheritDoc}
         */
        public Long getId() {
            return id;
        }
        
    }
}
