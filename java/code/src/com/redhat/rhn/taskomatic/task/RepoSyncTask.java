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
package com.redhat.rhn.taskomatic.task;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.log4j.Logger;
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.task.Task;
import com.redhat.rhn.domain.task.TaskFactory;


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
            //workaround in case task is null (which can happen)

            if (task == null || task.getData() == null) {
                TaskFactory.removeTask(task);
                continue;
            }
            Channel c = ChannelFactory.lookupById(task.getData());
            if (log.isInfoEnabled() && c != null) {
                log.info("Syncing repos for channel: " + c.getName());
            }
            if (c == null) {
                log.error("Channel could not be found: " + task.getData());
                TaskFactory.removeTask(task);
                continue;
            }
            TaskFactory.removeTask(task);
            
            try {
                Process p = Runtime.getRuntime().exec(
                        getSyncCommand(c).toArray(new String[0]));
                c.setLastSynced(new Date());
                int chr = p.getInputStream().read();
                while (chr != -1) {
                    chr = p.getInputStream().read();
                    
                }
                
            }
            catch (IOException e) {
                log.fatal(e.getMessage());
                e.printStackTrace();
            }
        }
    }
    
    private static List<String> getSyncCommand(Channel c) {
        List<String> cmd = new ArrayList<String>();
        cmd.add(Config.get().getString(ConfigDefaults.SPACEWALK_REPOSYNC_PATH,
                "/usr/bin/spacewalk-repo-sync"));
        cmd.add("--channel");
        cmd.add(c.getLabel());
        cmd.add("--type");
        cmd.add(ChannelFactory.CONTENT_SOURCE_TYPE_YUM.getLabel());
        cmd.add("--quiet");
        return cmd;
    }
    

}
