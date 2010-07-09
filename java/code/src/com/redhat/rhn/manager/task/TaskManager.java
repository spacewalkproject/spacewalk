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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.taskomatic.task.TaskConstants;

import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

/**
 *
 * TaskManager
 * @version $Rev$
 */
public class TaskManager {


    private TaskManager() {

    }

    /**
     * gets the last time a certain task was exectued
     * @param label the label of the task
     * @return the date
     */
    public static Date getTaskExecutionTime(String label) {

        SelectMode m = ModeFactory.getMode("Task_queries", "get_task_stats");
        Map in = new HashMap();
        in.put("label", label);
        DataResult<Map> list = m.execute(in);

        if (!list.isEmpty()) {
            return (Date) list.get(0).get("last_poll");
        }
        return null;
    }


    /**
     * Gets the current db time
     * @return the date
     */
    public static Date getCurrentDBTime() {
        SelectMode m = ModeFactory.getMode("Task_queries", "get_current_time");
        DataResult<Map> list = m.execute();
        if (!list.isEmpty()) {
            return (Date) list.get(0).get("sysdate");
        }
        return null;
    }

    /**
     *  Get the channel package list for a channel
     * @param channel channel info
     * @return the iterator
     */
    public static Iterator getChannelPackageDtoIterator(Channel channel) {
        SelectMode m = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_REPOMD_GENERATOR_CHANNEL_PACKAGES);
        Map params = new HashMap();
        params.put("channel_id", channel.getId());
        return m.execute(params).iterator();
    }


}
