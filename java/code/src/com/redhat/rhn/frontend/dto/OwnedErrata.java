/**
 * Copyright (c) 2009--2015 Red Hat, Inc.
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

import java.util.Date;

/**
 * OwnedErrata
 * @version $Rev$
 */
public class OwnedErrata extends ErrataOverview {

    private Date created;
    private String locallyModified;
    private Integer published;

    /**
     * @param locallyModifiedIn The locallyModified to set.
     */
    public void setLocallyModified(String locallyModifiedIn) {
        this.locallyModified = locallyModifiedIn;
    }
    /**
     * @return Returns the created.
     */
    public Date getCreated() {
        return created;
    }
    /**
     * @param createdIn The created to set.
     */
    public void setCreated(Date createdIn) {
        created = createdIn;
    }
    /**
     * @return Returns the locallyModified.
     */
    public String getLocallyModified() {
        return locallyModified;
    }
    /**
     * @return Returns the published.
     */
    public Integer getPublished() {
        return published;
    }
    /**
     * @param publishedIn The published to set.
     */
    public void setPublished(Integer publishedIn) {
        published = publishedIn;
    }
    /**
     * @return Returns the synopsys.
     */
    public String getSynopsis() {
        return getAdvisorySynopsis();
    }
    /**
     * @param synopsisIn The synopsys to set.
     */
    public void setSynopsis(String synopsisIn) {
        setAdvisorySynopsis(synopsisIn);
    }
}
