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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import com.redhat.rhn.frontend.dto.XccdfRuleResultDto;
import com.redhat.rhn.manager.audit.ScapManager;

/**
 * RuleResultDiffer - Facility for comparison of xccdf:rule-result-s
 * assigned with given xccdf:TestResult-s
 */
public class RuleResultDiffer {
    private HashMap<String, RuleResultComparator> dataMap;

    /**
     * Constructor
     * @param firstTestResultId id of TestResult to compare
     * @param secondTestResultId id of TestResult to compare
     */
    public RuleResultDiffer(Long firstTestResultId, Long secondTestResultId) {
        dataMap = new HashMap<String, RuleResultComparator>();
        addFirstList(ScapManager.ruleResultsPerScan(firstTestResultId));
        addSecondList(ScapManager.ruleResultsPerScan(secondTestResultId));
    }

    private void addFirstList(List<XccdfRuleResultDto> listIn) {
        for (XccdfRuleResultDto rule : listIn) {
            String idref = rule.getDocumentIdref();
            if (dataMap.containsKey(idref)) {
                throw new IllegalArgumentException("Multiple rules with idref=" + idref);
            }
            dataMap.put(idref, new RuleResultComparator(rule));
        }
    }

    private void addSecondList(List<XccdfRuleResultDto> listIn) {
        for (XccdfRuleResultDto rule : listIn) {
            String idref = rule.getDocumentIdref();
            RuleResultComparator comp = dataMap.get(idref);
            if (comp == null) {
                comp = new RuleResultComparator(null, rule);
            }
            else {
                comp.addSecond(rule);
            }
            dataMap.put(idref, comp);
        }
    }

    /**
     * Get list of comparators between rule-results
     * @return results
     */
    public List<RuleResultComparator> getData() {
        return new ArrayList<RuleResultComparator>(dataMap.values());
    }

    /**
     * Get list of comparators betwen rule-results (a subset).
     * @param differs defines resulting subset.
     * True - filters out those which does not differ.
     * False - filters out those which differs.
     * @return results
     */
    public List<RuleResultComparator> getData(Boolean differs) {
        List<RuleResultComparator> result = new ArrayList<RuleResultComparator>();
        for (RuleResultComparator item : dataMap.values()) {
            if (item.getDiffers() == differs) {
                result.add(item);
            }
        }
        return result;
    }

    /**
     * Returns the top-level state of rule-result's comparison.
     * @return the state
     * "checked" = no difference
     * "alert" = differences
     * "error" = notable differences (may imply that the second scan is worse)
     */
    public String overallComparison() {
        List<RuleResultComparator> difference = getData(true);
        if (difference.isEmpty()) {
            return "checked";
        }
        for (RuleResultComparator c : difference) {
            if (c.isTheSecondWorse()) {
                return "error";
            }
        }
        return "alert";
    }
}
