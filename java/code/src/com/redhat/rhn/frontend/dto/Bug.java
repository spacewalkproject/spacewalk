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


/**
 * Simple DTO for transfering data from the DB to the UI through datasource.
 * @version $Rev$
 */
public class Bug {
    
    private Long errataId;
    private Long bugId;
    private String summary;
    

    /**
     * @return Returns the bugId.
     */
    public Long getBugId() {
        return bugId;
    }
    /**
     * @param bugIdIn The bugId to set.
     */
    public void setBugId(Long bugIdIn) {
        this.bugId = bugIdIn;
    }
    /**
     * @return Returns the errataId.
     */
    public Long getErrataId() {
        return errataId;
    }
    /**
     * @param errataIdIn The errataId to set.
     */
    public void setErrataId(Long errataIdIn) {
        this.errataId = errataIdIn;
    }
    /**
     * @return Returns the summary.
     */
    public String getSummary() {
        return summary;
    }
    /**
     * @param summaryIn The summary to set.
     */
    public void setSummary(String summaryIn) {
        this.summary = summaryIn;
    }
}
