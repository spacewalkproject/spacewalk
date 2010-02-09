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

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.Package;

import java.util.Date;
import java.util.List;
import java.util.Set;

/**
 * Errata - Class representation of the table rhnErrata.
 * @version $Rev$
 */
public interface Errata {
    
    /** 
     * Getter for id 
     * @return Long to get
    */
    Long getId();

    /** 
     * Setter for id 
     * @param idIn to set
    */
    void setId(Long idIn);

    /** 
     * Getter for advisory 
     * @return String to get
    */
    String getAdvisory();

    /** 
     * Setter for advisory 
     * @param advisoryIn to set
    */
    void setAdvisory(String advisoryIn);

    /** 
     * Getter for advisoryType 
     * @return String to get
    */
    String getAdvisoryType();

    /** 
     * Setter for advisoryType 
     * @param advisoryTypeIn to set
    */
    void setAdvisoryType(String advisoryTypeIn);

    /** 
     * Getter for product 
     * @return String to get
    */
    String getProduct();

    /** 
     * Setter for product 
     * @param productIn to set
    */
    void setProduct(String productIn);

    /** 
     * Getter for description 
     * @return String to get
    */
    String getDescription();

    /** 
     * Setter for description 
     * @param descriptionIn to set
    */
    void setDescription(String descriptionIn);

    /** 
     * Getter for synopsis 
     * @return String to get
    */
    String getSynopsis();

    /** 
     * Setter for synopsis 
     * @param synopsisIn to set
    */
    void setSynopsis(String synopsisIn);

    /** 
     * Getter for topic 
     * @return String to get
    */
    String getTopic();

    /** 
     * Setter for topic 
     * @param topicIn to set
    */
    void setTopic(String topicIn);

    /** 
     * Getter for solution 
     * @return String to get
    */
    String getSolution();

    /** 
     * Setter for solution 
     * @param solutionIn to set
    */
    void setSolution(String solutionIn);

    /** 
     * Getter for issueDate 
     * @return Date to get
    */
    Date getIssueDate();

    /** 
     * Setter for issueDate 
     * @param issueDateIn to set
    */
    void setIssueDate(Date issueDateIn);

    /** 
     * Getter for updateDate 
     * @return Date to get
    */
    Date getUpdateDate();

    /** 
     * Setter for updateDate 
     * @param updateDateIn to set
    */
    void setUpdateDate(Date updateDateIn);

    /** 
     * Getter for notes 
     * @return String to get
    */
    String getNotes();

    /** 
     * Setter for notes 
     * @param notesIn to set
    */
    void setNotes(String notesIn);

    /** 
     * Getter for org 
     * @return Org to get
    */
    Org getOrg();

    /** 
     * Setter for org 
     * @param orgIn to set
    */
    void setOrg(Org orgIn);

    /** 
     * Getter for refersTo 
     * @return String to get
    */
    String getRefersTo();

    /** 
     * Setter for refersTo 
     * @param refersToIn to set
    */
    void setRefersTo(String refersToIn);

    /** 
     * Getter for advisoryName 
     * @return String to get
    */
    String getAdvisoryName();

    /** 
     * Setter for advisoryName 
     * @param advisoryNameIn to set
    */
    void setAdvisoryName(String advisoryNameIn);

    /** 
     * Getter for advisoryRel 
     * @return Long to get
    */
    Long getAdvisoryRel();

    /** 
     * Setter for advisoryRel 
     * @param advisoryRelIn to set
    */
    void setAdvisoryRel(Long advisoryRelIn);

    /** 
     * Getter for locallyModified 
     * @return boolean to get
    */
    Boolean getLocallyModified();

    /** 
     * Setter for locallyModified 
     * @param locallyModifiedIn to set
    */
    void setLocallyModified(Boolean locallyModifiedIn);

    /** 
     * Getter for lastModified 
     * @return Date to get
    */
    Date getLastModified();

    /** 
     * Setter for lastModified 
     * @param lastModifiedIn to set
    */
    void setLastModified(Date lastModifiedIn);

    /**
     * Returns true if the advisory is a Product Enhancement.
     * @return true if the advisory is a Product Enhancement.
     */
    boolean isProductEnhancement();
    
    /**
     * Returns true if the advisory is a Security Advisory.
     * @return true if the advisory is a Security Advisory.
     */
    boolean isSecurityAdvisory();
    
    /**
     * Returns true if the advisory is a Bug Fix.
     * @return true if the advisory is a Bug Fix.
     */
    boolean isBugFix();
    
    /**
     * Adds a bug to the bugs set
     * @param bugIn The bug to add
     */
    void addBug(Bug bugIn);

    /**
     * Removes a bug from the bugs set
     * @param bugId The id of the bug to remove
     */
    void removeBug(Long bugId);
    
    /**
     * @return Returns the bugs.
     */
    Set getBugs();
    
    /**
     * @param b The bugs to set.
     */
    void setBugs(Set b);
    
    /**
     * Adds a file to the file set
     * @param fileIn The file to add
     */
    void addFile(ErrataFile fileIn);

    /**
     * Removes a file from the files set
     * @param fileId The id of the file to remove
     */
    void removeFile(Long fileId);
    
    /**
     * @return Returns the files.
     */
    Set<ErrataFile> getFiles();
    
    /**
     * @param f The files to set.
     */
    void setFiles(Set f);
    
    /**
     * Convienience method so we can add keywords logically
     * Adds a keyword to the keywords set
     * @param keywordIn The keyword to add.
     */
    void addKeyword(String keywordIn);
    
    /**
     * Adds a keyword to the keywords set.
     * @param keywordIn The keyword to add.
     */
    void addKeyword(Keyword keywordIn);
    
    /**
     * @return Returns the keywords.
     */
    Set getKeywords();
    
    /**
     * @param k The keywords to set.
     */
    void setKeywords(Set k);
    
    /**
     * Adds a package to the packages set.
     * @param packageIn The package to add.
     */
    void addPackage(Package packageIn);
    
    /**
     * Removes a package from the packages set.
     * @param packageIn The package to remove.
     */
    void removePackage(Package packageIn);
    
    /**
     * @return Returns the packages.
     */
    Set getPackages();
    
    /**
     * @param p The packages to set.
     */
    void setPackages(Set p);
    
    /**
     * @return Returns the Set of channels associated with this errata
     */
    Set<Channel> getChannels();
    
    /**
     * @param channelsIn The set of channels to set for this errata
     */
    void setChannels(Set channelsIn);
    
    /**
     * Adds a single channel to this errata
     * @param channelIn The channel to add
     */
    void addChannel(Channel channelIn);
    
    /**
     * Add a new notification for this errata
     * @param dateIn The notify date
     */
    void addNotification(Date dateIn);
    
    /**
     * List errata notifications that are queued
     * @return list of maps with channel_id and time
     */
    List getNotificationQueue();
    
    /**
     * Tells whether or not the errata is published. 
     * @return Returns true if this is a PublishedErrata
     */
    boolean isPublished();

    
    /**
     * Tells whether or not the errata is cloned.
     * @return Returns true if this errata is cloned
     */
    boolean isCloned();

    
    /**
     * {@inheritDoc}
     */
    String toString();

    /** 
     * Clears out the Channels associated with this errata.
     *
     */
    void clearChannels();
    /**
     * Sets cves
     * @param cvesIn cve input
     */
    void setCves(Set <Cve> cvesIn);
    /**
     * 
     * @return Returns Cves
     */
    Set <Cve> getCves();
      
}
