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
import com.redhat.rhn.domain.audit.XccdfTestResult;

/**
 * TestResultDiffer - Facility for comparison of xccdf:TestResult
 */
public class TestResultDiffer {
    private static final String DIFFERS = "differs";
    private static final String FIRST = "first";
    private static final String SECOND = "second";

    private TestResultDiffer() { }

    /**
     * Make a full diff of TestResult's metadata
     * @param first the first TestResult to compare
     * @param second the second TestResult to compare
     * @return the diff
     */
    public static List<HashMap<String, Object>> diff(XccdfTestResult first,
            XccdfTestResult second) {
        List<HashMap<String, Object>> result = new ArrayList<HashMap<String, Object>>();
        result.add(buildItem("id", linkToScan(first), linkToScan(second)));
        result.add(buildItem("system.audit.xccdfdetails.jsp.benchmarkid",
                first.getBenchmark().getIdentifier(),
                second.getBenchmark().getIdentifier()));
        result.add(buildItem("system.audit.xccdfdetails.jsp.version",
                first.getBenchmark().getVersion(),
                second.getBenchmark().getVersion()));
        result.add(buildItem("system.audit.xccdfdetails.jsp.profileid",
                first.getProfile().getIdentifier(),
                second.getProfile().getIdentifier()));
        result.add(buildItem("system.audit.xccdfdetails.jsp.title",
                first.getProfile().getTitle(),
                second.getProfile().getTitle()));
        result.add(buildItem("system.audit.xccdfdetails.jsp.path",
                first.getScapActionDetails().getPath(),
                second.getScapActionDetails().getPath()));
        result.add(buildItem("system.audit.schedulexccdf.jsp.arguments",
                first.getScapActionDetails().getParametersContents(),
                second.getScapActionDetails().getParametersContents()));
        result.add(buildItem("systemlist.jsp.system",
                linkToSystemListScap(first), linkToSystemListScap(second)));
        result.add(buildItem("configoverview.jsp.scheduledBy", first
                .getScapActionDetails().getParentAction().getSchedulerUser().getLogin(),
                second.getScapActionDetails().getParentAction().getSchedulerUser()
                .getLogin()));
        result.add(buildItem("system.audit.xccdfdetails.jsp.started",
                first.getStartTime(), second.getStartTime()));
        result.add(buildItem("system.audit.xccdfdetails.jsp.completed",
                first.getEndTime(), second.getEndTime()));
        return result;
    }

    /**
     * Make a subset of diff between TestResult's metadata
     * @param first the first TestResult to compare
     * @param second the second TestResult to compare
     * @param differs defines resulting subset
     * True - filters out items which does not differ
     * False - filters out items which differs
     * @return the result
     */
    public static List<HashMap<String, Object>> diff(XccdfTestResult first,
            XccdfTestResult second, Boolean differs) {
       if (differs == null) {
           return diff(first, second);
       }
       List<HashMap<String, Object>> result = new ArrayList<HashMap<String, Object>>();
       for (HashMap<String, Object> item : diff(first, second)) {
           if (differs.equals(item.get(DIFFERS))) {
               result.add(item);
           }
       }
       return result;
    }

    private static HashMap<String, Object> buildItem(String localizationString,
            Object first, Object second) {
        HashMap<String, Object> item = new HashMap<String, Object>();
        item.put("msg", localizationString);
        item.put(FIRST, first == null ? "" : first);
        item.put(SECOND, second == null ? "" : second);
        item.put(DIFFERS, !item.get(FIRST).equals(item.get(SECOND)));
        return item;
    }

    private static String linkToScan(XccdfTestResult tr) {
        return "<a href=\"/rhn/systems/details/audit/XccdfDetails.do?sid=" +
                tr.getServer().getId() + "&xid=" + tr.getId() + "\">" +
                tr.getId() + "</a>";
    }

    private static String linkToSystemListScap(XccdfTestResult tr) {
        return "<a href=\"/rhn/systems/details/audit/ListScap.do?sid=" +
                tr.getServer().getId() + "\">" + tr.getServer().getName() + "</a>";
    }
}
