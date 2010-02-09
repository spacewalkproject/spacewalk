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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.CSVWriter;
import com.redhat.rhn.common.util.ExportWriter;
import com.redhat.rhn.common.util.ServletExportHandler;
import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.frontend.context.Context;
import com.redhat.rhn.frontend.dto.monitoring.TimeSeriesData;
import com.redhat.rhn.frontend.graphing.GraphGenerator;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.monitoring.MonitoringManager;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.JFreeChart;

import java.io.IOException;
import java.io.StringWriter;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Action for the probe details page. Note that there is no correpsonding 
 * SetupAction since there isn't really a good separation between setup
 * and performing the action.
 * 
 * @version $Rev: 54016 $
 */
public class ProbeGraphAction extends BaseProbeAction {    
    
    public static final int DEFAULT_CHART_HEIGHT = 240;
    public static final int DEFAULT_CHART_WIDTH = 800;
    public static final String MIME_TYPE = "image/png";
    
    private Logger log = Logger.getLogger(ProbeGraphAction.class);
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest req, HttpServletResponse resp) throws Exception {
        
        RequestContext rctx = new RequestContext(req);
        Probe probe = rctx.lookupProbe();
        String[] metrics = req.getParameterValues(METRICS);
        
        Long start = rctx.getParamAsLong(STARTTS);
        Long end = rctx.getParamAsLong(ENDTS);
        
        if (start == null || end == null) {
            log.debug("No start or end date passed into execute()");
            return null;
        }

        Timestamp startts = new Timestamp(start.longValue());
        Timestamp endts = new Timestamp(end.longValue());
        
        List tsdList =  MonitoringManager.getInstance().getProbeDataList(probe, metrics, 
                startts, endts);
        
        if (rctx.isRequestedExport()) {
            writeExport(tsdList, resp, metrics);
        } 
        else {
            writeGraph(tsdList, resp, req, metrics, startts, endts);
        }
        return null;
    }
    
    private void writeGraph(List tsdList, HttpServletResponse resp, 
            HttpServletRequest req, String[] metrics, Timestamp startts, Timestamp endts) 
                throws IOException {
        Context ctx = Context.getCurrentContext();
        String timeZoneLabel = ctx.getTimezone().getDisplayName(ctx.getLocale());
        String yAxisLabel = LocalizationService.getInstance().
            getMessage("probedetails.graph.yAxis");
        String xAxisLabel;
        if (tsdList.size() > 0) {
            xAxisLabel = timeZoneLabel;
        } 
        else {
            xAxisLabel = LocalizationService.getInstance().
            getMessage("probedetails.graph.noprobedata");
        }
        Map labelMap = getMetricLabels(req, metrics);
        // Add blank start and finish values so we show the full range of the 
        // graph.  This modifies the data when the user selected a date range
        // larger than the data stored with this probe.
        tsdList = addStartandEndData(tsdList, startts, endts, metrics);
        
        JFreeChart chart = GraphGenerator.getInstance().
            generateJFReeChart(DEFAULT_CHART_WIDTH, 
                    DEFAULT_CHART_HEIGHT, xAxisLabel, yAxisLabel, tsdList, labelMap);
        
        if (log.isDebugEnabled()) { 
            // We can turn debug on for this class and stick the graph
            // files in /tmp/chart892380980923409.png
            log.debug("Dumping graph file to /tmp");
            GraphGenerator.getInstance().generateGraphFile(
                 chart, DEFAULT_CHART_WIDTH, DEFAULT_CHART_HEIGHT);        
        }
        writeChartToResponse(chart, resp);
    }

    private void writeExport(List tsdList, HttpServletResponse resp, 
            String[] metrics) throws IOException {
        Iterator i = tsdList.iterator();
        while (i.hasNext()) {
            TimeSeriesData[] tsdarr = (TimeSeriesData[]) i.next();
            List dtoList = Arrays.asList(tsdarr);
            List columns = new LinkedList();
            columns.add("oid");
            columns.add("data");
            columns.add("time");
            columns.add("metric");
            ExportWriter ew = new CSVWriter(new StringWriter());
            ew.setColumns(columns);
            ServletExportHandler seh = new ServletExportHandler(ew);
            seh.writeExporterToOutput(resp, dtoList);
        }
    }

    private Map getMetricLabels(HttpServletRequest req, String[] metrics) {
        Map retval = new HashMap();
        // Some Probes have no metrics (General: Check Nothing)
        if (metrics != null) {
            for (int i = 0; i < metrics.length; i++) {
                String key = ProbeDetailsAction.L10NKEY + metrics[i];
                retval.put(metrics[i], req.getParameter(key));
            }
        }
        return retval;
    }

    // Add blank values to the start and end of the graph if we need to.
    private List addStartandEndData(List timeSeriesList, Timestamp startTime, 
            Timestamp endTime, String[] metrics) {
        
        List retval = new LinkedList();
        if (metrics != null) {
            for (int i = 0; i < metrics.length; i++) {
                if (timeSeriesList.size() > i) {
                    TimeSeriesData[] tsd = (TimeSeriesData[]) timeSeriesList.get(i);
                    retval.add(padProbeData(tsd, startTime, endTime, metrics[i]));
                }
            }
        }
        return retval;
    }
    
    // Do the grunt work of adding the 2 entries to the array.  This might do some
    // System.arrayCopy()s so if we find performance with large graphsets is causing
    // problems we should look here.
    private TimeSeriesData[] padProbeData(TimeSeriesData[] tsd, Timestamp startTime, 
            Timestamp endTime, String metricId) {
        List retval = new LinkedList(Arrays.asList(tsd));
        
        // Here we determine if we need to add a blank bit of data
        // at the beginning and end of the data 
        if (tsd.length >= 2) {
            TimeSeriesData first = tsd[0];
            TimeSeriesData last = tsd[tsd.length - 1];
            // We want to pad the start and end dates by 5 minutes so
            // we don't add space at the start and beginning 
            Calendar pcal = Calendar.getInstance();
            pcal.setTime(startTime);
            pcal.roll(Calendar.MINUTE, 5);
            
            if (first.getTime().after(pcal.getTime())) {
                log.debug("Adding start padding  : " + startTime);
                TimeSeriesData firstPad = 
                    new TimeSeriesData(null, null, startTime, metricId);
                retval.add(0, firstPad);
            }
            pcal.setTime(endTime);
            pcal.roll(Calendar.MINUTE, -5);
            if (last.getTime().before(pcal.getTime())) {
                log.debug("Adding end padding : " + endTime);
                TimeSeriesData lastPad = 
                    new TimeSeriesData(null, null, endTime, metricId);
                retval.add(retval.size() - 1, lastPad);
            }
        }
        return (TimeSeriesData[]) retval.toArray(new TimeSeriesData[0]);
    }
    
    // Write the Chart to the Response
    private void writeChartToResponse(JFreeChart chartIn, HttpServletResponse resp) 
        throws IOException {
        resp.setContentType(MIME_TYPE);
        try {
            ChartUtilities.writeChartAsPNG(resp.getOutputStream(),
                    chartIn, DEFAULT_CHART_WIDTH, DEFAULT_CHART_HEIGHT);
        }
        catch (IOException e) {
            log.error("Error writing chart to OutputStream.", e);
            throw e;
        }
    }
}
