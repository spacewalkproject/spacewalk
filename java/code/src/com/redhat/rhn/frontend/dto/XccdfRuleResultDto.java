/**
 * Copyright (c) 2012 Red Hat, Inc.
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

import java.util.ArrayList;
import java.util.List;

import com.redhat.rhn.domain.audit.ScapFactory;
import com.redhat.rhn.domain.audit.XccdfTestResult;
import com.redhat.rhn.manager.audit.ScapManager;

/**
 * Simple DTO for transfering data from the DB to the UI through datasource.
 * @version $Rev$
 */
public class XccdfRuleResultDto extends BaseDto {

    private Long id;
    private String label;
    private Long testResultId;
    private List<XccdfIdentDto> idents;

    /**
     * Returns id of xccdf:rule-result
     * @return the id
     */
    public Long getId() {
        return this.id;
    }

    /**
     * Sets the id of xccdf:rule-result
     * @param idIn to set
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     * Returns the actual xccdf:rule-result result
     * @return the result
     */
    public String getLabel() {
        return label;
    }

    /**
     * Returns the actual xccdf:rule-result result
     * @return the result
     */
    public String getEvaluationResult() {
        // this method serve only for better localization within CSVWriter
        return getLabel();
    }

    /**
     * Sets the actual xccdf:rule-result result
     * @param labelIn to set
     */
    public void setLabel(String labelIn) {
        label = labelIn;
    }

    /**
     * Returns id of parent xccdf:TestResult
     * @return the id
     */
    public Long getTestResultId() {
        return this.testResultId;
    }

    /**
     * Sets the id of parent xccdf:TestResult
     * @param testResultIdIn to set
     */
    public void setTestResultId(Long testResultIdIn) {
        testResultId = testResultIdIn;
    }

    /**
     * Returns the parent testResult
     * @return the parent testResult
     */
    public XccdfTestResult getTestResult() {
        return ScapFactory.lookupTestResultById(this.testResultId);
    }

    /**
     * Get idref attribute of xccdf:rule-result
     * @return idref attribute
     */
    public String getDocumentIdref() {
        for (XccdfIdentDto i : getIdents()) {
            if (i.isDocumentIdref()) {
                return i.getIdentifier();
            }
        }
        return new String();
    }

    /**
     * Get idents without idref
     * @return list of idents without the idref
     */
    public List<XccdfIdentDto> getIdentsWithoutIdref() {
        List<XccdfIdentDto> result = new ArrayList<XccdfIdentDto>();
        for (XccdfIdentDto i : getIdents()) {
            if (!i.isDocumentIdref()) {
                result.add(i);
            }
        }
        return result;
    }

    /**
     * Return summary of xccdf:idents in xccdf:rule-result
     * @return comma separated list of xccdf:ident identifiers
     */
    public String getIdentsString() {
        String result = new String();
        for (XccdfIdentDto i : getIdents()) {
            if (!i.isDocumentIdref()) {
                result += (result.isEmpty() ? "" : ", ") + i.getIdentifier();
            }
        }
        return result;
    }

    private List<XccdfIdentDto> getIdents() {
        if (idents == null) {
            idents = ScapManager.identsPerRuleResult(this.id);
        }
        return idents;
    }
}
