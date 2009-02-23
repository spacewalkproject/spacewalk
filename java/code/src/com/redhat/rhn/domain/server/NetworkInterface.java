/**
 * Copyright (c) 2009 Red Hat, Inc.
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
 * NetworkInterface
 * @version $Rev$
 */
public class NetworkInterface extends BaseDomainHelper implements 
    Serializable {

    private Server server;
    private String name;
    private String ipaddr;
    private String netmask;
    private String broadcast;
    private String hwaddr;
    private String module;
    
    
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
     * @return Returns the hwaddr.
     */
    public String getHwaddr() {
        return hwaddr;
    }
    
    /**
     * @param h The hwaddr to set.
     */
    public void setHwaddr(String h) {
        this.hwaddr = h;
    }
    
    /**
     * @return Returns the ipddr.
     */
    public String getIpaddr() {
        return ipaddr;
    }
    
    /**
     * @param i The ipddr to set.
     */
    public void setIpaddr(String i) {
        this.ipaddr = i;
    }
    
    /**
     * @return Returns the module.
     */
    public String getModule() {
        return module;
    }
    
    /**
     * @param m The module to set.
     */
    public void setModule(String m) {
        this.module = m;
    }
    
    /**
     * @return Returns the name.
     */
    public String getName() {
        return name;
    }
    
    /**
     * @param n The name to set.
     */
    public void setName(String n) {
        this.name = n;
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
        if (!(other instanceof NetworkInterface)) {
            return false;
        }
        NetworkInterface castOther = (NetworkInterface) other;
        return new EqualsBuilder().append(this.getServer(), castOther.getServer())
                                  .append(this.getName(), castOther.getName())
                                  .append(this.getIpaddr(), castOther.getIpaddr())
                                  .append(this.getNetmask(), castOther.getNetmask())
                                  .append(this.getBroadcast(), castOther.getBroadcast())
                                  .append(this.getHwaddr(), castOther.getHwaddr())
                                  .append(this.getModule(), castOther.getModule())
                                  .isEquals();
    }
    
    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(this.getServer())
                                    .append(this.getName())
                                    .append(this.getIpaddr())
                                    .append(this.getNetmask())
                                    .append(this.getBroadcast())
                                    .append(this.getHwaddr())
                                    .append(this.getModule())
                                    .toHashCode();
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return "NetworkInterface - name: " + this.getName() + " ip: " + this.getIpaddr();
    }
    
    /**
     * returns true if the NetworkInterface is disabled
     * @return if it's empty or not
     */
    public boolean isDisabled() {
        return this.getIpaddr() == null || this.getIpaddr().equals("0") ||  
                this.getIpaddr().equals("");
    }
    
    
}
