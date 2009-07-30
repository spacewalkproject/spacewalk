/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.ContentSource;
import com.redhat.rhn.domain.task.Task;
import com.redhat.rhn.domain.task.TaskFactory;

import org.apache.log4j.Logger;
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;


/**
 * Repo Sync
 *  Used for syncing repos (like yum repos) to a channel
 *  This really just calls a python script
 *  
 * @version $Rev$
 */
public class RepoSyncTask implements Job {
        
    /**
     * Used to log stats in the RHNDAEMONSTATE table
     */
    public static final String DISPLAY_NAME = "repo_sync";

    private static Logger log = Logger.getLogger(RepoSyncTask.class);
    
    /**
     * Default constructor
     */
    public RepoSyncTask() {
    }
 

    /**
     * 
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext context)
        throws JobExecutionException {
        
        for (Task task : TaskFactory.listTasks(DISPLAY_NAME)) {
            
            ContentSource src = ChannelFactory.lookupContentSource(task.getData());
            if (src == null) {
                log.error("Content Source could not be found: " + task.getData());
                continue;
            }
            
            try {

                Process p = Runtime.getRuntime().exec(
                        (String[]) getSyncCommand(src).toArray());
                p.waitFor();
            }
            catch (IOException e) {
                e.printStackTrace();
            }
            catch (InterruptedException e) {
                e.printStackTrace();
            }
            src.setLastSynced(new Date());
            TaskFactory.removeTask(task);
        }
    }
    
    private static List<String> getSyncCommand(ContentSource src) {
        List<String> cmd = new ArrayList<String>();
        cmd.add(Config.get().getString(ConfigDefaults.SPACEWALK_REPO_SYNC_PATH,
                "/usr/sbin/spacewalk-repo-sync"));
        cmd.add("-c");
        cmd.add(src.getChannel().getLabel());
        cmd.add("-u");
        cmd.add(src.getSourceUrl());
        cmd.add("-t");
        cmd.add(src.getType().getLabel());
        cmd.add("-l");
        cmd.add(src.getLabel());
        return cmd;
    }
    

}
