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
package com.redhat.rhn.frontend.dto;

import com.redhat.rhn.frontend.filter.DepthAware;

/**
 * Simple DTO for transfering data from the DB to the UI through datasource.
 *
 * @version $Rev$
 */
public class VirtualSystemOverview extends SystemOverview
                                        implements DepthAware {

    private Long systemId;
    private String uuid;
    private String stateName;
    private String stateLabel;
    private Long hostSystemId;
    private Long virtualSystemId;
    private Long countActiveInstances;
    private Long countTotalInstances;
    private boolean doAction;
    private String noActionReason;
    private String actionName;
    private Long vcpus;
    private Long memory;
    private String virtEntitlement;


    /**
     * @return Returns the system id.
     */
    public Long getSystemId() {
        return systemId;
    }
    /**
     * @param systemIdIn the system id to set
     */
    public void setSystemId(Long systemIdIn) {
        this.systemId = systemIdIn;
    }

    /**
     * @return Returns the vcpus.
     */
    public Long getVcpus() {
        return vcpus;
    }

    /**
     * @param vcpusIn The vcpus to set.
     */
    public void setVcpus(Long vcpusIn) {
        this.vcpus = vcpusIn;
    }

    /**
     * @return Returns the memory in Kb.
     */
    public Long getMemory() {
        return memory;
    }

    /**
     * @param memoryIn The memory to set. (in Kb)
     */
    public void setMemory(Long memoryIn) {
        this.memory = memoryIn;
    }

    /**
     * @return Returns the uuid.
     */
    public String getUuid() {
        return uuid;
    }

    /**
     * @param uuidIn The uuid to set.
     */
    public void setUuid(String uuidIn) {
        this.uuid = uuidIn;
    }

    /**
     * @return Returns the stateName.
     */
    public String getStateName() {
        return stateName;
    }
    /**
     * @param stateNameIn The stateName to set.
     */
    public void setStateName(String stateNameIn) {
        this.stateName = stateNameIn;
    }

    /**
     * @return Returns the stateLabel.
     */
    public String getStateLabel() {
        return stateLabel;
    }
    /**
     * @param stateLabelIn The stateLabel to set.
     */
    public void setStateLabel(String stateLabelIn) {
        this.stateLabel = stateLabelIn;
    }

    /**
     * @return Returns the host system id.
     */
    public Long getHostSystemId() {
        return hostSystemId;
    }
    /**
     * @param hostSystemIdIn the system id to set
     */
    public void setHostSystemId(Long hostSystemIdIn) {
        this.hostSystemId = hostSystemIdIn;
    }

    /**
     * @return Returns the virtual system id.
     */
    public Long getVirtualSystemId() {
        return virtualSystemId;
    }
    /**
     * @param virtualSystemIdIn the system id to set
     */
    public void setVirtualSystemId(Long virtualSystemIdIn) {
        this.virtualSystemId = virtualSystemIdIn;
    }

    /**
     * @return Returns the number of instances.
     */
    public Long getCountTotalInstances() {
        if (countTotalInstances == null) {
            return new Long(0);
        }
        return countTotalInstances;
    }
    /**
     * @param countTotalInstancesIn the count of instances to set
     */
    public void setCountTotalInstances(Long countTotalInstancesIn) {
        this.countTotalInstances = countTotalInstancesIn;
    }

    /**
     * @return Returns the number of 'active' instances - where the
     *         state is not 'stopped' or 'crashed'.
     */
    public Long getCountActiveInstances() {
        if (countActiveInstances == null) {
            return new Long(0);
        }
        return countActiveInstances;
    }
    /**
     * @param countActiveInstancesIn the count of active instances to set
     */
    public void setCountActiveInstances(Long countActiveInstancesIn) {
        this.countActiveInstances = countActiveInstancesIn;
    }

    /**
     * Is the virtual system a 'host' system (dom0)?
     * @return whether the current system is UI isVirtualHost
     */
    public boolean getIsVirtualHost() {
        return (this.getUuid() == null);
    }


    /**
     * Gets the value of doAction
     *
     * @return the value of doAction
     */
    public boolean getDoAction() {
        return this.doAction;
    }

    /**
     * Sets the value of doAction
     *
     * @param argDoAction Value to assign to this.doAction
     */
    public void setDoAction(boolean argDoAction) {
        this.doAction = argDoAction;
    }

    /**
     * Gets the value of noActionReason
     *
     * @return the value of noActionReason
     */
    public String getNoActionReason() {
        return this.noActionReason;
    }

    /**
     * Sets the value of noActionReason
     *
     * @param argNoActionReason Value to assign to this.noActionReason
     */
    public void setNoActionReason(String argNoActionReason) {
        this.noActionReason = argNoActionReason;
    }

    /**
     * Gets the value of actionName
     *
     * @return the value of actionName
     */
    public String getActionName() {
        return this.actionName;
    }

    /**
     * Sets the value of actionName
     *
     * @param argActionName Value to assign to this.actionName
     */
    public void setActionName(String argActionName) {
        this.actionName = argActionName;
    }

    /**
     * {@inheritDoc}
     */
    public long depth() {
        if (getIsVirtualHost()) {
            return 0;
        }
        else {
            return 1;
        }
    }

    /**
     *  gets the current virtual entitlement string (none if the system has no virt ent)
     * @return the current virtual entitlement label
     */
    public String getVirtEntitlement() {
        return virtEntitlement;
    }

    /**
     *  sets the virtual Entitlement label of this system
     * @param virtEntitlementIn the virt entitlement label to set
     */
    public void setVirtEntitlement(String virtEntitlementIn) {
        this.virtEntitlement = virtEntitlementIn;
    }
}
