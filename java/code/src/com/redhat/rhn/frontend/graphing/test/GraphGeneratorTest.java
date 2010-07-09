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

package com.redhat.rhn.frontend.graphing.test;

import com.redhat.rhn.frontend.context.Context;
import com.redhat.rhn.frontend.dto.monitoring.TimeSeriesData;
import com.redhat.rhn.frontend.graphing.GraphGenerator;
import com.redhat.rhn.manager.monitoring.test.MonitoringManagerTest;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.jfree.chart.JFreeChart;

import java.io.File;
import java.util.Calendar;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;

/**
 * GraphGeneratorTest
 * @version $Rev: 49534 $
 */

public class GraphGeneratorTest extends RhnBaseTestCase {

    /**
     * {@inheritDoc}
     */
    protected void setUp() throws Exception {
        super.setUp();
        Context ctx = Context.getCurrentContext();
        ctx.setTimezone(TimeZone.getDefault());
        ctx.setLocale(Locale.getDefault());

    }

    /**
     * {@inheritDoc}
     */
    protected void tearDown() throws Exception {
        super.tearDown();
        Context.freeCurrentContext();
    }

    public void testMakeGraphFile() throws Exception {
        File f = GraphGenerator.getInstance().generateGraphFile(
                makeTestGraph(20), 800, 240);
        assertNotNull(f.getAbsolutePath());
        // f.deleteOnExit();
    }

    public void testEmptyGraphFile() throws Exception {
        File f = GraphGenerator.getInstance().generateGraphFile(
                makeTestGraph(0), 800, 240);
        assertNotNull(f.getAbsolutePath());
        f.deleteOnExit();
    }

    public void testMakeJFreeChart() throws Exception {
        JFreeChart chart = makeTestGraph(20);
        assertNotNull(chart);
    }

    private TimeSeriesData[] getTestTimeSeriesData(String metric, int size) {
        TimeSeriesData[] tsd = new TimeSeriesData[size];
        for (int i = 0; i < tsd.length; i++) {
           Calendar start = Calendar.getInstance();
           start.roll(Calendar.HOUR, -3);
           start.add(Calendar.MINUTE, (i * 5));
           Float rnd = new Float(Math.random() * 10);
           tsd[i] = new TimeSeriesData("1-2-test", rnd, start.getTime(),
                   metric);
        }
        return tsd;
    }
    public JFreeChart makeTestGraph(int size) {
        TimeSeriesData[] tsd1 =
            getTestTimeSeriesData(MonitoringManagerTest.TEST_METRIC, size);
        TimeSeriesData[] tsd2 =
            getTestTimeSeriesData(MonitoringManagerTest.TEST_METRIC2, size);
        List tsdList = new LinkedList();
        tsdList.add(tsd1);
        tsdList.add(tsd2);
        Map labels = new HashMap();
        labels.put(MonitoringManagerTest.TEST_METRIC,
                "l10ned" + MonitoringManagerTest.TEST_METRIC);
        labels.put(MonitoringManagerTest.TEST_METRIC2,
                "l10ned" + MonitoringManagerTest.TEST_METRIC2);
        JFreeChart chart = GraphGenerator.getInstance().
            generateJFReeChart(800, 240, "Time (PST)"  , "Metrics", tsdList, labels);
        return chart;
    }

}


