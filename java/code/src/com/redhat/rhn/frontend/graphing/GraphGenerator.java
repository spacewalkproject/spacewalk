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
package com.redhat.rhn.frontend.graphing;

import com.redhat.rhn.frontend.context.Context;
import com.redhat.rhn.frontend.dto.monitoring.TimeSeriesData;

import org.apache.log4j.Logger;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.JFreeChart;
import org.jfree.data.time.Minute;
import org.jfree.data.time.TimeSeries;
import org.jfree.data.time.TimeSeriesCollection;
import org.jfree.data.xy.XYDataset;

import java.io.File;
import java.io.IOException;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * GraphGenerator - Generates a graph JPG with the passed in parameters.  Places
 * the file in the java.io.tmpdir system property location.
 *
 * @version $Rev$
 */
public class GraphGenerator {

    private Logger log = Logger.getLogger(GraphGenerator.class);
    private static GraphGenerator instance = new GraphGenerator();

    /**
     * Create new GraphGenerator
     */
    private GraphGenerator() {

    }

    /**
     * Get the instance of the GraphGenerator
     * @return the GraphGenerator
     */
    public static GraphGenerator getInstance() {
        return instance;
    }

    /**
     * Generate a graph, store it to the java.io.tmpdir and
     * return a java.io.File object pointer to the file itself.
     *
     * @param chartIn chart we want to save as a File
     * @param height height in pixels of the image generated
     * @param width in pixels of the image generated
     * @return java.io.File representation of the graph
     */
    public File generateGraphFile(JFreeChart chartIn, int height, int width) {
        File retval = null;
        try {
            log.debug("Generating graph with title: ");
            String tmpDir = System.getProperty("java.io.tmpdir");
            StringBuffer fname = new StringBuffer();
            fname.append(tmpDir);
            fname.append("/chart");
            fname.append(System.currentTimeMillis());
            fname.append(".png");
            retval = new File(fname.toString());
            ChartUtilities.saveChartAsPNG(retval, chartIn, height,
                    width);
        }
        catch (IOException ioe) {
            log.error("Error generating graph: " + ioe, ioe);
        }
        return retval;
    }

    /**
     * Generate a JFreeChart class from specified parameters.
     *
     * @param height height in pixels of the image generated
     * @param width in pixels of the image generated
     * @param xAxisLabel label for the x axis
     * @param yAxisLabel label for the y axis
     * @param timeSeriesData List of TimeSeriesData[] DTO objects
     * @param labelMap a map containing the localized labels used
     *        for the metrics.  Contains simple "metricId" keys
     *        with the localized Strings as the value.  For example:
     *        labelMap={"pctfree" -> "Percent Free", "memused" -> "Memory Used"}
     * @return JFreeChart representation
     */
    public JFreeChart generateJFReeChart(int height, int width, String xAxisLabel,
            String yAxisLabel, List timeSeriesData, Map labelMap) {

        if (Context.getCurrentContext() == null ||
                Context.getCurrentContext().getTimezone() == null ||
                Context.getCurrentContext().getLocale() == null) {
            throw new IllegalArgumentException("Context, Timezone or Locale is " +
                    "NULL in the Context.  Please make sure it has been set.");
        }

        XYDataset jfreeDataset = createDataset(timeSeriesData, labelMap);
        JFreeChart chart = ChartFactory.createTimeSeriesChart(
                null, // title
                xAxisLabel, // x-axis label
                yAxisLabel, // y-axis label
                jfreeDataset, // data
                true, // create legend?
                true, // generate tooltips?
                false // generate URLs?
                );
        // TODO: If we need to force time formats
        // this is how we do it.  Leaving out for now.
        /*XYPlot plot = chart.getXYPlot();
        DateAxis axis = (DateAxis) plot.getDomainAxis();
        Context ctx = Context.getCurrentContext();

        String graphDateFormat = "yyyy-MM-dd h:mm a";
        SimpleDateFormat sdf = new SimpleDateFormat(
                graphDateFormat, ctx.getLocale());
        axis.setDateFormatOverride(sdf);*/

        return chart;

    }

    /**
     * Format the RHN TimeSeriesData DTO into a JFree format.
     * @param List of DTO objects
     * @param labelMap a map containing the localized labels used
     *        for the metrics.  Contains simple "metricId" keys
     *        with the localized Strings as the value.  For example:
     *        labelMap={"pctfree" -> "Percent Free", "memused" -> "Memory Used"}
     * @return JFree object collection of data and time values
     */
    private static XYDataset createDataset(List dataIn, Map labelMap) {
        TimeSeriesCollection dataset =
            new TimeSeriesCollection(Context.getCurrentContext().getTimezone());

        Iterator itr = dataIn.iterator();
        while (itr.hasNext()) {
            TimeSeriesData[] data = (TimeSeriesData[]) itr.next();
            if (data.length > 0) {
                TimeSeries s1 = new TimeSeries(
                        (String) labelMap.get(data[0].getMetric()), Minute.class);
                for (int i = 0; i < data.length; i++) {
                    Minute m1 = new Minute(data[i].getTime());
                    s1.addOrUpdate(m1, data[i].getData());
                }
                dataset.addSeries(s1);
            }
        }
        dataset.setDomainIsPointsInTime(true);
        return dataset;

    }

}
