/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.audit;

import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.frontend.action.common.DateRangePicker;
import com.redhat.rhn.frontend.dto.AuditReviewDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.audit.AuditManager;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;
import org.stringtree.json.JSONWriter;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.Enumeration;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * AuditSearchAction
 * @version $Rev$
 */
public class AuditSearchAction extends RhnAction {

    private static Logger log = Logger.getLogger(AuditSearchAction.class);

    private Long processStartMilli(DynaActionForm dform,
                                   HttpServletRequest request) {
        Calendar yesterday;
        Long startMilli = (Long)dform.get("startMilli");
        String startDisp;

        if (startMilli != null && startMilli >= 0) {
            startDisp = (new Date(startMilli)).toString();
        }
        else {
            yesterday = Calendar.getInstance();
            yesterday.add(Calendar.DAY_OF_YEAR, -7);
            startMilli = yesterday.getTime().getTime();
            startDisp = "<<";
        }

        request.setAttribute("startDisp", startDisp);
        request.setAttribute("startMilli", startMilli);

        return startMilli;
    }

    private Long processEndMilli(DynaActionForm dform,
                                 HttpServletRequest request) {
        Long endMilli = (Long)dform.get("endMilli");
        String endDisp;

        if (endMilli != null && endMilli > 0 && endMilli != Long.MAX_VALUE) {
            endDisp = (new Date(endMilli)).toString();
        }
        else {
            endMilli = Calendar.getInstance().getTime().getTime();
            endDisp = ">>";
        }

        request.setAttribute("endDisp", endDisp);
        request.setAttribute("endMilli", endMilli);

        return endMilli;
    }

    private DateRangePicker.DatePickerResults processTimeArgs(
                DynaActionForm dform,
                HttpServletRequest request,
                Boolean processDates) {
        Date start, end;
        DateRangePicker drp = new DateRangePicker(dform, request,
            new Date(processStartMilli(dform, request)),
            new Date(processEndMilli(dform, request)),
            DatePicker.YEAR_RANGE_NEGATIVE,
            "probedetails.jsp.start_date", "probedetails.jsp.end_date");
        DateRangePicker.DatePickerResults dpresults =
                drp.processDatePickers(processDates);

        if (processDates) { // we need to redo {start,end}{Disp,Milli}
            start = dpresults.getStart().getDate();
            end = dpresults.getEnd().getDate();
            request.setAttribute("startDisp", start.toString());
            request.setAttribute("startMilli", start.getTime());
            request.setAttribute("endDisp", end.toString());
            request.setAttribute("endMilli", end.getTime());
        }

        return dpresults;
    }

    private List prepareAuditTypes() {
        BufferedReader brdr;
        LinkedList<String> typelist;
        Process proc;
        String str = "";

        // set up types for checkboxes
        try { // cache this, maybe...
            proc = Runtime.getRuntime().exec("/sbin/ausearch -m");
            brdr = new BufferedReader(
                new InputStreamReader(proc.getErrorStream()));

            brdr.readLine(); // Argument is required for -m
            str = brdr.readLine(); // Valid message types are: ...
            str = str.substring(str.indexOf(':') + 2);
            brdr.close();
        }
        catch (IOException ioex) {
            log.warn("failed to get ausearch types", ioex);
        }

        typelist = new LinkedList<String>();

        for (String type : str.split(" ")) {
            if (!type.equals("ALL")) {
                typelist.add(type);
            }
        }

        Collections.sort(typelist);

        return typelist;
    }

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        ActionMessages amsgs;
        AuditReviewDto aureview;
        Boolean parseDates, submitted, unrev;
        DateRangePicker.DatePickerResults dpresults;
        DynaActionForm dform = (DynaActionForm)form;
        Enumeration paramNames;
        JSONWriter jsonwr = new JSONWriter();
        List result = null;
        Long start, end;
        Map forwardParams = makeParamMap(request);
        Map<String, String[]> typemap;
        RequestContext requestContext = new RequestContext(request);
        String machine, str;
        String[] autypes;

        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        request.setAttribute("user", requestContext.getLoggedInUser());

        // what audit types are we looking at?
        autypes = dform.getStrings("autypes");
        // what machine are we looking at?
        machine = dform.getString("machine");
        // should we look at the DatePickers?
        parseDates = (Boolean)dform.get("parseDates") != null;
        // did we receive a form with some checkboxes checked?
        submitted = (autypes != null && autypes.length > 0);
        // can we mark this section reviewed?
        unrev = (Boolean)dform.get("unreviewable") != null;

        // handle search times & make displayable versions
        dpresults = processTimeArgs(dform, request, parseDates);

        if (parseDates || unrev) {
            // if we have to process the DatePickers, it means that the user
            // entered a time, which means it's probably not a reviewable
            // section
            unrev = true;
            request.setAttribute("unreviewable", "true");
        }
        else if (!submitted && request.getParameter("machine") != null) {
            log.debug("auto-submit!");
            // this is a click-through from the review list.
            // we skip the search dialog and return the default selection
            submitted = true;
            typemap = AuditManager.getAuditTypeMap();
            autypes = typemap.get("default");
        }

        amsgs = new ActionMessages();
        amsgs.add(dpresults.getErrors()); // possibly empty

        // search?
        if (submitted && dpresults.getErrors().isEmpty()) {
            start = dpresults.getStart().getDate().getTime();
            end = dpresults.getEnd().getDate().getTime();

            // search!
            result = AuditManager.getAuditLogs(autypes, machine, start, end);

            if (result == null) {
                if (!unrev) {
                    // we need to be able to mark reviewable sections as
                    // 'reviewed' even if they're empty
                    result = new LinkedList();
                }
                else {
                    amsgs.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("No results found!", false));
                }
            }

            // check to see if this section has been reviewed
            try {
                aureview = AuditManager.getReviewInfo(machine, start, end);
                // the below may return null, indicating "not reviewed"
                request.setAttribute("reviewedBy", aureview.getReviewedBy());
                request.setAttribute("reviewedOn", aureview.getReviewedOn());
            }
            catch (IOException ioex) {
                // do nothing
            }

            request.setAttribute("autypes", autypes);
            request.setAttribute("machine", machine);
            request.setAttribute("result", result);
        }

        // add any accumulated messages to be displayed
        addMessages(request, amsgs);

        // set up parameters to forward
        paramNames = request.getParameterNames();

        while (paramNames.hasMoreElements()) {
            str = (String) paramNames.nextElement();
            forwardParams.put(str, request.getParameter(str));
        }

        // either the search had no results, so we go back to the search form,
        // or this is what they asked for
        if (result == null) {
            typemap = AuditManager.getAuditTypeMap();
            request.setAttribute("auJsonTypes", jsonwr.write(typemap));
            request.setAttribute("machines", AuditManager.getMachines());
            request.setAttribute("types", prepareAuditTypes());

            // if we processed the DatePickers, reset the "display" times
            // so that the DatePickers are displayed again
            if (parseDates) {
                request.setAttribute("startDisp", "<<");
                request.setAttribute("endDisp", ">>");
            }

            return getStrutsDelegate().forwardParams(
                    mapping.findForward("default"),
                    forwardParams);
        }

        return getStrutsDelegate().forwardParams(
                mapping.findForward("view"),
                forwardParams);
    }
}

// vim: ts=4:expandtab
