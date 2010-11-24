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
package com.redhat.rhn.taskomatic;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.user.User;

import java.net.MalformedURLException;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import redstone.xmlrpc.XmlRpcClient;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcFault;


/**
 *
 * TaskomaticApi
 * @version $Rev$
 */
public class TaskomaticApi {



    private XmlRpcClient getClient() throws TaskomaticApiException {
        try {
           return  new XmlRpcClient(
                    ConfigDefaults.get().getTaskoServerUrl(), false);
        }
        catch (MalformedURLException e) {
            throw new TaskomaticApiException(e);
        }
    }

    private Object invoke(String name, Object...args) {
        try {
            return getClient().invoke(name, args);
        }
        catch (XmlRpcException e) {
            throw new TaskomaticApiException(e);
        }
        catch (XmlRpcFault e) {
            throw new TaskomaticApiException(e);
        }
    }

    /**
     * Returns whether taskomatic is running
     * @return True if taskomatic is running
     */
    public boolean isRunning() {
        try {
            invoke("tasko.one", new Integer(0));
            return true;
        }
        catch (Exception e) {
            return false;
        }
    }

    /**
     * Schedule a single reposync
     * @param chan the channel
     * @param user the user
     * @throws TaskomaticApiException if there was an error
     */
    public void scheduleSingleRepoSync(Channel chan, User user)
                                    throws TaskomaticApiException {
        Map scheduleParams = new HashMap();
        scheduleParams.put("channel_id", chan.getId().toString());
        invoke("tasko.scheduleSingleBunchRun", user.getOrg().getId(),
                "repo-sync-bunch", scheduleParams);
    }

    private String createRepoSyncScheduleName(Channel chan, User user) {
        return "repo-sync-" + user.getOrg().getId() + "-" + chan.getId();
    }

    /**
     * Schedule a recurring reposync
     * @param chan the channel
     * @param user the user
     * @param cron the cron format
     * @return the Date?
     * @throws TaskomaticApiException if there was an error
     */
    public Date scheduleRepoSync(Channel chan, User user, String cron)
                                        throws TaskomaticApiException {
        String jobLabel = createRepoSyncScheduleName(chan, user);

        Map task = findScheduleByBunchAndLabel("repo-sync-bunch", jobLabel, user);
        if (task != null) {
            unscheduleTask(jobLabel, user);
        }
        Map scheduleParams = new HashMap();
        scheduleParams.put("channel_id", chan.getId().toString());
        return (Date) invoke("tasko.scheduleBunch", user.getOrg().getId(),
                "repo-sync-bunch", jobLabel , cron,
                scheduleParams);
    }


    /**
     * Unchedule a reposync task
     * @param chan the channel
     * @param user the user
     */
    public void unscheduleRepoSync(Channel chan, User user) {
        unscheduleTask(createRepoSyncScheduleName(chan, user), user);
    }

    private void unscheduleTask(String jobLabel, User user) {
        invoke("tasko.unscheduleBunch", user.getOrg().getId(), jobLabel);
    }



    private Map findScheduleByBunchAndLabel(String bunchName, String jobLabel, User user) {
        List<Map> schedules = (List<Map>) invoke("tasko.listActiveSchedulesByBunch",
                user.getOrg().getId(), bunchName);
        for (Map schedule : schedules) {
            if (schedule.get("job_label").equals(jobLabel)) {
                return schedule;
            }
         }
        return null;
    }

    /**
     * Get the cron format for a single channel
     * @param chan the channel
     * @param user the user
     * @return the Cron format
     */
    public String getRepoSyncSchedule(Channel chan, User user) {
        String jobLabel = createRepoSyncScheduleName(chan, user);
        Map task = findScheduleByBunchAndLabel("repo-sync-bunch", jobLabel, user);
        if (task == null) {
            return null;
        }
        else {
            return (String) task.get("cron_expr");
        }
    }

}
