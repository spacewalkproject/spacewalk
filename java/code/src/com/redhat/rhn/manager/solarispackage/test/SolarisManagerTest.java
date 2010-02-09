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
package com.redhat.rhn.manager.solarispackage.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.manager.solarispackage.SolarisManager;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * SolarisManagerTest
 * @version $Rev: 53102 $
 */
public class SolarisManagerTest extends RhnBaseTestCase {

    //initial tests for Solaris feature. disabled until we can create solaris system
    // and assign to a solaris channel

    public void testNothing() {
        // This test is only here to make junit happy. It complains
        // if there are no tests in a TestCase
    }
    
    public void atestSystemAvailablePackageList() {
        PageControl pc = new PageControl();
        pc.setIndexData(false);
        pc.setStart(1);

        // hard code for now.
        DataResult dr = SolarisManager.systemAvailablePackageList(new Long(1000010004), pc);
        assertNotNull(dr);

    }

    public void atestSystemUpgradablePackageList() {
        PageControl pc = new PageControl();
        pc.setIndexData(false);
        pc.setStart(1);

        // hard code for now.
        DataResult dr = SolarisManager.
                                      systemUpgradablePackageList(new Long(1000010004), pc);
        assertNotNull(dr);

    }

    public void atestSystemAvailablePatchList() {
        PageControl pc = new PageControl();
        pc.setIndexData(false);
        pc.setStart(1);

        // hard code for now.
        DataResult dr = SolarisManager.systemAvailablePatchList(new Long(1000010004), pc);
        assertNotNull(dr);
    }

    public void atestSystemPatchList() {
        PageControl pc = new PageControl();
        pc.setIndexData(false);
        pc.setStart(1);

        // hard code for now.
        DataResult dr = SolarisManager.systemPatchList(new Long(1000010004), pc);
        assertNotNull(dr);



    }

    public void atestSystemPackageList() {
        PageControl pc = new PageControl();
        pc.setIndexData(false);
        pc.setStart(1);

        // hard code for now.
        DataResult dr = SolarisManager.systemPackageList(new Long(1000010004), pc);
        assertNotNull(dr);


    }

}
