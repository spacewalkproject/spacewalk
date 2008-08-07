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
package com.redhat.satellite.search.db.models;

import java.util.Date;

/**
 * ErrataOverview
 * @version $Rev$
 *
 */
public class ErrataCVE {
    private long errataId;
    private long cveId;
    private String name;
    private Date created;
    private Date modified;

    /**
     * Returns the errataId.
     * @return the errataId.
     */
    public long getErrataId() {
        return errataId;
    }
    /**
     * Sets errataId
     * @param errataIdIn new errata_id
     */
    public void setErrataId(long errataIdIn) {
        errataId = errataIdIn;
    }
    /**
     * Returns the cveId.
     * @return the cveId.
     */
    public long getCveId() {
        return cveId;
    }
    /**
     * Sets cveId
     * @param cveIdIn new errata_id
     */
    public void setCveId(long cveIdIn) {
        cveId = cveIdIn;
    }
    /**
     * Returns the name.
     * @return the name.
     */
    public String getName() {
        return name;
    }
    /**
     * Sets name
     * @param nameIn new name
     */
    public void setName(String nameIn) {
        name = nameIn;
    }
    /**
     * Returns the created date.
     * @return the created date.
     */
    public Date getCreated() {
        return created;
    }
    /**
     * Sets created
     * @param createdIn new created
     */
    public void setCreated(Date createdIn) {
        created = createdIn;
    }
    /**
     * Returns the modified date.
     * @return the modified date.
     */
    public Date getModified() {
        return modified;
    }
    /**
     * Sets modified
     * @param modifiedIn new modified
     */
    public void setModified(Date modifiedIn) {
        modified = modifiedIn;
    }


}
