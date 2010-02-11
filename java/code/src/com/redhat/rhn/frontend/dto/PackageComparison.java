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
package com.redhat.rhn.frontend.dto;

import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * PackageComparison
 * @version $Rev$
 */
public class PackageComparison extends BaseDto {
    
    protected Long id;
    protected String name;
    protected String currentNvrea;
    protected String newNvrea;

    /**
     * @return Returns the currentNvre.
     */
    public String getCurrentNvrea() {
        return currentNvrea;
    }
    /**
     * @param currentNvreIn The currentNvre to set.
     */
    public void setCurrentNvrea(String currentNvreIn) {
        this.currentNvrea = currentNvreIn;
    }
    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }
    /**
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }
    /**
     * @return Returns the newNvre.
     */
    public String getNewNvrea() {
        return newNvrea;
    }
    /**
     * @param newNvreIn The newNvre to set.
     */
    public void setNewNvrea(String newNvreIn) {
        this.newNvrea = newNvreIn;
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
        this.name = nameIn;
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return new ToStringBuilder(this).append("id", id).append("name", name)
            .append("currentNvre", currentNvrea).append("newNvre", newNvrea)
                .toString();
    }

}
