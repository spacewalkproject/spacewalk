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
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.domain.action.scap.ScapAction;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.XccdfIdentDto;
import com.redhat.rhn.frontend.dto.XccdfRuleResultDto;
import com.redhat.rhn.frontend.dto.XccdfTestResultDto;
import com.redhat.rhn.manager.BaseManager;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

/**
 * ScapManager
 * @version $Rev$
 */
public class ScapManager extends BaseManager {

    private static final List<String> SEARCH_TERM_PRECEDENCE = Arrays.asList(
            "slabel", "start", "end", "result");

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
     * Show brief results of all scans accessible by user.
     * Sorted by date, descending.
     * @param user The user requesting the data.
     * @param systemId The id of system
     * @return The list of scan results.
     */
    public static List<XccdfTestResultDto> latestTestResultByServerId(
            User user, Long systemId) {
        SelectMode m = ModeFactory.getMode("scap_queries",
                "latest_testresults_by_server");
        HashMap<String, Long> params = new HashMap<String, Long>();
        params.put("user_id", user.getId());
        params.put("sid", systemId);
        return m.execute(params);
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
     * Get xccdf:rule-results by ident's ids
     * @param inParams direct parameters for query.
     * user_id is the only compulsory
     * @param identIds list of xccdf:ident ids
     * @return the result
     */
    public static List<XccdfRuleResultDto> ruleResultsByIdentIds(Map inParams,
            List<Long> identIds) {
        String modeName = "rr_by_idents";
        for (String term : SEARCH_TERM_PRECEDENCE) {
            if (inParams.containsKey(term)) {
                modeName += "_" + term;
            }
        }
        SelectMode m = ModeFactory.getMode("scap_queries", modeName);
        return m.execute(inParams, identIds);
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

    /**
     * Show scap capable systems which are currently in SSM
     * @param scheduler user requesting the systems
     * @return the list of systems in SSM
     */
    public static DataResult scapCapableSystemsInSsm(User scheduler) {
        SelectMode m = ModeFactory.getMode("scap_queries",
                "scap_capable_systems_in_set");
        HashMap params = new HashMap();
        params.put("user_id", scheduler.getId());
        params.put("set_label", RhnSetDecl.SYSTEMS.getLabel());
        return m.execute(params);
    }

    /**
     * Show systems in SSM and their true/false scap capability
     * @param scheduler user requesting the systems
     * @return the list of systems in SSM
     */
    public static DataResult systemsInSsmAndScapCapability(User scheduler) {
        SelectMode m = ModeFactory.getMode("scap_queries",
                "systems_in_set_and_scap_capability");
        HashMap params = new HashMap();
        params.put("user_id", scheduler.getId());
        params.put("set_label", RhnSetDecl.SYSTEMS.getLabel());
        return m.execute(params);
    }

    /**
     * Schedule scap.xccdf_eval action for systems in user's SSM.
     * @param scheduler user which commits the schedule
     * @param path path to xccdf document on systems file system
     * @param parameters additional parameters for xccdf scan
     * @param earliest time of earliest action occurence
     * @return the newly created ScapAction
     */
    public static ScapAction scheduleXccdfEvalInSsm(User scheduler, String path,
            String parameters, Date earliest) {
        HashSet<Long> systemIds = idsInDataResultToSet(scapCapableSystemsInSsm(scheduler));
        return ActionManager.scheduleXccdfEval(
                scheduler, systemIds, path, parameters, earliest);
    }

    /**
     * Check if the user has permission to see the XCCDF scan.
     * @param user User being checked.
     * @param testResultId ID of XCCDF scan being checked.
     * @throws LookupException if user cannot access the scan.
     */
    public static void ensureAvailableToUser(User user, Long testResultId) {
        if (!isAvailableToUser(user, testResultId)) {
            throw new LookupException("Could not find XCCDF scan " +
                    testResultId + " for user " + user.getId());
        }
    }

    /**
     * Return list of possible results of xccdf:rule evaluation
     * @return the result
     */
    public static List<Map<String, String>> ruleResultTypeLabels() {
        return ModeFactory.getMode("scap_queries", "result_type_labels").execute();
    }

    /**
     * Checks if the user has permission to see the XCCDF scan.
     * @param user User being checked.
     * @param testResultId ID of the XCCDF scan being checked.
     * @retutn true if the user can access the TestResult, false otherwise.
     */
    private static boolean isAvailableToUser(User user, Long testResultId) {
        SelectMode m = ModeFactory.getMode("scap_queries",
                "is_available_to_user");
        HashMap<String, Long> params = new HashMap<String, Long>();
        params.put("user_id", user.getId());
        params.put("xid", testResultId);
        return m.execute(params).size() >= 1;
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

    private static HashSet<Long> idsInDataResultToSet(DataResult dataIn) {
        HashSet<Long> result = new HashSet<Long>();
        for (Map<String, Long> map : (List<Map<String, Long>>) dataIn) {
            result.add(map.get("id"));
        }
        return result;
    }

}
