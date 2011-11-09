/**
 * Copyright (c) 2009--2011 Red Hat, Inc.
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
 * ServerNetAddress4
 */

public class ServerNetAddress4 extends BaseDomainHelper implements Serializable {

    private Long interfaceId;
    private String address;
    private String netmask;
    private String broadcast;

    /**
     * @return Returns the interfaceId.
     */
    public Long getInterfaceId() {
        return interfaceId;
    }

    /**
     * @param id Set the interfaceId.
     */
    public void setInterfaceId(Long id) {
        this.interfaceId = id;
    }

    /**
     * @return Returns the address.
     */
    public String getAddress() {
        return address;
    }

    /**
     * @param i The address to set.
     */
    public void setAddress(String i) {
        this.address = i;
    }

    /**
     * @return Returns the broadcast.
     */
    public String getBroadcast() {
        return broadcast;
    }

    /**
     * @param b The broadcast to set.
     */
    public void setBroadcast(String b) {
        this.broadcast = b;
    }

    /**
     * @return Returns the netmask.
     */
    public String getNetmask() {
        return netmask;
    }

    /**
     * @param n The netmask to set.
     */
    public void setNetmask(String n) {
        this.netmask = n;
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof ServerNetAddress4)) {
            return false;
        }

        ServerNetAddress4 castOther = (ServerNetAddress4) other;
        return new EqualsBuilder().append(this.getAddress(), castOther.getAddress())
                                  .append(this.getBroadcast(), castOther.getBroadcast())
                                  .append(this.getNetmask(), castOther.getNetmask())
                                  .isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(this.getAddress())
                                    .append(this.getBroadcast())
                                    .append(this.getNetmask())
                                    .toHashCode();
    }
}
