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
package com.redhat.rhn.manager.audit.test;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.frontend.dto.AuditMachineDto;
import com.redhat.rhn.manager.audit.AuditManager;
import com.redhat.rhn.testing.TestUtils;

import java.io.File;

import junit.framework.TestCase;


public class AuditManagerTest extends TestCase {

    
    public void testGetMachines() throws Exception {
        String testdir =  "/tmp/sw-audit-test";
        String machinename = TestUtils.randomString();
        Config.get().setString("web.audit.logdir", testdir);
        File newdir = new File(testdir);
        if (!newdir.exists()) {
            newdir.mkdir();
        }
        File machinedir = new File(testdir + "/" + machinename);
        machinedir.mkdir();
        
        DataResult dr = AuditManager.getMachines();
        assertNotNull(dr);
        assertTrue(dr.size() == 1);
        AuditMachineDto dto = (AuditMachineDto) dr.get(0);
        assertEquals(machinename, dto.getName());
        
        machinedir.delete();
        newdir.delete();
    }
}
