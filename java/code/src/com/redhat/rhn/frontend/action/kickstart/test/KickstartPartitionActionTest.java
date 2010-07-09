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
package com.redhat.rhn.frontend.action.kickstart.test;

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.frontend.action.kickstart.KickstartPartitionEditAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;

import org.apache.struts.action.DynaActionForm;

/**
 * KickstartPreActionTest
 * @version $Rev: 1 $
 */
public class KickstartPartitionActionTest extends RhnMockStrutsTestCase {
    private KickstartData ksdata;

    public void setUp() throws Exception {
        super.setUp();

        this.ksdata = KickstartDataTest.createKickstartWithOptions(user.getOrg());
        TestUtils.saveAndFlush(ksdata);
        addRequestParameter(RequestContext.KICKSTART_ID, this.ksdata.getId().toString());
    }

    public void testPopulatePartition() throws Exception {
        setRequestPathInfo("/kickstart/KickstartPartitionEdit");
        addRequestParameter(RhnAction.SUBMITTED, Boolean.FALSE.toString());
        actionPerform();
        DynaActionForm form = (DynaActionForm) getActionForm();
        String formval = (String)form.get(KickstartPartitionEditAction.PARTITIONS);
        assertTrue(formval.length() > 0);
    }

    public void testCleanSubmit() throws Exception {

        String data = "partition swap --size=1000 --grow --maxsize=3000\n" +
        "logvol swap --fstype swap --name=lvswap --vgname=Volume00 --size=2048\n" +
        "volgroup myvg pv.01\n" +
        "raid swap --fstype swap --level 0 --device 1 raid.05 raid.06 raid.07 raid.08";
        setRequestPathInfo("/kickstart/KickstartPartitionEdit");
        addRequestParameter(KickstartPartitionEditAction.SUBMITTED,
                Boolean.TRUE.toString());
        addRequestParameter(KickstartPartitionEditAction.PARTITIONS, data);
        actionPerform();
        DynaActionForm form = (DynaActionForm) getActionForm();
        String formval = (String)form.get(KickstartPartitionEditAction.PARTITIONS);

        assertTrue(formval.length() > 0);
        assertTrue(ksdata.getRaids().size() > 0);
        assertTrue(ksdata.getVolgroups().size() > 0);
        assertTrue(ksdata.getLogvols().size() > 0);
        assertTrue(ksdata.getPartitions().size() > 0);
        assertEquals(0, ksdata.getIncludes().size());

        String[] keys = {"kickstart.partition.success"};
        verifyActionMessages(keys);
    }

    public void testDuplicateMountPoint() throws Exception {

        String data = "partition /boot --size=1000 --grow --maxsize=3000\n" +
        "partition /boot --size=2000 --grow --maxsize=3000\n" +
        "volgroup myvg pv.01\n" +
        "raid swap --fstype swap --level 0 --device 1 raid.05 raid.06 raid.07 raid.08";
        setRequestPathInfo("/kickstart/KickstartPartitionEdit");
        addRequestParameter(KickstartPartitionEditAction.SUBMITTED,
                Boolean.TRUE.toString());
        addRequestParameter(KickstartPartitionEditAction.PARTITIONS, data);
        actionPerform();
        DynaActionForm form = (DynaActionForm) getActionForm();
        String formval = (String)form.get(KickstartPartitionEditAction.PARTITIONS);

        assertTrue(formval.length() > 0);

        String[] keys = {"kickstart.partition.duplicate"};
        verifyActionErrors(keys);
    }

    public void testMultipleSwapsSubmit() throws Exception {

        String data = "partition swap --size=1000 --grow --maxsize=3000\n" +
        "partition swap --fstype swap --name=lvswap --vgname=Volume00 --size=2048\n" +
        "raid swap --fstype swap --level 0 --device 1 raid.05 raid.06 raid.07 raid.08";
        setRequestPathInfo("/kickstart/KickstartPartitionEdit");
        addRequestParameter(KickstartPartitionEditAction.SUBMITTED,
                Boolean.TRUE.toString());
        addRequestParameter(KickstartPartitionEditAction.PARTITIONS, data);
        actionPerform();
        DynaActionForm form = (DynaActionForm) getActionForm();
        String formval = (String)form.get(KickstartPartitionEditAction.PARTITIONS);

        assertTrue(formval.length() > 0);
        assertTrue(ksdata.getRaids().size() > 0);
        assertTrue(ksdata.getPartitions().size() > 0);
        assertEquals(0, ksdata.getLogvols().size());
        assertEquals(0, ksdata.getIncludes().size());
        assertEquals(0, ksdata.getVolgroups().size());

        String[] keys = {"kickstart.partition.success"};
        verifyActionMessages(keys);
    }

}


