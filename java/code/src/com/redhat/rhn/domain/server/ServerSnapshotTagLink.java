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

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.io.Serializable;

/**
 *
 * ServerSnapshot
 * @version $Rev$
 */
public class ServerSnapshotTagLink extends BaseDomainHelper implements Serializable {


    private Server server;
    private ServerSnapshot snapshot;
    private SnapshotTag tag;

    /**
     * @return Returns the server.
     */
    public Server getServer() {
        return server;
    }

    /**
     * @param serverIn The server to set.
     */
    public void setServer(Server serverIn) {
        this.server = serverIn;
    }

    /**
     * @return Returns the snapshot.
     */
    public ServerSnapshot getSnapshot() {
        return snapshot;
    }

    /**
     * @param snapshotIn The snapshot to set.
     */
    public void setSnapshot(ServerSnapshot snapshotIn) {
        this.snapshot = snapshotIn;
    }

    /**
     * @return Returns the tag.
     */
    public SnapshotTag getTag() {
        return tag;
    }

    /**
     * @param tagIn The tag to set.
     */
    public void setTag(SnapshotTag tagIn) {
        this.tag = tagIn;
    }

    /**
     *
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(server.hashCode())
                                    .append(tag.hashCode()).append(snapshot.hashCode())
                                    .toHashCode();
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(Object obj) {
        ServerSnapshotTagLink link = (ServerSnapshotTagLink) obj;
        EqualsBuilder build = new EqualsBuilder();

        return build.append(this.getServer(), link.getServer()).
                append(this.getSnapshot(), link.getSnapshot()).
                append(this.getTag(), link.getTag()).isEquals();
    }

}
