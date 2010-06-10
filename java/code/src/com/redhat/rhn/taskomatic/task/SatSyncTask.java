/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.taskomatic.task;

import com.redhat.rhn.manager.satellite.SystemCommandExecutor;

import org.quartz.Job;
import org.quartz.JobDataMap;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;


/**
 * SatSyncTask
 * @version $Rev$
 */
public class SatSyncTask implements Job {

    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext ctx) throws JobExecutionException {
        String[] args = new String[3];
        args[0] = "/usr/bin/sudo";
        args[1] = "satellite-sync";
        args[2] = "-l";

        SystemCommandExecutor ce = new SystemCommandExecutor();
        ce.execute(args);
        
        ctx.getJobDetail().getJobDataMap().put("stdOutput", ce.getLastCommandOutput());
        ctx.getJobDetail().getJobDataMap().put("stdError", ce.getLastCommandErrorMessage());
    }
}
