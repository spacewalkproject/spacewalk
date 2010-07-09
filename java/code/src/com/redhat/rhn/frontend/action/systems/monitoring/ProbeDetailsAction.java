/**
 * Copyright (c) 2009--2010 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.systems.monitoring;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.monitoring.MonitoringConstants;
import com.redhat.rhn.domain.monitoring.ProbeState;
import com.redhat.rhn.domain.monitoring.ServerProbe;
import com.redhat.rhn.domain.monitoring.command.Metric;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.frontend.action.common.DateRangePicker;
import com.redhat.rhn.frontend.action.common.DateRangePicker.DatePickerResults;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.monitoring.MonitoringManager;

import org.apache.commons.lang.BooleanUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.util.LabelValueBean;

import java.sql.Timestamp;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Action for the probe details page. Note that there is no correpsonding
 * SetupAction since there isn't really a good separation between setup
 * and performing the action.
 *
 * @version $Rev$
 */
public class ProbeDetailsAction extends BaseProbeAction implements Listable {

    public static final String IS_SUITE_PROBE = "is_suite_probe";
    public static final String SHOW_LOG = "show_log";
    public static final String SHOW_GRAPH = "show_graph";
    public static final String SELECTED_METRICS = "selected_metrics";
    public static final String SELECTED_METRICS_STRING = "selected_metrics_string";
    public static final String L10NED_SELECTED_METRICS_STRING =
            "l10ned_selected_metrics_string";
    public static final String L10NKEY = "l10nmetric_";


    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest req, HttpServletResponse resp) {

        RequestContext rctx = new RequestContext(req);
        ServerProbe probe = (ServerProbe) rctx.lookupProbe();

        if (probe.getTemplateProbe() != null) {
            req.setAttribute(IS_SUITE_PROBE, Boolean.TRUE);
        }
        else {
            req.setAttribute(IS_SUITE_PROBE, Boolean.FALSE);
        }
        Server server = rctx.lookupAndBindServer();
        DynaActionForm form = (DynaActionForm) formIn;

        boolean showGraph = BooleanUtils.toBoolean((Boolean) form.get(SHOW_GRAPH));
        boolean showLog = BooleanUtils.toBoolean((Boolean) form.get(SHOW_LOG));
        // Process the dates, default the start date to yesterday
        // and end date to today.
        Calendar today = Calendar.getInstance();
        today.setTime(new Date());
        Calendar yesterday = Calendar.getInstance();
        yesterday.setTime(new Date());
        yesterday.add(Calendar.DAY_OF_YEAR, -1);

        DateRangePicker picker = new DateRangePicker(form, req, yesterday.getTime(),
                today.getTime(),
                DatePicker.YEAR_RANGE_NEGATIVE,
                "probedetails.jsp.start_date",
                "probedetails.jsp.end_date");
        DatePickerResults dates = picker.processDatePickers(isSubmitted(form));
        ActionMessages errors = dates.getErrors();

        // Setup the Metrics array
        Map l10nmetrics = new HashMap();
        Metric[] marray = (Metric[])
            probe.getCommand().getMetrics().toArray(new Metric[0]);
        LabelValueBean[] metrics = new LabelValueBean[marray.length];
        for (int i = 0; i < marray.length; i++) {
            String label = LocalizationService.getInstance().
                getMessage("metrics." + marray[i].getLabel());
            metrics[i] = new LabelValueBean(
                    label, marray[i].getMetricId());
            l10nmetrics.put(marray[i].getMetricId(), label);
        }
        form.set(METRICS, metrics);
        req.setAttribute(METRICS, metrics);
        // Setup and deal with selected metrics.
        // Always have the 1st one selected
        String[] selectedMetrics = new String[0];
        if (marray.length > 0) {
            if (form.get(SELECTED_METRICS) == null ||
                    ((String[]) form.get(SELECTED_METRICS)).length <= 0) {
                selectedMetrics = new String[1];
                selectedMetrics[0] = marray[0].getMetricId();
                form.set(SELECTED_METRICS, selectedMetrics);
            }
            else {
                selectedMetrics = (String[]) form.get(SELECTED_METRICS);
            }
        }
        req.setAttribute(SELECTED_METRICS, selectedMetrics);

        if (showLog || showGraph) {
            boolean valid = errors.isEmpty();

            if (valid && showGraph) {
                // Setup the graphing specific parameters so we can
                // fill out the URL on details.jsp to the ProbeGraphAction
                StringBuffer ssString = new StringBuffer();
                // We also need to localize the labels so we can
                // pass them into ProbeGraphAction so it can localize
                // the metric lables within the graph itself.
                StringBuffer l10nString = new StringBuffer();
                // Here we concat together the selected metrics
                // so we don't have to do this in the JSP.  The graphing
                // Action can take multiple metrics so we just concat them together
                for (int i = 0; i < selectedMetrics.length; i++) {
                    ssString.append("metrics=");
                    ssString.append(selectedMetrics[i]);
                    ssString.append("&");
                    l10nString.append(L10NKEY + selectedMetrics[i]);
                    l10nString.append("=");
                    l10nString.append((String) l10nmetrics.get(selectedMetrics[i]));
                    l10nString.append("&");
                }
                req.setAttribute(SELECTED_METRICS_STRING, ssString.toString());
                req.setAttribute(L10NED_SELECTED_METRICS_STRING, l10nString.toString());
                req.setAttribute(STARTTS,
                        new Long(dates.getStart().getCalendar().getTimeInMillis()));
                req.setAttribute(ENDTS,
                        new Long(dates.getEnd().getCalendar().getTimeInMillis()));
            }
            if (valid && showLog) {
                DataResult dr =
                    MonitoringManager.getInstance().getProbeStateChangeData(probe,
                            new Timestamp(dates.getStart().getCalendar().getTimeInMillis()),
                            new Timestamp(dates.getEnd().getCalendar().getTimeInMillis()));
                req.setAttribute(ListHelper.LIST, dr);
                ListHelper helper = new ListHelper(this, req);
                helper.execute();
            }
        }

        if (!errors.isEmpty()) {
            addErrors(req, errors);
        }
        req.setAttribute("probe", probe);
        req.setAttribute("system", server);

        if (probe.getState() == null || probe.getState().getOutput() == null) {
            req.setAttribute("status",
               LocalizationService.getInstance().getMessage("probe.empty.status"));
        }
        else {
            ProbeState state = probe.getState();
            String statusString = LocalizationService.getInstance().
                getMessage(state.getState());
            if (!StringUtils.isBlank(state.getOutput())) {
                statusString = statusString + ", " + state.getOutput();
            }
            statusString = StringUtil.htmlifyText(statusString);
            req.setAttribute("status", statusString);
            if (probe.getState().getState().
                    equals(MonitoringConstants.PROBE_STATE_UNKNOWN)) {
                req.setAttribute("status_class", "probe-status-unknown");
            }
            else if (probe.getState().getState().
                    equals(MonitoringConstants.PROBE_STATE_CRITICAL)) {
                req.setAttribute("status_class", "probe-status-critical");
            }

        }

        req.setAttribute(SHOW_GRAPH, Boolean.valueOf(showGraph));
        req.setAttribute(SHOW_LOG, Boolean.valueOf(showLog));
        return mapping.findForward("default");
    }

    /**
     * part of the Listable interface
     * {@inheritDoc}
     */
    public List getResult(RequestContext context) {
        return (List)context.getRequest().getAttribute(ListHelper.LIST);
    }

}
