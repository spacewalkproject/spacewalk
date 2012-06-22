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

import java.util.HashMap;
import java.util.List;

/**
 * Simple DTO for transfering data from the DB to the UI through datasource.
 * @version $Rev$
 */
public abstract class XccdfTestResultCounts extends BaseDto {

    private static final String PASS_LABEL = "pass";
    private static final String FAIL_LABEL = "fail";
    private static final String ERROR_LABEL = "error";
    private static final String UNKNOWN_LABEL = "unknown";
    private static final String NOTAPPLICABLE_LABEL = "notapplicable";
    private static final String NOTCHECKED_LABEL = "notchecked";
    private static final String NOTSELECTED_LABEL = "notselected";
    private static final String INFORMATIONAL_LABEL = "informational";
    private static final String FIXED_LABEL = "fixed";

    private HashMap<String, Long> countMap;

    /* Following properties are set by testresult_counts elaborator. */
    private List label;
    private List count;


    /**
     * Returns the list of labels (content of xccdf:result).
     * @return the result
     */
    public List getLabel() {
        return label;
    }

    /**
     * Sets the list of labels (content of xccdf:result).
     * @param labelIn to set
     */
    public void setLabel(List labelIn) {
        label = labelIn;
    }

    /**
     * Returns the list of counts. The count represents a number
     * of xccdf:rule-result elements per given label.
     * @return the result
     */
    public List getCount() {
        return count;
    }

    /**
     * Sets the list of counts.
     * @param countIn to set
     */
    public void setCount(List countIn) {
        count = countIn;
    }

    /**
     * Get the count of passed rules.
     * @return count of passed rules
     */
    public Long getPass() {
        return getCountOf(PASS_LABEL);
    }

    /**
     * Get the count of failed rules.
     * @return count of failed rules
     */
    public Long getFail() {
        return getCountOf(FAIL_LABEL);
    }

    /**
     * Get the count of errorneous rules.
     * @return count of errorneous rules
     */
    public Long getError() {
        return getCountOf(ERROR_LABEL);
    }

    /**
     * Get the count of rules with unknown result.
     * @return count of rules with unknown result
     */
    public Long getUnknown() {
        return getCountOf(UNKNOWN_LABEL);
    }

    /**
     * Get the count of rules with notapplicable result.
     * @return count of rules with notapplicable result
     */
    public Long getNotapplicable() {
        return getCountOf(NOTAPPLICABLE_LABEL);
    }

    /**
     * Get the count of rules with notchecked result.
     * @return count of rules with notchecked result
     */
    public Long getNotchecked() {
        return getCountOf(NOTCHECKED_LABEL);
    }

    /**
     * Get the count of rules with notselected result.
     * @return count of rules with notselected result
     */
    public Long getNotselected() {
        return getCountOf(NOTSELECTED_LABEL);
    }

    /**
     * Get the count of rules with informational result.
     * @return count of rules with informational result
     */
    public Long getInformational() {
        return getCountOf(INFORMATIONAL_LABEL);
    }

    /**
     * Get the count of rules with fixed result.
     * @return count of rules with fixed result
     */
    public Long getFixed() {
        return getCountOf(FIXED_LABEL);
    }

    /**
     * For a simple view, get satisfied results
     * @return the count
     */
    public Long getSatisfied() {
        return getPass() + getFixed();
    }

    /**
     * For a simple view, get dissatisfied results
     * @return the count
     */
    public Long getDissatisfied() {
        return getFail();
    }

    /**
     * For a simple view, get results which are generally unknown
     * @return the count
     */
    public Long getSatisfactionUnknown() {
        return getError() + getUnknown() + getNotchecked();
    }

    private Long getCountOf(String resultLabel) {
        Long result = getCountMap().get(resultLabel);
        return (result != null) ? result : 0;
    }

    private HashMap<String, Long> getCountMap() {
        if (this.countMap == null) {
            this.countMap = new HashMap<String, Long>();
            if (this.label != null && this.count != null) {
                for (int i = 0; i < this.label.size(); i++) {
                    this.countMap.put((String) this.label.get(i),
                            (Long) this.count.get(i));
                }
            }
        }
        return this.countMap;
    }
}
