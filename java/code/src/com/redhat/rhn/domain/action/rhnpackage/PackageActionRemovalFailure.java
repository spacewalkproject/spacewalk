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
package com.redhat.rhn.domain.action.rhnpackage;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.rhnpackage.PackageCapability;
import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.rhnpackage.PackageName;
import com.redhat.rhn.domain.server.Server;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.io.Serializable;

/**
 * PackageActionRemovalFailure
 * @version $Rev$
 */
public class PackageActionRemovalFailure implements Serializable {

    private Server server;
    private Action action;
    private PackageName packageName;
    private PackageEvr evr;
    private PackageCapability capability;
    private Long flags;
    private PackageName suggested;
    private Long sense;

    /**
     * @return Returns the capability.
     */
    public PackageCapability getCapability() {
        return capability;
    }

    /**
     * @param c The capability to set.
     */
    public void setCapability(PackageCapability c) {
        this.capability = c;
    }

    /**
     * @return Returns the evr.
     */
    public PackageEvr getEvr() {
        return evr;
    }

    /**
     * @param e The evr to set.
     */
    public void setEvr(PackageEvr e) {
        this.evr = e;
    }

    /**
     * @return Returns the flags.
     */
    public Long getFlags() {
        return flags;
    }

    /**
     * @param f The flags to set.
     */
    public void setFlags(Long f) {
        this.flags = f;
    }

    /**
     * @return Returns the packageAction.
     */
    public Action getAction() {
        return action;
    }

    /**
     * @param p The Action to set.
     */
    public void setAction(Action p) {
        this.action = p;
    }

    /**
     * @return Returns the packageName.
     */
    public PackageName getPackageName() {
        return packageName;
    }

    /**
     * @param p The packageName to set.
     */
    public void setPackageName(PackageName p) {
        this.packageName = p;
    }

    /**
     * @return Returns the sense.
     */
    public Long getSense() {
        return sense;
    }

    /**
     * @param s The sense to set.
     */
    public void setSense(Long s) {
        this.sense = s;
    }

    /**
     * @return Returns the server.
     */
    public Server getServer() {
        return server;
    }

    /**
     * @param s The server to set.
     */
    public void setServer(Server s) {
        this.server = s;
    }

    /**
     * @return Returns the suggested.
     */
    public PackageName getSuggested() {
        return suggested;
    }

    /**
     * @param s The suggested to set.
     */
    public void setSuggested(PackageName s) {
        this.suggested = s;
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(Object obj) {
        if (obj == null || !(obj instanceof PackageActionRemovalFailure)) {
            return false;
        }

        PackageActionRemovalFailure p = (PackageActionRemovalFailure) obj;

        return new EqualsBuilder().append(this.getAction(), p.getAction())
                                  .append(this.getServer(), p.getServer())
                                  .append(this.getPackageName(), p.getPackageName())
                                  .append(this.getCapability(), p.getCapability())
                                  .append(this.getEvr(), p.getEvr())
                                  .append(this.getFlags(), p.getFlags())
                                  .append(this.getSense(), p.getSense())
                                  .append(this.getSuggested(), p.getSuggested())
                                  .isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(getAction())
                                    .append(getServer())
                                    .append(getPackageName())
                                    .append(getCapability())
                                    .append(getEvr())
                                    .append(getFlags())
                                    .append(getSense())
                                    .append(getSuggested())
                                    .toHashCode();
    }
}
