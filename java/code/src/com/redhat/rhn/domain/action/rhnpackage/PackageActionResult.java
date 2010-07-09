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

import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.server.Server;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.io.Serializable;

/**
 * PackageActionResult
 * @version $Rev$
 */
public class PackageActionResult extends BaseDomainHelper implements Serializable {

    private Server server;
    private PackageActionDetails details;
    private Long resultCode;
    //private <blob> stderr;
    //private <blob> stdout;

    /**
     * @return Returns the packageActionDetails.
     */
    public PackageActionDetails getDetails() {
        return details;
    }

    /**
     * @param p The packageActionDetails to set.
     */
    public void setDetails(PackageActionDetails p) {
        this.details = p;
    }

    /**
     * @return Returns the resultCode.
     */
    public Long getResultCode() {
        return resultCode;
    }

    /**
     * @param r The resultCode to set.
     */
    public void setResultCode(Long r) {
        this.resultCode = r;
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
     * {@inheritDoc}
     */
    public boolean equals(Object obj) {
        if (obj == null || !(obj instanceof PackageActionResult)) {
            return false;
        }

        PackageActionResult p = (PackageActionResult) obj;

        return new EqualsBuilder().append(this.getDetails(), p.getDetails())
                                  .append(this.getServer(), p.getServer())
                                  .append(this.getResultCode(), p.getResultCode())
                                  .isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(this.getDetails())
                                    .append(this.getServer())
                                    .append(this.getResultCode())
                                    .toHashCode();
    }
}
