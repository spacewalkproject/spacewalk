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
package com.redhat.rhn.frontend.dto;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.Elaborator;
import com.redhat.rhn.common.db.datasource.RowCallback;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.manager.errata.ErrataManager;

import java.text.ParseException;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

/**
 * ErrataOverview
 * @version $Rev$
 */
public class ErrataOverview extends BaseDto 
            implements RowCallback {
    private Long id;
    private String advisory;
    private String advisoryName;
    private String advisoryType;
    private String advisorySynopsis;
    private Date updateDate;
    private Date issueDate;
    private Integer affectedSystemCount;
    private String advisoryLastUpdated;
    private List cves;
    private List packageNames;
    private List actionId;
    private List status;
    private Long associatedSystemId;
    private Date lastModified;
   
    /**
     * This method is only used for csv export.. 
     * @return the internationalized errata advisory type string.
     */
    public String getErrataAdvisoryType() {
        LocalizationService ls = LocalizationService.getInstance();
        if (isSecurityAdvisory()) {
            return ls.getMessage("erratalist.jsp.securityadvisory");
        }
        else if (isBugFix()) {
            return ls.getMessage("erratalist.jsp.bugadvisory");
        }
        else if (isProductEnhancement()) {
            return ls.getMessage("erratalist.jsp.productenhancementadvisory");
        }
        return "";
    }
    /**
     * This method is only used for CSV export 
     * @return the i18ned errata status string.
     */
    public String getErrataStatus() {
        LocalizationService ls = LocalizationService.getInstance();
        if ("Queued".equals(getCurrentStatusAndActionId()[0])) {
            return ls.getMessage("affectedsystems.jsp.pending");
        }
        if ("Failed".equals(getCurrentStatusAndActionId()[0])) {
            return ls.getMessage("affectedsystems.jsp.failed");
        }
        if (getStatus() == null || getStatus().isEmpty()) {
            return ls.getMessage("affectedsystems.jsp.none");
        }
        return ""; 
    }
    
    /**
     * @return the associatedSystem
     */
    public Long getAssociatedSystem() {
        return associatedSystemId;
    }
    
    /**
     * @param systemId the associatedSystem to set
     */
    public void setAssociatedSystem(Long systemId) {
        this.associatedSystemId = systemId;
    }
    /**
     * @return Returns the actionId.
     */
    public List getActionId() {
        return actionId;
    }
    /**
     * @param actionIdIn The actionId to set.
     */
    public void setActionId(List actionIdIn) {
        this.actionId = actionIdIn;
    }
    /**
     * @return Returns the status.
     */
    public List getStatus() {
        return status;
    }
    /**
     * @param statusIn The status to set.
     */
    public void setStatus(List statusIn) {
        this.status = statusIn;
    }
    /**
     * Adds a name to packageNames list.
     * @param name The name to add to packageNames.
     */
    public void addPackageName(String name) {
        if (packageNames == null) {
            packageNames = new ArrayList();
        }
        packageNames.add(name);
    }
    /**
     * @return Returns the packageNames.
     */
    public List getPackageNames() {
        return packageNames;
    }
    /**
     * @param p The packageNames to set.
     */
    public void setPackageNames(List p) {
        this.packageNames = p;
    }
    /**
     * @return Returns the cves.
     */
    public List getCves() {
        return cves;
    }
    /**
     * Adds a cve to cves list.
     * @param cveIn The cve to add to cves list.
     */
    public void addCve(CVE cveIn) {
        if (cveIn == null) {
            cves = new ArrayList();
        }
        cves.add(cveIn);
    }
    /**
     * @param p The cves to set.
     */
    public void setCves(List p) {
        this.cves = p;
    }
    
    /**
     * @return Returns the advisoryLastUpdated.
     */
    public String getAdvisoryLastUpdated() {
        return advisoryLastUpdated;
    }
    
    /**
     * @param a The advisoryLastUpdated to set.
     */
    public void setAdvisoryLastUpdated(String a) {
        this.advisoryLastUpdated = a;
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
     * @return Returns the advisoryLastUpdated.
     */
    public String getUpdateDate() {
        return LocalizationService.getInstance().formatShortDate(updateDate);
    }
    /**
     * @return Returns the advisoryLastUpdated.
     */
    public Date getUpdateDateObj() {
        return updateDate;
    }    
    /**
     * @param advisoryLastUpdatedIn The advisoryLastUpdated to set.
     */
    public void setUpdateDate(Date advisoryLastUpdatedIn) {
        updateDate = advisoryLastUpdatedIn;
    }
    /**
     * @return Returns the issueDate.
     */
    public String getIssueDate() {
        if (issueDate == null) {
            return null;
        }
        return LocalizationService.getInstance().formatShortDate(issueDate);
    }
    /**
     * @return Returns the advisoryLastUpdated.
     */
    public Date getIssueDateObj() {
        return issueDate;
    }
    /**
     * @param issueDateIn The issueDate to set.
     */
    public void setIssueDate(Date issueDateIn) {
        issueDate = issueDateIn;
    }
    /**
     * @param issueDateIn The issueDate to set.String 'yyyy-mm-dd"
     * @throws ParseException when issueDateIn can't be parsed
     */
    public void setIssueDate(String issueDateIn) throws ParseException {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-mm-dd");
        issueDate = sdf.parse(issueDateIn);
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
     * @return Returns the advisorySynopsis.
     */
    public String getAdvisorySynopsis() {
        return advisorySynopsis;
    }
    /**
     * @param advisorySynopsisIn The advisorySynopsis to set.
     */
    public void setAdvisorySynopsis(String advisorySynopsisIn) {
        advisorySynopsis = advisorySynopsisIn;
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
     * @return Returns the affectedSystemCount.
     */
    public Integer getAffectedSystemCount() {
        return affectedSystemCount;
    }
    /**
     * @param affectedSystemCountIn The affectedSystemCount to set.
     */
    public void setAffectedSystemCount(Integer affectedSystemCountIn) {
        affectedSystemCount = affectedSystemCountIn;
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
     * Returns id as a long
     * @return id as a long
     */
    public long getIdAsLong() {
        return id.longValue();
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
     * Returns the most applicable status with its action id
     * Completed supercedes Picked Up which supercedes Queued which supercedes Failed
     * @return An array with the first index as status and second index as actionId
     */
    public Object[] getCurrentStatusAndActionId() {
        Object[] results = new Object[2];
        if (status == null) {
            results[0] = null;
            results[1] = null;
        }
        else if (status.contains("Completed")) {
            results[0] = status.get(status.indexOf("Completed"));
            results[1] = actionId.get(status.indexOf("Completed"));
        }
        else if (status.contains("Picked Up")) {
            results[0] = status.get(status.indexOf("Picked Up"));
            results[1] = actionId.get(status.indexOf("Picked Up"));
        }
        else if (status.contains("Queued")) {
            results[0] = status.get(status.indexOf("Queued"));
            results[1] = actionId.get(status.indexOf("Queued"));
        }
        else {
            results[0] = status.get(status.indexOf("Failed"));
            results[1] = actionId.get(status.indexOf("Failed"));
        }
        return results;
    }

    /**
     * @return Returns the lastModified.
     */
    public Date getLastModifiedObject() {
        return lastModified;
    }

    /**
     * @return Returns the lastModified.
     */
    public String getLastModified() {
        return LocalizationService.getInstance().formatDate(lastModified);
    }


    /**
     * @param lastModifiedIn The lastModified to set.
     */
    public void setLastModified(Date lastModifiedIn) {
        this.lastModified = lastModifiedIn;
    }

    /**
     * {@inheritDoc}
     */
    public List<String> getCallBackColumns() {
        return new ArrayList<String>();
    }

    /**
     * {@inheritDoc}
     */
    public void callback(ResultSet rs) throws SQLException {
        if (rs != null) {
            if ("Security Advisory".equals(rs.getString("advisory_type"))) {
                long eid = rs.getLong("id");
                DataResult dr = ErrataManager.errataCVEs(eid);
                Elaborator elab = dr.getElaborator();
                List cvesList = new ArrayList();
                for (Iterator iter = dr.iterator(); iter.hasNext();) {
                    CVE cve = (CVE)iter.next();
                    cvesList.add(cve.getName());
                }
                this.setCves(cvesList);
            }
        }
    }
}
