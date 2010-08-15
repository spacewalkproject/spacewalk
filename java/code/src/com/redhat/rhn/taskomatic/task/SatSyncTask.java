/**
 * Copyright (c) 2010 Red Hat, Inc.
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

import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.util.ArrayList;
import java.util.List;


/**
 * SatSyncTask
 * @version $Rev$
 */
public class SatSyncTask extends RhnJavaJob {

    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext ctx) throws JobExecutionException {
        List<String> cmd = new ArrayList<String>();
        String list = (String) ctx.getJobDetail().getJobDataMap().get("list");
        String channel = (String) ctx.getJobDetail().getJobDataMap().get("channel");

        cmd.add("/usr/bin/sudo");
        cmd.add("satellite-sync");

        if (list != null) {
            cmd.add("--list-channels");
        }
        else if (channel != null) {
            cmd.add("-c");
            cmd.add(channel);
        }

        String[] args = cmd.toArray(new String[cmd.size()]);
        executeExtCmd(args);
    }
}
