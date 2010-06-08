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
package com.redhat.rhn.domain.errata;

import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.errata.impl.PublishedErrataFile;
import com.redhat.rhn.domain.errata.impl.PublishedKeyword;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.frontend.struts.Selectable;
import com.redhat.rhn.manager.errata.ErrataManager;

import org.apache.commons.collections.IteratorUtils;
import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

/**
 * 
 * AbstractErrata abstract implmenetation of Errata
 * @version $Rev$
 */
public abstract class AbstractErrata extends BaseDomainHelper implements
        Errata, Selectable {

    private Long id;
    private String advisory;
    private String advisoryType;
    private String product;
    private String description;
    private String synopsis;
    private String topic;
    private String solution;
    private Date issueDate;
    private Date updateDate;
    private String notes;
    private String refersTo;
    private String advisoryName;
    private Long advisoryRel;
    private Boolean locallyModified;
    private Date lastModified;
    private Org org;
    private Set bugs = new HashSet();
    private Set files;
    private Set keywords;
    protected Set packages;
    private boolean selected;

    /**
     * Getter for id
     * @return Long to get
     */
    public Long getId() {
        return this.id;
    }

    /**
     * Setter for id
     * @param idIn to set
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     * Getter for advisory
     * @return String to get
     */
    public String getAdvisory() {
        return this.advisory;
    }

    /**
     * Setter for advisory
     * @param advisoryIn to set
     */
    public void setAdvisory(String advisoryIn) {
        this.advisory = advisoryIn;
    }

    /**
     * Getter for advisoryType
     * @return String to get
     */
    public String getAdvisoryType() {
        return this.advisoryType;
    }

    /**
     * Setter for advisoryType
     * @param advisoryTypeIn to set
     */
    public void setAdvisoryType(String advisoryTypeIn) {
        this.advisoryType = advisoryTypeIn;
    }

    /**
     * Getter for product
     * @return String to get
     */
    public String getProduct() {
        return this.product;
    }

    /**
     * Setter for product
     * @param productIn to set
     */
    public void setProduct(String productIn) {
        this.product = productIn;
    }

    /**
     * Getter for description
     * @return String to get
     */
    public String getDescription() {
        return this.description;
    }

    /**
     * Setter for description
     * @param descriptionIn to set
     */
    public void setDescription(String descriptionIn) {
        this.description = descriptionIn;
    }

    /**
     * Getter for synopsis
     * @return String to get
     */
    public String getSynopsis() {
        return this.synopsis;
    }

    /**
     * Getter for synopsis
     * @return String to get
     */
    public String getAdvisorySynopsis() {
        return getSynopsis();
    }

    /**
     * Setter for synopsis
     * @param synopsisIn to set
     */
    public void setSynopsis(String synopsisIn) {
        this.synopsis = synopsisIn;
    }

    /**
     * Getter for topic
     * @return String to get
     */
    public String getTopic() {
        return this.topic;
    }

    /**
     * Setter for topic
     * @param topicIn to set
     */
    public void setTopic(String topicIn) {
        this.topic = topicIn;
    }

    /**
     * Getter for solution
     * @return String to get
     */
    public String getSolution() {
        return this.solution;
    }

    /**
     * Setter for solution
     * @param solutionIn to set
     */
    public void setSolution(String solutionIn) {
        this.solution = solutionIn;
    }

    /**
     * Getter for issueDate
     * @return Date to get
     */
    public Date getIssueDate() {
        return this.issueDate;
    }

    /**
     * Setter for issueDate
     * @param issueDateIn to set
     */
    public void setIssueDate(Date issueDateIn) {
        this.issueDate = issueDateIn;
    }

    /**
     * Getter for updateDate
     * @return Date to get
     */
    public Date getUpdateDate() {
        return this.updateDate;
    }

    /**
     * Setter for updateDate
     * @param updateDateIn to set
     */
    public void setUpdateDate(Date updateDateIn) {
        this.updateDate = updateDateIn;
    }

    /**
     * Getter for notes
     * @return String to get
     */
    public String getNotes() {
        return this.notes;
    }

    /**
     * Setter for notes
     * @param notesIn to set
     */
    public void setNotes(String notesIn) {
        this.notes = notesIn;
    }

    /**
     * Getter for orgId
     * @return Long to get
     */
    public Org getOrg() {
        return this.org;
    }

    /**
     * Setter for org
     * @param orgIn to set
     */
    public void setOrg(Org orgIn) {
        this.org = orgIn;
    }

    /**
     * Getter for refersTo
     * @return String to get
     */
    public String getRefersTo() {
        return this.refersTo;
    }

    /**
     * Setter for refersTo
     * @param refersToIn to set
     */
    public void setRefersTo(String refersToIn) {
        this.refersTo = refersToIn;
    }

    /**
     * Getter for advisoryName
     * @return String to get
     */
    public String getAdvisoryName() {
        return this.advisoryName;
    }

    /**
     * Setter for advisoryName
     * @param advisoryNameIn to set
     */
    public void setAdvisoryName(String advisoryNameIn) {
        this.advisoryName = advisoryNameIn;
    }

    /**
     * Getter for advisoryRel
     * @return Long to get
     */
    public Long getAdvisoryRel() {
        return this.advisoryRel;
    }

    /**
     * Setter for advisoryRel
     * @param advisoryRelIn to set
     */
    public void setAdvisoryRel(Long advisoryRelIn) {
        this.advisoryRel = advisoryRelIn;
    }

    /**
     * Getter for locallyModified
     * @return Boolean to get
     */
    public Boolean getLocallyModified() {
        return this.locallyModified;
    }

    /**
     * Setter for locallyModified
     * @param locallyModifiedIn to set
     */
    public void setLocallyModified(Boolean locallyModifiedIn) {
        this.locallyModified = locallyModifiedIn;
    }

    /**
     * Getter for lastModified
     * @return Date to get
     */
    public Date getLastModified() {
        return this.lastModified;
    }

    /**
     * Setter for lastModified
     * @param lastModifiedIn to set
     */
    public void setLastModified(Date lastModifiedIn) {
        this.lastModified = lastModifiedIn;
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
     * {@inheritDoc}
     */
    public void removeBug(Long bugId) {
        Iterator itr = getBugs().iterator();
        Bug deleteme = null; // the bug to delete
        while (itr.hasNext()) {
            Bug bug = (Bug) itr.next();
            if (bug.getId().equals(bugId)) {
                deleteme = bug; // we found it!!!
                break;
            }
        }
        getBugs().remove(deleteme);
        ErrataFactory.removeBug(deleteme);
    }

    /**
     * Adds a bug to the bugs set
     * @param bugIn The bug to add
     */
    public void addBug(Bug bugIn) {
        // add bug to bugs
        this.getBugs().add(bugIn);
        // set errata for bugIn
        bugIn.setErrata(this);
    }

    /**
     * @return Returns the bugs.
     */
    public Set getBugs() {
        return bugs;
    }

    /**
     * @param b The bugs to set.
     */
    public void setBugs(Set b) {
        this.bugs = b;
    }

    /**
     * Adds a file to the file set
     * @param fileIn The file to add
     */
    public void addFile(ErrataFile fileIn) {
        if (this.files == null) {
            this.files = new HashSet();
        }

        this.files.add(fileIn);
        fileIn.setErrata(this);
    }

    /**
     * Removes a file from the files set
     * @param fileId The id of the file to remove
     */
    public void removeFile(Long fileId) {
        Iterator itr = this.files.iterator();
        ErrataFile deleteme = null; // the bug to delete
        while (itr.hasNext()) {
            ErrataFile file = (ErrataFile) itr.next();
            if (file.getId().equals(fileId)) {
                deleteme = file; // we found it!!!
                break;
            }
        }
        this.files.remove(deleteme);
        ErrataFactory.removeFile(deleteme);
    }

    /**
     * @return Returns the files.
     */
    public Set getFiles() {
        return this.files;
    }

    /**
     * @param f The files to set.
     */
    public void setFiles(Set f) {
        this.files = f;
    }

    /**
     * Convienience method so we can add keywords logically Adds a keyword to
     * the keywords set
     * @param keywordIn The keyword to add.
     */
    public void addKeyword(String keywordIn) {
        if (this.keywords == null) {
            this.keywords = new HashSet();
        }
        /*
         * Bah... this stinks since a keyword is just a string, but we have to
         * set the created/modified fields in the db.
         */
        Keyword k = new PublishedKeyword();
        k.setKeyword(keywordIn);
        addKeyword(k);
        k.setErrata(this);
    }

    /**
     * Adds a keyword to the keywords set.
     * @param keywordIn The keyword to add.
     */
    public void addKeyword(Keyword keywordIn) {
        if (this.keywords == null) {
            this.keywords = new HashSet();
        }
        // add keyword to set
        keywords.add(keywordIn);
        // set errata for keywordIn

    }

    /**
     * @return Returns the keywords.
     */
    public Set getKeywords() {
        return keywords;
    }

    /**
     * @param k The keywords to set.
     */
    public void setKeywords(Set k) {
        this.keywords = k;
    }

    /**
     * Adds a package to the packages set and create an ErrataFile that
     * represents this package
     * @param packageIn The package to add.
     */
    public void addPackage(Package packageIn) {
        if (this.packages == null) {
            this.packages = new HashSet();
        }
        packages.add(packageIn);
    }

    /**
     * {@inheritDoc}
     */
    public void removePackage(Package packageIn) {
        packages.remove(packageIn);
    }

    /**
     * @return Returns the packages.
     */
    public Set getPackages() {
        return packages;
    }

    /**
     * @param p The packages to set.
     */
    public void setPackages(Set p) {
        this.packages = p;
    }

    /**
     * {@inheritDoc}
     */
    public void addNotification(Date dateIn) {
        ErrataManager.clearErrataNotifications(this);
        for (Channel chan : getChannels()) {
            ErrataManager.addErrataNotification(this, chan, dateIn);
        }
    }
    
    /**
     * {@inheritDoc}
     */
    public List getNotificationQueue() {
        return ErrataManager.listErrataNotifications(this);
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        StringBuffer result = new StringBuffer();
        result.append(this.getClass().getName());
        result.append(" : ");
        result.append(id);
        result.append(" : ");
        result.append(advisory);
        result.append(" desc: " + description);
        result.append(" syn: " + synopsis);
        return result.toString();
    }

    /**
     * {@inheritDoc}
     */
    public void clearChannels() {
        if (this.getChannels() != null) {
            this.getChannels().clear();
        }
        Iterator i = IteratorUtils.getIterator(this.getFiles());
        while (i.hasNext()) {
            PublishedErrataFile pf = (PublishedErrataFile) i.next();
            pf.getChannels().clear();
        }
    }

    /**
     * 
     * {@inheritDoc}
     */
    public abstract boolean isPublished();

    /**
     * 
     * {@inheritDoc}
     */
    public abstract boolean isCloned();

    /**
     * @return whether this object is selectable for RhnSet
     */
    public boolean isSelectable() {
        return true;
    }

    /**
     * @return the selected
     */
    public boolean isSelected() {
        return selected;
    }

    /**
     * @param isSelected the selected to set
     */
    public void setSelected(boolean isSelected) {
        this.selected = isSelected;
    }

    /**
     * 
     * {@inheritDoc}
     */
    public String getSelectionKey() {
        return String.valueOf(getId());
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(Object obj) {
        if (!(obj instanceof AbstractErrata)) {
            return false;
        }
        AbstractErrata e = (AbstractErrata) obj;
        EqualsBuilder eb = new EqualsBuilder();
        eb.append(this.getAdvisory(), e.getAdvisory());
        eb.append(this.getAdvisoryName(), e.getAdvisoryName());
        eb.append(this.getAdvisoryRel(), e.getAdvisoryRel());
        eb.append(this.getAdvisorySynopsis(), e.getAdvisorySynopsis());
        eb.append(this.getOrg(), e.getOrg());
        return eb.isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        HashCodeBuilder eb = new HashCodeBuilder();
        eb.append(this.getAdvisory());
        eb.append(this.getAdvisoryName());
        eb.append(this.getAdvisoryRel());
        eb.append(this.getAdvisorySynopsis());
        eb.append(this.getOrg());
        return eb.toHashCode();
    }
}
