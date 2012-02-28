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

import com.redhat.rhn.domain.task.TaskFactory;
import com.redhat.rhn.taskomatic.TaskoBunch;
import com.redhat.rhn.taskomatic.TaskoFactory;
import com.redhat.rhn.taskomatic.TaskoRun;
import com.redhat.rhn.taskomatic.TaskoTask;
import com.redhat.rhn.taskomatic.TaskoTemplate;
import com.redhat.rhn.taskomatic.task.ErrataQueue;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

import org.apache.commons.lang.RandomStringUtils;

public class ErrataQueueTest extends BaseTestCaseWithUser {

    // We can run this now that mmccune made ErrataQueue perform OK.
    public void testErrataQueue() throws Exception {

        ErrataQueue eq = new ErrataQueue();
        String suffix = RandomStringUtils.randomAlphanumeric(5);
        TaskoBunch bunch = new TaskoBunch();
        TaskoTemplate template = new TaskoTemplate();
        TaskoTask task = new TaskoTask();
        bunch.setName("testBunchName_" + suffix);
        task.setName("testTaskName_" + suffix);
        task.setTaskClass(ErrataQueue.class.toString());
        template.setTask(task);
        template.setOrdering(0L);
        template.setBunch(bunch);
        TaskoFactory.save(template.getBunch());
        TaskoFactory.save(template.getTask());
        TaskoFactory.save(template);
        TaskoRun run = new TaskoRun(null, template, new Long(1));
        eq.execute(null, run);
        // Just a simple test to make sure we get here without
        // exceptions.  Better than nothin'
        assertTrue(true);
        TaskoFactory.delete(run);
        TaskoFactory.delete(template);
        TaskoFactory.delete(template.getBunch());
        TaskoFactory.delete(template.getTask());
        TaskoFactory.commitTransaction();
        TaskFactory.closeSession();
    }
}
