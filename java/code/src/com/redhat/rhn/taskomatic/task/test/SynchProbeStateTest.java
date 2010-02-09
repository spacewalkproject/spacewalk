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
package com.redhat.rhn.taskomatic.task.test;

import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.taskomatic.task.SynchProbeState;
import com.redhat.rhn.taskomatic.task.TaskConstants;
import com.redhat.rhn.testing.RhnBaseTestCase;

public class SynchProbeStateTest extends RhnBaseTestCase {

    protected void setUp() throws Exception {
        CallableMode proc = ModeFactory.getCallableMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_SYNCHPROBESTATE_PROC);
        assertNotNull(proc);
    }
    
    public void testSynchProbeState() throws Exception {
        SynchProbeState task = new SynchProbeState();
        task.execute(null);
    }

}
