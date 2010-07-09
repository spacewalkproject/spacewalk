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
 * VirtualInstanceInfo
 * @version $Rev$
 */
public class VirtualInstanceInfo extends BaseDomainHelper {

    private Long id;
    private String name;
    private Long totalMemory;
    private Integer virtualCPUs;
    private VirtualInstance parent;
    private VirtualInstanceType type;
    private VirtualInstanceState state;

    private Long getId() {
        return id;
    }

    private void setId(Long newId) {
        this.id = newId;
    }

    /**
     *
     * @return the virtual instance owning this info
     */
    public VirtualInstance getParent() {
        return parent;
    }

    void setParent(VirtualInstance parentInstance) {
        parent = parentInstance;
    }

    /**
     * Return the name of the virtual instance.
     *
     * @return The name of the virtual instance.
     */
    public String getName() {
        return name;
    }

    /**
     * Sets the name of the virtual instance.
     *
     * @param newName The new name
     */
    public void setName(String newName) {
        name = newName;
    }

    /**
     * Returns the total memory in KB allocated to the virtual instance.
     *
     * @return The total memory in KB allocated to the virtual instance.
     */
    public Long getTotalMemory() {
        return totalMemory;
    }

    /**
     * Sets the total memory in KB for the virtual instance.
     *
     * @param memory The total memory in KB.
     */
    public void setTotalMemory(Long memory) {
        totalMemory = memory;
    }

    /**
     * Returns the number of virtual CPUs allocated to the virtual instance.
     *
     * @return The number of virtual CPUs allocated to the virtual instance.
     */
    public Integer getNumberOfCPUs() {
        return virtualCPUs;
    }

    /**
     * Sets the number of virtual CPUs allocated to the virtual instance.
     *
     * @param cpuCount The number of virtual CPUs allocated to the virtual instance.
     */
    public void setNumberOfCPUs(Integer cpuCount) {
        virtualCPUs = cpuCount;
    }

    /**
     * Returns the virtualizations type of the virtual instance, which will be either
     * <code>Fully Virtualized</code> or <code>Para-Virtualized</code>.
     *
     * @return The type of virtualization type of the virtual instance, which will be either
     * <code>Fully Virtualized</code> or <code>Para-Virtualized</code>.
     */
    public VirtualInstanceType getType() {
        return type;
    }

    /**
     * Sets the virtualization type of the virtual instance.
     *
     * @param virtType The virtualization type
     */
    public void setType(VirtualInstanceType virtType) {
        type = virtType;
    }

    /**
     * Return the state of the virtual instance, which wil be running, stopped, crashed, or
     * paused.
     *
     * @return The state of the virtual instance, which wil be running, stopped, crashed, or
     * paused.
     */
    public VirtualInstanceState getState() {
        return state;
    }

    /**
     * Changes the state of the virtual instance.
     *
     * @param newState The new state, which is one of running, stopped, crashed, or paused.
     */
    public void setState(VirtualInstanceState newState) {
        state = newState;
    }

    /**
     * Two VirtualInstanceInfo objects are considered equal if they share the same parent
     * virtual instance.
     *
     * @param object The object to compare
     *
     * @return <code>true</code> if <code>object</code> is a VirtualInstanceInfo and has
     * the same parent VirtualInstance as this info object.
     */
    public boolean equals(Object object) {
        if (object == null || object.getClass() != getClass()) {
            return false;
        }

        VirtualInstanceInfo that = (VirtualInstanceInfo)object;

        return new EqualsBuilder().append(this.getParent(), that.getParent()).isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(getParent()).toHashCode();
    }

}
