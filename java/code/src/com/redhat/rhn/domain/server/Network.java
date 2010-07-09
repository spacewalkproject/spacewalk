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

/**
 * Network
 * @version $Rev$
 */
public class Network extends BaseDomainHelper {

    private Long id;
    private String hostname;
    private String ipaddr;
    private Server server;


    /**
     * @return Returns the hostname.
     */
    public String getHostname() {
        return hostname;
    }

    /**
     * @param h The hostname to set.
     */
    public void setHostname(String h) {
        this.hostname = h;
    }

    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }

    /**
     * @param i The id to set.
     */
    public void setId(Long i) {
        this.id = i;
    }

    /**
     * @return Returns the ipaddr.
     */
    public String getIpaddr() {
        return ipaddr;
    }

    /**
     * @param i The ipaddr to set.
     */
    public void setIpaddr(String i) {
        this.ipaddr = i;
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
    public boolean equals(final Object other) {
        if (!(other instanceof Network)) {
            return false;
        }
        Network castOther = (Network) other;
        return new EqualsBuilder().append(id, castOther.id)
                                  .append(hostname, castOther.hostname)
                                  .append(ipaddr, castOther.ipaddr)
                                  .isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(id)
                                    .append(hostname)
                                    .append(ipaddr)
                                    .toHashCode();
    }
}
