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
package com.redhat.rhn.manager.audit.scap;

import com.redhat.rhn.frontend.dto.XccdfRuleResultDto;

/**
 * RuleResultComparator
 * @version $Rev$
 */
public class RuleResultComparator {

    /* The constructors ensure that at least one of the following items is not null. */
    private XccdfRuleResultDto first;
    private XccdfRuleResultDto second;

    /**
     * Constructor
     * @param firstIn xccdf:rule-result to compare
     * @param secondIn xccdf:rule-result to compate
     */
    public RuleResultComparator(XccdfRuleResultDto firstIn, XccdfRuleResultDto secondIn) {
        if (firstIn == null && secondIn == null) {
            throw new IllegalArgumentException();
        }
        first = firstIn;
        addSecond(secondIn);
    }

    /**
     * Constructor
     * @param firstIn xccdf:rule-result to compare. The other is null for now.
     */
    public RuleResultComparator(XccdfRuleResultDto firstIn) {
        if (firstIn == null) {
            throw new IllegalArgumentException();
        }
        first = firstIn;
        second = null;
    }

    /**
     * Add second item for comparison
     * @param secondIn xccdf:rule-result to compare
     */
    public void addSecond(XccdfRuleResultDto secondIn) {
        if (second != null || secondIn == null) {
            throw new IllegalArgumentException();
        }
        if (first != null && second != null &&
                first.getDocumentIdref() !=  second.getDocumentIdref()) {
            throw new IllegalArgumentException();
        }
        second = secondIn;
    }

    /**
     * Get document Idref of xccdf:rule assigned with this comparator
     * @return the idref
     */
    public String getDocumentIdref() {
        return (first != null ? first : second).getDocumentIdref();
    }

    /**
     * Is there difference between first and second
     * @return true if the two rule-result-s differ
     * either on xccdf:idents or result of evaluation
     */
    public Boolean getDiffers() {
        return (first == null || second == null ||
                !first.getLabel().equals(second.getLabel()) ||
                !first.getIdentsString().equals(second.getIdentsString()));
    }

    /**
     * Is there is difference between first and second idents
     * @return true if the two rule-result-s differ only in xccdf:idents
     */
    public Boolean getOnlyIdentDiffers() {
        return getDiffers() && first != null && second != null &&
                first.getLabel().equals(second.getLabel());
    }

    /**
     * Get first xccdf:rule-result
     * @return the answer
     */
    public XccdfRuleResultDto getFirst() {
        return first;
    }

    /**
     * Get second xccdf:rule-result
     * @return the answer
     */
    public XccdfRuleResultDto getSecond() {
        return second;
    }
}
