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
package com.redhat.rhn.frontend.dto.kickstart;

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.frontend.dto.BaseDto;

import org.apache.commons.lang.BooleanUtils;
import org.apache.commons.lang.StringUtils;

/**
 * DTO for a com.redhat.rhn.domain.kickstart.KickStartData
 * @version $Rev: 50942 $
 */
public class KickstartDto extends BaseDto {
    private Long id;
    private Long orgId;
    private Long kstreeId;
    private String label;
    private String isOrgDefault;
    private String treeLabel;
    private boolean active;
    private String kickstartType;
    private String cobblerId;
    private String cobblerUrl;
    private int virtMemory;
    private int virtSpace;
    private int virtCpus;
    private String virtBridge;


    /**
     * @return if this is a raw KS
     */
    public boolean isAdvancedMode() {
        return KickstartData.TYPE_RAW.equals(kickstartType);
    }

    /**
     * @param typeIn to set
     */
    public void setKickstartType(String typeIn) {
        this.kickstartType = typeIn;
    }

    /**
     * @return the id
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
     * @return the orgId
     */
    public Long getOrgId() {
        return orgId;
    }

    /**
     * @param orgIdIn The id to set.
     */
     public void setOrgId(Long orgIdIn) {
         this.orgId = orgIdIn;
     }

    /**
     * @return the kickstart tree id
     */
    public Long getKstreeId() {
        return kstreeId;
    }

    /**
     * @param kstreeIdIn The kstree id to set.
     */
     public void setKstreeId(Long kstreeIdIn) {
         this.kstreeId = kstreeIdIn;
     }

    /**
     * @return Returns the label.
     */
    public String getLabel() {
        return label;
    }

    /**
     * @param labelIn The name to set.
     */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }

    /**
     * @return Returns the active flag.
     */
    public boolean isActive() {
        return active;
    }

    /**
     * @param activeIn The server id, null if not a satellite
     */
    public void setActive(boolean activeIn) {
        this.active = activeIn;
    }


    /**
     * @return Returns the isOrgDefault.
     */
    public boolean isOrgDefault() {
        return !StringUtils.isBlank(isOrgDefault) &&
                BooleanUtils.toBoolean(isOrgDefault, "Y", "N");
    }


    /**
     * @param isOrgDefaultIn The isOrgDefault to set.
     */
    public void setIsOrgDefault(String isOrgDefaultIn) {
        this.isOrgDefault = isOrgDefaultIn;
    }

    /**
     * @return the treeLabel
     */
    public String getTreeLabel() {
        return treeLabel;
    }



    /**
     * @param treeLabelIn the treeLabel to set
     */
    public void setTreeLabel(String treeLabelIn) {
        this.treeLabel = treeLabelIn;
    }

    /**
     * @return true if this dto represents a
     *  Cobbler Only Profile.
     */
    public boolean isCobbler() {
        return false;
    }

    /**
     * @return the cobblerId
     */
    public String getCobblerId() {
        return cobblerId;
    }

    /**
     * @param cobblerIdIn the cobblerId to set
     */
    public void setCobblerId(String cobblerIdIn) {
        cobblerId = cobblerIdIn;
    }

    /**
     * @return the cobblerUrl
     */
    public String getCobblerUrl() {
        return cobblerUrl;
    }

    /**
     * @param cobblerUrlIn the cobblerUrl to set
     */
    public void setCobblerUrl(String cobblerUrlIn) {
        cobblerUrl = cobblerUrlIn;
    }


    /**
     * @return Returns the virtMemory.
     */
    public int getVirtMemory() {
        return virtMemory;
    }


    /**
     * @param virtMemoryIn The virtMemory to set.
     */
    public void setVirtMemory(int virtMemoryIn) {
        this.virtMemory = virtMemoryIn;
    }


    /**
     * @return Returns the virtSpace.
     */
    public int getVirtSpace() {
        return virtSpace;
    }


    /**
     * @param virtSpaceIn The virtSpace to set.
     */
    public void setVirtSpace(int virtSpaceIn) {
        this.virtSpace = virtSpaceIn;
    }


    /**
     * @return Returns the virtCpus.
     */
    public int getVirtCpus() {
        return virtCpus;
    }


    /**
     * @param virtCpusIn The virtCpus to set.
     */
    public void setVirtCpus(int virtCpusIn) {
        this.virtCpus = virtCpusIn;
    }


    /**
     * @return Returns the virtBridge.
     */
    public String getVirtBridge() {
        return virtBridge;
    }


    /**
     * @param virtBridgeIn The virtBridge to set.
     */
    public void setVirtBridge(String virtBridgeIn) {
        this.virtBridge = virtBridgeIn;
    }
}
