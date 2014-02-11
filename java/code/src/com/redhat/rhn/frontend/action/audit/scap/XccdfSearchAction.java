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
package com.redhat.rhn.frontend.action.audit.scap;

import java.net.MalformedURLException;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcFault;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.frontend.action.BaseSearchAction;
import com.redhat.rhn.frontend.action.common.DateRangePicker;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.manager.audit.ScapManager;

/**
 * XccdfSearchAction
 */
public class XccdfSearchAction extends BaseSearchAction {

    private static final String ANY_LABEL = "any";
    private static final String SHOW_AS = "show_as";
    private static final String TESTRESULT_ID = "tr";
    private static final String RULERESULT_ID = "rr";

    protected ActionForward doExecute(HttpServletRequest request, ActionMapping mapping,
                    DynaActionForm form)
            throws MalformedURLException, XmlRpcException, XmlRpcFault {
        RequestContext context = new RequestContext(request);
        String searchString = form.getString(SEARCH_STR);
        String whereToSearch = form.getString(WHERE_TO_SEARCH);

        DateRangePicker picker = setupDatePicker(form, request);

        if (!StringUtils.isBlank(searchString)) {
            picker.processDatePickers(getOptionScanDateSearch(request), false);
            DataResult results = XccdfSearchHelper.performSearch(searchString,
                whereToSearch, getPickerDate(request, "start"),
                getPickerDate(request, "end"), getRuleResultLabel(form),
                isTestestResultRequested(form), context);
            request.setAttribute(RequestContext.PAGE_LIST,
                    results != null ? results : Collections.EMPTY_LIST);
            if (isTestestResultRequested(form) && results != null) {
                TagHelper.bindElaboratorTo("searchResultsTr", results.getElaborator(),
                        request);
            }
        }
        else {
            request.setAttribute(RequestContext.PAGE_LIST, Collections.EMPTY_LIST);
            picker.processDatePickers(false, false);
        }
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    private Date getPickerDate(HttpServletRequest request, String paramName) {
        if (getOptionScanDateSearch(request)) {
            DatePicker dPick = (DatePicker)request.getAttribute(paramName);
            if (dPick != null) {
                return dPick.getDate();
            }
        }
        return null;
    }

    private Boolean getOptionScanDateSearch(HttpServletRequest request) {
        Object dateSrch = request.getAttribute(SCAN_DATE_SEARCH);
        if (dateSrch instanceof Boolean) {
            return ((Boolean)dateSrch).booleanValue();
        }
        else {
            String strDateSearch = (String)request.getAttribute(SCAN_DATE_SEARCH);
            return "on".equals(strDateSearch);
        }
    }

    private DateRangePicker setupDatePicker(DynaActionForm form,
            HttpServletRequest request) {
        Calendar today = Calendar.getInstance();
        today.setTime(new Date());
        Calendar yesterday = (Calendar) today.clone();
        yesterday.add(Calendar.DAY_OF_YEAR, -1);
        return new DateRangePicker(form, request, yesterday.getTime(), today.getTime(),
                DatePicker.YEAR_RANGE_NEGATIVE, "scapsearch.jsp.start_date",
                "scapsearch.jsp.end_date");
    }

    private boolean isTestestResultRequested(DynaActionForm form) {
        String showAs = form.getString(SHOW_AS);
        if (showAs == null ||
                RULERESULT_ID.equals(showAs) || "".equals(showAs)) {
            return false;
        }
        return true;
    }

    private void setupShowAsOption(DynaActionForm form) {
        String showAs = form.getString(SHOW_AS);
        form.set(SHOW_AS,
                TESTRESULT_ID.equals(showAs) ? showAs : RULERESULT_ID);
    }

    private String getRuleResultLabel(DynaActionForm form) {
        String resultFilter = form.getString("result_filter");
        if (resultFilter == null ||
                ANY_LABEL.equals(resultFilter) || "".equals(resultFilter)) {
            return null;
        }
        return resultFilter;
    }

    private void setupRuleResultLabelOptions(HttpServletRequest request) {
        List<Map<String, String>> possibleResults = ScapManager.ruleResultTypeLabels();
        Map<String, String> anyLabel = new HashMap<String, String>();
        anyLabel.put("label", ANY_LABEL);
        possibleResults.add(0, anyLabel);

        request.setAttribute("allResults", possibleResults);
    }

    @Override
    protected void insureFormDefaults(HttpServletRequest request, DynaActionForm form) {
        String searchString = form.getString(SEARCH_STR);
        String whereToSearch = form.getString(WHERE_TO_SEARCH);

        request.setAttribute(SEARCH_STR, searchString);
        form.set(WHERE_TO_SEARCH,
                "system_list".equals(whereToSearch) ? whereToSearch : "all");
        setupRuleResultLabelOptions(request);
        setupShowAsOption(form);
        Map m = form.getMap();
        Set<String> keys = (Set<String>)m.keySet();
        for (String key : keys) {
            Object vObj = m.get(key);
            request.setAttribute(key, vObj);
        }
    }
}
