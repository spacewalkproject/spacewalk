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

import com.redhat.rhn.common.localization.LocalizationService;

import java.util.Date;

/**
 * OwnedErrata
 * @version $Rev$
 */
public class OwnedErrata extends BaseDto {

    private Long id;
    private String advisory;
    private String advisoryName;
    private String advisoryType;
    private String synopsis;
    private Date updateDate;
    private Date created;
    private String locallyModified;
    private Integer published;
    private Long fromErrataId;
    private String relationship;
    private Long affectedSystemCount;

    /**
     * @param locallyModifiedIn The locallyModified to set.
     */
    public void setLocallyModified(String locallyModifiedIn) {
        this.locallyModified = locallyModifiedIn;
    }
    /**
     * @return Returns the advisory.
     */
    public String getAdvisory() {
        return advisory;
    }
    /**
     * @param advisoryIn The advisory to set.
     */
    public void setAdvisory(String advisoryIn) {
        advisory = advisoryIn;
    }
    /**
     * @return Returns the advisoryName.
     */
    public String getAdvisoryName() {
        return advisoryName;
    }
    /**
     * @param advisoryNameIn The advisoryName to set.
     */
    public void setAdvisoryName(String advisoryNameIn) {
        advisoryName = advisoryNameIn;
    }
    /**
     * @return Returns the created.
     */
    public Date getCreated() {
        return created;
    }
    /**
     * @param createdIn The created to set.
     */
    public void setCreated(Date createdIn) {
        created = createdIn;
    }
    /**
     * @return Returns the fromErrataId.
     */
    public Long getFromErrataId() {
        return fromErrataId;
    }
    /**
     * @param fromErrataIdIn The fromErrataId to set.
     */
    public void setFromErrataId(Long fromErrataIdIn) {
        fromErrataId = fromErrataIdIn;
    }
    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }
    /**
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        id = idIn;
    }
    /**
     * @return Returns the locallyModified.
     */
    public String getLocallyModified() {
        return locallyModified;
    }
    /**
     * @return Returns the published.
     */
    public Integer getPublished() {
        return published;
    }
    /**
     * @param publishedIn The published to set.
     */
    public void setPublished(Integer publishedIn) {
        published = publishedIn;
    }
    /**
     * @return Returns the relationship.
     */
    public String getRelationship() {
        return relationship;
    }
    /**
     * @param relationshipIn The relationship to set.
     */
    public void setRelationship(String relationshipIn) {
        relationship = relationshipIn;
    }
    /**
     * @return Returns the synopsys.
     */
    public String getSynopsis() {
        return synopsis;
    }
    /**
     * @param synopsisIn The synopsys to set.
     */
    public void setSynopsis(String synopsisIn) {
        synopsis = synopsisIn;
    }

    /**
     * @param synopsisIn The synopsys to set.
     */
    public void setAdvisorySynopsis(String synopsisIn) {
        setSynopsis(synopsisIn);
    }

    /**
     * Returns the advisory synopsis.
     * @return advisory synopsis.
     */
    public String getAdvisorySynopsis() {
        return getSynopsis();
    }

    /**
     * @return Returns the updateDate.
     */
    public String getUpdateDate() {
        return LocalizationService.getInstance().formatDate(updateDate);
    }
    /**
     * @param updateDateIn The updateDate to set.
     */
    public void setUpdateDate(Date updateDateIn) {
        updateDate = updateDateIn;
    }

    /**
     * Returns true if the advisory is a Product Enhancement.
     * @return true if the advisory is a Product Enhancement.
     */
    public boolean isProductEnhancement() {
        return "Product Enhancement Advisory".equals(getAdvisoryType());
    }

    /**
     * Returns true if the advisory is a Security Advisory.
     * @return true if the advisory is a Security Advisory.
     */
    public boolean isSecurityAdvisory() {
        return "Security Advisory".equals(getAdvisoryType());
    }

    /**
     * Returns true if the advisory is a Bug Fix.
     * @return true if the advisory is a Bug Fix.
     */
    public boolean isBugFix() {
        return "Bug Fix Advisory".equals(getAdvisoryType());
    }

    /**
     * @return Returns the advisoryType.
     */
    public String getAdvisoryType() {
        return advisoryType;
    }
    /**
     * @param advisoryTypeIn The advisoryType to set.
     */
    public void setAdvisoryType(String advisoryTypeIn) {
        advisoryType = advisoryTypeIn;
    }

    /**
     * @return Return the affected system count
     */
    public Long getAffectedSystemCount() {
        return this.affectedSystemCount;
    }

    /**
     * Sets the system count
     * @param systemCountIn system count to be set
     */
    public void setAffectedSystemCount(Long systemCountIn) {
        this.affectedSystemCount = systemCountIn;
    }
}
