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
import java.util.Enumeration;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;
import org.directwebremoting.util.Logger;

import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcFault;

import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.frontend.action.common.DateRangePicker;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;

/**
 * XccdfSearchAction
 */
public class XccdfSearchAction extends RhnAction {

    private static final String SEARCH_STRING = "search_string";
    private static final String WHERE_TO_SEARCH = "whereToSearch";
    private static final String SCAN_DATE_SEARCH = "optionScanDateSearch";
    private static Logger log = Logger.getLogger(XccdfSearchAction.class);

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response) {
        ActionErrors errors = new ActionErrors();
        DynaActionForm form = (DynaActionForm) formIn;
        String searchString = request.getParameter(SEARCH_STRING);

        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());

        if (!isSubmitted(form)) {
            try {
                setupForm(request, form);
                return getStrutsDelegate().forwardParams(
                    mapping.findForward(RhnHelper.DEFAULT_FORWARD),
                    request.getParameterMap());
            }
            catch (XmlRpcException xre) {
                log.error("Could not connect to search server.", xre);
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("packages.search.connection_error"));
            }
            catch (XmlRpcFault e) {
                log.info("Caught Exception :" + e);
                log.info("ErrorCode = " + e.getErrorCode());
                e.printStackTrace();
                if (e.getErrorCode() == 100) {
                    log.error("Invalid search query", e);
                    errors.add(ActionMessages.GLOBAL_MESSAGE,
                            new ActionMessage("packages.search.could_not_parse_query",
                                    searchString));
                }
                else if (e.getErrorCode() == 200) {
                    log.error("Index files appear to be missing: ", e);
                    errors.add(ActionMessages.GLOBAL_MESSAGE,
                            new ActionMessage("packages.search.index_files_missing",
                                    searchString));
                }
                else {
                    errors.add(ActionMessages.GLOBAL_MESSAGE,
                            new ActionMessage("packages.search.could_not_execute_query",
                                    searchString));
                }
            }
            catch (MalformedURLException e) {
                log.error("Could not connect to server.", e);
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("packages.search.connection_error"));
            }
       }

       if (!errors.isEmpty()) {
           addErrors(request, errors);
           return getStrutsDelegate().forwardParams(
                   mapping.findForward(RhnHelper.DEFAULT_FORWARD),
                   createForwardParams(request));
       }
       return getStrutsDelegate().forwardParams(
               mapping.findForward("success"),
               createForwardParams(request));
    }

    private void setupForm(HttpServletRequest request, DynaActionForm form)
            throws MalformedURLException, XmlRpcException, XmlRpcFault {
        RequestContext context = new RequestContext(request);
        String searchString = request.getParameter(SEARCH_STRING);
        String whereToSearch = request.getParameter(WHERE_TO_SEARCH);

        request.setAttribute(SEARCH_STRING, searchString);
        form.set(WHERE_TO_SEARCH,
                "system_list".equals(whereToSearch) ? whereToSearch : "all");
        DateRangePicker picker = setupDatePicker(form, request);

        if (!StringUtils.isBlank(searchString)) {
            picker.processDatePickers(getOptionScanDateSearch(request), false);
            List results = XccdfSearchHelper.performSearch(searchString, whereToSearch,
                getPickerDate(request, "start"), getPickerDate(request, "end"), context);
            request.setAttribute(RequestContext.PAGE_LIST,
                    results != null ? results : Collections.EMPTY_LIST);
        }
        else {
            request.setAttribute(RequestContext.PAGE_LIST, Collections.EMPTY_LIST);
            picker.processDatePickers(false, false);
        }
    }

    private Map createForwardParams(HttpServletRequest request) {
        Map forwardParams = makeParamMap(request);
        // keep all params except submitted, in order for the new list
        // tag pagination to work we need to pass along all the formvars it
        // generated.
        Enumeration paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String name = (String) paramNames.nextElement();
            if (!SUBMITTED.equals(name)) {
                forwardParams.put(name, request.getParameter(name));
            }
        }
        return forwardParams;
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
        String strDateSearch = request.getParameter(SCAN_DATE_SEARCH);
        return "on".equals(strDateSearch);
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
}
