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
package com.redhat.rhn.domain.rhnpackage;

import java.sql.Blob;
import java.util.Date;
import java.util.Set;

/**
 * PatchSet
 * @version $Rev$
 */
public class PatchSet extends Package {

    private Date setDate;
    private Date created;
    private Date modified;
    private Set<Patch> members;
    private Blob readme;

    /**
     * @return Returns the readme.
     */
    public Blob getReadme() {
        return readme;
    }

    /**
     * @param readmeIn The readme to set.
     */
    public void setReadme(Blob readmeIn) {
        this.readme = readmeIn;
    }

    /**
     * @return Returns the setDate.
     */
    public Date getSetDate() {
        return setDate;
    }

    /**
     * @param setDateIn The setDate to set.
     */
    public void setSetDate(Date setDateIn) {
        setDate = setDateIn;
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
     * @return Returns the modified.
     */
    public Date getModified() {
        return modified;
    }

    /**
     * @param modifiedIn The modified to set.
     */
    public void setModified(Date modifiedIn) {
        modified = modifiedIn;
    }

    /**
     * @return Returns the members.
     */
    public Set<Patch> getMembers() {
        return members;
    }

    /**
     * @param membersIn The members to set.
     */
    public void setMembers(Set<Patch> membersIn) {
        this.members = membersIn;
    }

    /**
     * Adds a patch to the patch set
     * @param patch the patch to add
     */
    public void addPatch(Patch patch) {
        this.members.add(patch);
    }
}
