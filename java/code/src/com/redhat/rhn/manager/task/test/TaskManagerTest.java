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
package com.redhat.rhn.manager.task.test;

import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.manager.task.TaskManager;
import com.redhat.rhn.taskomatic.core.TaskomaticConstants;
import com.redhat.rhn.testing.RhnBaseTestCase;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;


public class TaskManagerTest extends RhnBaseTestCase {




    public void testGetTaskExecutionTime() throws Exception {

        String label = "errata_engine";

        if (TaskManager.getTaskExecutionTime(label) == null) {
            WriteMode statsQuery = ModeFactory.getWriteMode(TaskomaticConstants.MODE_NAME,
                    TaskomaticConstants.DAEMON_QUERY_CREATE_STATS);
            Map params = new HashMap();
            params.put("display_name", label);
            statsQuery.executeUpdate(params);
        }

        Date date = TaskManager.getTaskExecutionTime(label);
        assertNotNull(date);

    }


    public void testGetCurrentDBTime() throws Exception {
        assertNotNull(TaskManager.getCurrentDBTime());
    }


}
