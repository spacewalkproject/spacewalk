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
package com.redhat.rhn.manager.audit;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.XccdfIdentDto;
import com.redhat.rhn.frontend.dto.XccdfRuleResultDto;
import com.redhat.rhn.manager.BaseManager;

/**
 * ScapManager
 * @version $Rev$
 */
public class ScapManager extends BaseManager {

    /**
     * Returns the given system is scap enabled.
     * @param server The system for which to seach scap capability
     * @param user The user requesting to view the system
     * @return true if the system is scap capable
     */
    public static boolean isScapEnabled(Server server, User user) {
        SelectMode m = ModeFactory.getMode("scap_queries",
                "system_scap_enabled_check");
        HashMap params = new HashMap();
        params.put("user_id", user.getId());
        params.put("sid", server.getId());
        DataResult<Map<String, ? extends Number>> dr = m.execute(params);
        return dr.get(0).get("count").intValue() > 0;
    }

    /**
     * Show brief results of all scans accessible by user.
     * Sorted by date, descending.
     * @param user The user requesting.
     * @return The list of scan results
     */
    public static DataResult latestTestResultByUser(User user) {
        SelectMode m = ModeFactory.getMode("scap_queries",
                "latest_testresults_by_user");
        HashMap params = new HashMap();
        params.put("user_id", user.getId());
        return makeDataResult(params, new HashMap(), null, m);
    }

    /**
     * Show brief results of all scans for given system
     * @param server The system for which to search
     * @return The list of scan results in brief
     */
    public static List allScans(Server server) {
        SelectMode m = ModeFactory.getMode("scap_queries",
                "show_system_scans");
        HashMap params = new HashMap();
        params.put("sid", server.getId());
        DataResult dr = m.execute(params);
        return transposeView(dr);
    }

    /**
     * Show xccdf:rule-result results for given test
     * @param testResultId of XccdfTestResult of the test for which to search
     * @return the list of rule-results
     */
    public static DataResult ruleResultsPerScan(Long testResultId) {
        SelectMode m = ModeFactory.getMode("scap_queries",
                "show_ruleresults");
        HashMap params = new HashMap();
        params.put("xid", testResultId);
        return m.execute(params);
    }

    /**
     * Get xccdf:rule-result by id
     * @param ruleResultId of the XccdfRuleResult
     * @return the result
     */
    public static XccdfRuleResultDto ruleResultById(Long ruleResultId) {
        SelectMode m = ModeFactory.getMode("scap_queries",
                "ruleresult_by_id");
        HashMap params = new HashMap();
        params.put("rr_id", ruleResultId);
        List<XccdfRuleResultDto> result = m.execute(params);
        return result.isEmpty() ? null : result.get(0);
    }

    /**
     * Show xccdf:ident results for given rule-result
     * @param ruleResultId of XccdfRuleResultDto
     * @return the list of idents
     */
    public static List<XccdfIdentDto> identsPerRuleResult(Long ruleResultId) {
        SelectMode m = ModeFactory.getMode("scap_queries",
                "idents_per_ruleresult");
        HashMap params = new HashMap();
        params.put("rr_id", ruleResultId);
        return m.execute(params);
    }

    private static List<Map<String, Object>> transposeView(DataResult testResultsRaw) {
        List<Map<String, Object>> resultView = new ArrayList<Map<String, Object>>();
        Map<String, Object> currResult = null;
        for (Map row : (DataResult<Map>) testResultsRaw) {
            if (currResult != null &&
                    ((Long) currResult.get("id")).equals(row.get("id"))) {
                String label = (String) row.get("label");
                Long figure = (Long) row.get("figure");
                currResult.put(label, figure);
                currResult.put("sum", ((Long) currResult.get("sum")) + figure);
            }
            else {
                if (currResult != null) {
                    resultView.add(currResult);
                }
                currResult = new HashMap<String, Object>();
                currResult.put("id", row.get("id"));
                currResult.put("testResult", row.get("test_result"));
                currResult.put((String) row.get("label"), row.get("figure"));
                currResult.put("sum", row.get("figure"));
                currResult.put("completionTime", row.get("completion_time"));
            }
        }
        if (currResult != null) {
            resultView.add(currResult);
        }
        return resultView;
    }
}
