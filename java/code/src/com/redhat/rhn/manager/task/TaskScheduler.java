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
package com.redhat.rhn.manager.task;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.task.Task;
import com.redhat.rhn.domain.task.TaskFactory;

import org.apache.commons.collections.IteratorUtils;

import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

/**
 * TaskScheduler
 * @version $Rev$
 */
public class TaskScheduler {

    private Org org;
    private Errata errata;
    
    //Name for tasks that were scheduled by channel. Goes in the TASK_NAME column
    //in the rhnTaskQueue table in the db.
    private static final String CHANNELNAME = "update_errata_cache_by_channel";
    private static final int DELAY = 1000 * 60 * 10; //10 minute delay in milliseconds
    
    /**
     * Create a scheduler that only has the org set. This is useful for org-wide operations
     * such as setting all tasks to run now.
     * @param orgIn The org containing the tasks to be run.
     */
    public TaskScheduler(Org orgIn) {
        org = orgIn;
    }
    
    /**
     * Create a scheduler that has both an errata and an org. This constructor is for when
     * you need to operate on tasks for an errata, such as updating the tasks for the 
     * channels in a given errata.
     * @param errataIn The errata containing the channels you wish to operate on.
     * @param orgIn The org for the user
     */
    public TaskScheduler(Errata errataIn, Org orgIn) {
        errata = errataIn;
        org = orgIn;
    }
    
    /**
     * This method inserts/updates tasks by the channels in an errata. This method
     * corresponds to ChannelEditor.pm -> schedule_errata_cache_update method in the 
     * perl codebase.
     */
    public void updateByChannels() {
        //Get the channels for this errata
        Set channels = errata.getChannels();
        
        //Loop through the channels and either insert or update a task
        Iterator itr = IteratorUtils.getIterator(channels);
        while (itr.hasNext()) {
            Channel channel = (Channel) itr.next();
            
            //Look to see if task already exists...
            Task task = TaskFactory.lookup(org, CHANNELNAME, channel.getId());
            if (task == null) { //if not, create a new task
                task = TaskFactory.createTask(org, CHANNELNAME, channel.getId());
            }
            else { //if so, update the earliest column
                task.setEarliest(new Date(System.currentTimeMillis() + DELAY));
            }
            //save the task
            TaskFactory.save(task);
        }
    }
    
    /**
     * Gets all of the tasks which have been set by channel name, and updates their 
     * earliest attribute to now.
     */
    public void runTasksByChannelNow() {
        //tasks contains the tasks for an org that have CHANNELNAME for their name attr
        List tasks = TaskFactory.getTaskListByChannel(org);
        Date now = new Date();
        /*
         * TODO: Hopefully when we get to hib3, we can make one update statement to hit
         * all of the Task objects. As of now, this isn't a big deal since we will 
         * realistically only have a few channels per org.
         */
        for (Iterator itr = tasks.iterator(); itr.hasNext();) {
            Task task = (Task) itr.next(); //Get the task
            task.setEarliest(now); //set to run asap
            TaskFactory.save(task); //save
        }
        
    }
    
}
