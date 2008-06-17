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
package com.redhat.rhn.domain.rhnpackage;

import com.redhat.rhn.domain.BaseDomainHelper;

/**
 * PackageCapability
 * @version $Rev$
 */
public class PackageCapability extends BaseDomainHelper {

    private Long id;
    private String name;
    private String version;
    
    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }
    
    /**
     * @param i The id to set.
     */
    public void setId(Long i) {
        this.id = i;
    }
    
    /**
     * @return Returns the name.
     */
    public String getName() {
        return name;
    }
    
    /**
     * @param n The name to set.
     */
    public void setName(String n) {
        this.name = n;
    }
    
    /**
     * @return Returns the version.
     */
    public String getVersion() {
        return version;
    }
    
    /**
     * @param v The version to set.
     */
    public void setVersion(String v) {
        this.version = v;
    }
}
