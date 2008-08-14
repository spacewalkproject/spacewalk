/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.satellite.search.db.models;


/**
 * Errata
 * @version $Rev$
 */
public class Errata {
    private long id;
    private String advisory;
    private String advisoryType;
    private String advisoryName;
    private long advisoryRel;
    private String product;
    private String description;
    private String synopsis;
    private String topic;
    private String solution;
    private String issueDate;
    private String updateDate;
    private String notes;
    private String orgId;
    private String created;
    private String modified;
    private String lastModified;
    
    /**
     * Returns a string representation of the errata
     * @return string representation of the errata
     */
    public String toString() {
        StringBuffer text = new StringBuffer("Errata<" + id + ", " + product + ">: ");
        text.append(advisoryType + ", " + advisoryName + ", " + advisory);
        text.append(", " + topic + ", " + synopsis);
        return text.toString();
    }

    /**
     * Returns the erratum's id.
     * @return the erratum's id.
     */
    public long getId() {
        return id;
    }

    /**
     * The erratum's id.
     * @param idIn erratum id.
     */
    public void setId(long idIn) {
        id = idIn;
    }

    /**
     * Returns the advisory.
     * @return the advisory.
     */
    public String getAdvisory() {
        return advisory;
    }

    /**
     * Sets the advisory.
     * @param advisoryIn
     */
    public void setAdvisory(String advisoryIn) {
        advisory = advisoryIn;
    }

    /**
     * Returns advisory name
     * @return advisory name
     */
    public String getAdvisoryName() {
        return advisoryName;
    }

    /**
     * Sets advisory name
     * @param advisoryNameIn new advisory name
     */
    public void setAdvisoryName(String advisoryNameIn) {
        advisoryName = advisoryNameIn;
    }

    /**
     * Returns advisory release
     * @return advisory release
     */
    public long getAdvisoryRel() {
        return advisoryRel;
    }

    /**
     * Sets advisory release
     * @param advisoryRelIn advisory release
     */
    public void setAdvisoryRel(long advisoryRelIn) {
        advisoryRel = advisoryRelIn;
    }

    /**
     * Returns advisory type
     * @return advisory type 
     */
    public String getAdvisoryType() {
        return advisoryType;
    }

    /**
     * Set advisory type
     * @param advisoryTypeIn new advisory type
     */
    public void setAdvisoryType(String advisoryTypeIn) {
        advisoryType = advisoryTypeIn;
    }

    /**
     * Returns created date as a string
     * @return created date as a string
     */
    public String getCreated() {
        return created;
    }

    /**
     * Sets the created date (expecting string format)
     * @param createdIn string formatted date.
     */
    public void setCreated(String createdIn) {
        created = createdIn;
    }

    /**
     * Returns the errata description
     * @return the errata description
     */
    public String getDescription() {
        return description;
    }

    /**
     * Sets the description
     * @param descriptionIn description of errata
     */
    public void setDescription(String descriptionIn) {
        description = descriptionIn;
    }

    /**
     * Returns the erratum's issue date as a string.
     * @return the erratum's issue date as a string.
     */
    public String getIssueDate() {
        return issueDate;
    }

    /**
     * Sets the issue date (expecting string format).
     * @param issueDateIn string formatted date.
     */
    public void setIssueDate(String issueDateIn) {
        issueDate = issueDateIn;
    }

    /**
     * Returns the last time the erratum was modified as a string.
     * @return the last time the erratum was modified as a string.
     */
    public String getLastModified() {
        return lastModified;
    }

    /**
     * sets the last modified date as a string.
     * @param lastModifiedIn string formatted last modified date.
     */
    public void setLastModified(String lastModifiedIn) {
        lastModified = lastModifiedIn;
    }

    /**
     * Returns the modified date as a string.
     * @return the modified date as a string.
     */
    public String getModified() {
        return modified;
    }

    /**
     * Sets the modified date as a string.
     * @param modifiedIn string formatted date.
     */
    public void setModified(String modifiedIn) {
        modified = modifiedIn;
    }

    /**
     * Returns notes associated with the errataum.
     * @return notes associated with the errataum.
     */
    public String getNotes() {
        return notes;
    }

    /**
     * Sets the notes for the erratum.
     * @param notesIn notes.
     */
    public void setNotes(String notesIn) {
        notes = notesIn;
    }

    /**
     * The org id owning the errata.
     * @return org id owning the errata.
     */
    public String getOrgId() {
        return orgId;
    }

    /**
     * Sets the orgid owning the errata.
     * @param orgIdIn owning orgid.
     */
    public void setOrgId(String orgIdIn) {
        orgId = orgIdIn;
    }

    /**
     * Products affected.
     * @return affected products.
     */
    public String getProduct() {
        return product;
    }

    /**
     * sets the product.
     * @param productIn product
     */
    public void setProduct(String productIn) {
        product = productIn;
    }

    /**
     * Returns what the errata proposed solution.
     * @return what the errata proposed solution.
     */
    public String getSolution() {
        return solution;
    }

    /**
     * Proposed solution
     * @param solutionIn proposed solution.
     */
    public void setSolution(String solutionIn) {
        solution = solutionIn;
    }

    /**
     * Returns erratum's synopsis.
     * @return erratum's synopsis.
     */
    public String getSynopsis() {
        return synopsis;
    }

    /**
     * Sets the erratum's synopsis.
     * @param synopsisIn synopsis.
     */
    public void setSynopsis(String synopsisIn) {
        synopsis = synopsisIn;
    }

    /**
     * returns erratum topic.
     * @return erratum topic.
     */
    public String getTopic() {
        return topic;
    }

    /**
     * Sets the erratum's topic.
     * @param topicIn topic
     */
    public void setTopic(String topicIn) {
        topic = topicIn;
    }

    /**
     * Returns the update date as a string.
     * @return the update date as a string.
     */
    public String getUpdateDate() {
        return updateDate;
    }

    /**
     * Sets the update date as a string.
     * @param updateDateIn string formatted date.
     */
    public void setUpdateDate(String updateDateIn) {
        updateDate = updateDateIn;
    }
}
