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
package com.redhat.rhn.taskomatic.core;

import com.redhat.rhn.taskomatic.task.TaskConstants;

/**
 * Various constants used by the Taskomatic daemon
 * @version $Rev$
 */
public class TaskomaticConstants {

    // Quartz task group name
     public static final String TASK_GROUP = "Taskomatic Group";

     // Various "command-line" parameters Taskomatic understands
     public static final String CLI_DEBUG  = "debug";
     public static final String CLI_DAEMON = "daemon";
     public static final String CLI_SINGLE = "single";
     public static final String CLI_HELP = "help";
     public static final String CLI_PIDFILE = "pidfile";
     public static final String CLI_TASK = "task";
     public static final String CLI_DBURL = "dburl";
     public static final String CLI_DBUSER  = "dbuser";
     public static final String CLI_DBPASSWORD = "dbpassword";

     public static final String DISPLAY_NAME_CONST = "DISPLAY_NAME";

     public static final String MODE_NAME = TaskConstants.MODE_NAME;
     public static final String DAEMON_QUERY_FIND_STATS = "find_task_stats";
     public static final String DAEMON_QUERY_CREATE_STATS = "create_task_stats";
     public static final String DAEMON_QUERY_UPDATE_STATS = "update_task_stats";


     private TaskomaticConstants() {

     }
}
