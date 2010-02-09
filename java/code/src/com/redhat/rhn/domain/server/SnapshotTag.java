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
package com.redhat.rhn.domain.server;

import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.org.Org;

import org.apache.commons.lang.builder.HashCodeBuilder;

import java.util.Set;

/**
 * CPU
 * @version $Rev: 118113 $
 */
public class SnapshotTag extends BaseDomainHelper {
    
   
    private Long id;
    private SnapshotTagName name;
    private Org org;
    
    private Set<ServerSnapshot> snapshots;
    
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
     * @return Returns the name.
     */
    public SnapshotTagName getName() {
        return name;
    }

    
    /**
     * @param nameIn The name to set.
     */
    public void setName(SnapshotTagName nameIn) {
        this.name = nameIn;
    }

    
    /**
     * @return Returns the org.
     */
    public Org getOrg() {
        return org;
    }

    
    /**
     * @param orgIn The org to set.
     */
    public void setOrg(Org orgIn) {
        this.org = orgIn;
    }

    
    /**
     * @return Returns the snapshots.
     */
    public Set<ServerSnapshot> getSnapshots() {
        return snapshots;
    }

    
    /**
     * @param snapshotsIn The snapshots to set.
     */
    public void setSnapshots(Set<ServerSnapshot> snapshotsIn) {
        this.snapshots = snapshotsIn;
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(name.hashCode())
                                    .append(org.hashCode())
                                    .toHashCode();
    }

}
