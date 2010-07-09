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
package com.redhat.rhn.domain.org;

import com.redhat.rhn.domain.server.Server;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

import java.io.Serializable;
import java.util.Date;

/**
 * Class representation of the rhnSystemMigrations table
 * SystemMigration
 * @version $Rev$
 */
public class SystemMigration implements Serializable {

    private Server server;
    private Org toOrg;
    private Org fromOrg;
    private Date migrated;

    /**
     * Constructor for SystemMigration
     */
    public SystemMigration() {
    }

    /**
     * Getter for server
     * @return the server that was migrated
     */
    public Server getServer() {
        return server;
    }

    /**
     * set the server that was migrated
     * @param serverIn the server that was migrated
     */
    public void setServer(Server serverIn) {
        this.server = serverIn;
    }

    /**
     * Getter for org that the server was migrated to
     * @return the org
     */
    public Org getToOrg() {
        return toOrg;
    }

    /**
     * Set the org that the server was migrated to
     * @param toOrgIn the org the server was migrated to
     */
    public void setToOrg(Org toOrgIn) {
        this.toOrg = toOrgIn;
    }

    /**
     * Getter for org that the server was migrated from
     * @return the org
     */
    public Org getFromOrg() {
        return fromOrg;
    }

    /**
     * Set the org that the server was migrated from
     * @param fromOrgIn the org the server was migrated from
     */
    public void setFromOrg(Org fromOrgIn) {
        this.fromOrg = fromOrgIn;
    }

    /**
     * Gets the migrated date
     * @return Date the current value
     */
    public Date getMigrated() {
        return this.migrated;
    }

    /**
     * Sets the migrated date
     * @param migratedIn Date the migration was performed
     */
    public void setMigrated(Date migratedIn) {
        this.migrated = migratedIn;
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        ToStringBuilder builder = new ToStringBuilder(this);
        builder.append("toOrg", this.getToOrg())
               .append("fromOrg", this.getFromOrg())
               .append("server", this.getServer())
               .append("migrated", this.getMigrated());
        return builder.toString();
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(Object obj) {

        if (!(obj instanceof SystemMigration)) {
            return false;
        }

        SystemMigration other = (SystemMigration) obj;

        EqualsBuilder builder = new EqualsBuilder();
        builder.append(this.getToOrg(), other.getToOrg())
               .append(this.getFromOrg(), other.getFromOrg())
               .append(this.getServer(), other.getServer())
               .append(this.getMigrated(), other.getMigrated());

        return builder.isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {

        HashCodeBuilder builder = new HashCodeBuilder();
        builder.append(this.getToOrg())
               .append(this.getFromOrg())
               .append(this.getServer())
               .append(this.getMigrated());

        return builder.toHashCode();
    }
}

