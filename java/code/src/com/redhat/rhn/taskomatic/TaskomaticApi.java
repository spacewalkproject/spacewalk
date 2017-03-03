/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;

import java.net.MalformedURLException;
import java.util.ArrayList;
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

    /**
     * Schedule a single reposync
     * @param chan the channel
     * @param user the user
     * @param params parameters
     * @throws TaskomaticApiException if there was an error
     */
    public void scheduleSingleRepoSync(Channel chan, User user, Map <String, String>params)
                                    throws TaskomaticApiException {

        Map <String, String> scheduleParams = new HashMap<String, String>();
        scheduleParams.put("channel_id", chan.getId().toString());
        scheduleParams.putAll(params);

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
            unscheduleRepoTask(jobLabel, user);
        }
        Map scheduleParams = new HashMap();
        scheduleParams.put("channel_id", chan.getId().toString());
        return (Date) invoke("tasko.scheduleBunch", user.getOrg().getId(),
                "repo-sync-bunch", jobLabel, cron, scheduleParams);
    }

    /**
     * Schedule a recurring reposync
     * @param chan the channel
     * @param user the user
     * @param cron the cron format
     * @param params parameters
     * @return the Date?
     * @throws TaskomaticApiException if there was an error
     */
    public Date scheduleRepoSync(Channel chan, User user, String cron,
            Map<String, String> params) throws TaskomaticApiException {
        String jobLabel = createRepoSyncScheduleName(chan, user);

        Map task = findScheduleByBunchAndLabel("repo-sync-bunch", jobLabel, user);
        if (task != null) {
            unscheduleRepoTask(jobLabel, user);
        }
        Map <String, String> scheduleParams = new HashMap<String, String>();
        scheduleParams.put("channel_id", chan.getId().toString());
        scheduleParams.putAll(params);

        return (Date) invoke("tasko.scheduleBunch", user.getOrg().getId(),
                "repo-sync-bunch", jobLabel, cron, scheduleParams);
    }

    /**
     * Creates a new single satellite schedule
     * @param user shall be sat admin
     * @param bunchName bunch name
     * @return date of the first schedule
     * @throws TaskomaticApiException if there was an error
     */
    public Date scheduleSingleSatBunch(User user, String bunchName)
    throws TaskomaticApiException {
        ensureSatAdminRole(user);
        return (Date) invoke("tasko.scheduleSingleSatBunchRun", bunchName, new HashMap());
    }

    /**
     * Validates user has sat admin role
     * @param user shall be sat admin
     * @throws PermissionException if there was an error
     */
    private void ensureSatAdminRole(User user) {
        if (!user.hasRole(RoleFactory.SAT_ADMIN)) {
            ValidatorException.raiseException("satadmin.jsp.error.notsatadmin",
                                user.getLogin());
        }
    }

    /**
     * Validates user has org admin role
     * @param user shall be org admin
     * @throws PermissionException if there was an error
     */
    private void ensureOrgAdminRole(User user) {
        if (!user.hasRole(RoleFactory.ORG_ADMIN)) {
            throw new PermissionException(RoleFactory.ORG_ADMIN);
        }
    }

    /**
     * Validates user has channel admin role
     * @param user shall be channel admin
     * @throws PermissionException if there was an error
     */
    private void ensureChannelAdminRole(User user) {
        if (!user.hasRole(RoleFactory.CHANNEL_ADMIN)) {
            throw new PermissionException(RoleFactory.CHANNEL_ADMIN);
        }
    }

    /**
     * Creates a new schedule, unschedules, if en existing is defined
     * @param user shall be sat admin
     * @param jobLabel name of the schedule
     * @param bunchName bunch name
     * @param cron cron expression
     * @return date of the first schedule
     * @throws TaskomaticApiException if there was an error
     */
    public Date scheduleSatBunch(User user, String jobLabel, String bunchName, String cron)
    throws TaskomaticApiException {
        ensureSatAdminRole(user);
        Map task = findSatScheduleByBunchAndLabel(bunchName, jobLabel, user);
        if (task != null) {
            unscheduleSatTask(jobLabel, user);
        }
        return (Date) invoke("tasko.scheduleSatBunch", bunchName, jobLabel , cron,
                new HashMap());
    }

    /**
     * Unchedule a reposync task
     * @param chan the channel
     * @param user the user
     */
    public void unscheduleRepoSync(Channel chan, User user) {
        String jobLabel = createRepoSyncScheduleName(chan, user);
        Map task = findScheduleByBunchAndLabel("repo-sync-bunch", jobLabel, user);
        if (task != null) {
            unscheduleRepoTask(jobLabel, user);
        }
    }

    private void unscheduleRepoTask(String jobLabel, User user) {
        ensureChannelAdminRole(user);
        invoke("tasko.unscheduleBunch", user.getOrg().getId(), jobLabel);
    }

    /**
     * unschedule satellite task
     * @param jobLabel schedule name
     * @param user shall be satellite admin
     */
    public void unscheduleSatTask(String jobLabel, User user) {
        ensureSatAdminRole(user);
        invoke("tasko.unscheduleSatBunch", jobLabel);
    }

    /**
     * Return list of active schedules
     * @param user shall be sat admin
     * @return list of schedules
     */
    public List findActiveSchedules(User user) {
        List<Map> schedules = (List<Map>) invoke("tasko.listActiveSatSchedules");
        return schedules;
    }

    /**
     * Return list of bunch runs
     * @param user shall be sat admin
     * @param bunchName name of the bunch
     * @return list of schedules
     */
    public List findRunsByBunch(User user, String bunchName) {
        List<Map> runs = (List<Map>) invoke("tasko.listBunchSatRuns", bunchName);
        return runs;
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

    private Map findSatScheduleByBunchAndLabel(String bunchName, String jobLabel,
            User user) {
        List<Map> schedules = (List<Map>) invoke("tasko.listActiveSatSchedulesByBunch",
                bunchName);
        for (Map schedule : schedules) {
            if (schedule.get("job_label").equals(jobLabel)) {
                return schedule;
            }
         }
        return null;
    }

    /**
     * Check whether there's an active schedule of given job label
     * @param jobLabel job label
     * @param user the user
     * @return true, if schedule exists
     */
    public boolean satScheduleActive(String jobLabel, User user) {
        List<Map> schedules = (List<Map>) invoke("tasko.listActiveSatSchedules");
        for (Map schedule : schedules) {
            if (schedule.get("job_label").equals(jobLabel)) {
                return Boolean.TRUE;
            }
         }
        return Boolean.FALSE;
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
        return (String) task.get("cron_expr");
    }

    /**
     * Return list of available bunches
     * @param user shall be sat admin
     * @return list of bunches
     */
    public List listSatBunchSchedules(User user) {
        List<Map> bunches = (List<Map>) invoke("tasko.listSatBunches");
        return bunches;
    }

    /**
     * looks up schedule according to id
     * @param user shall be sat admin
     * @param scheduleId schedule id
     * @return schedule
     */
    public Map lookupScheduleById(User user, Long scheduleId) {
        return (Map) invoke("tasko.lookupScheduleById", scheduleId);
    }

    /**
     * looks up schedule according to label
     * @param user shall be sat admin
     * @param bunchName bunch name
     * @param scheduleLabel schedule label
     * @return schedule
     */
    public Map lookupScheduleByBunchAndLabel(User user, String bunchName,
            String scheduleLabel) {
        return findSatScheduleByBunchAndLabel(bunchName, scheduleLabel, user);
    }

    /**
     * looks up bunch according to name
     * @param user shall be sat admin
     * @param bunchName bunch name
     * @return bunch
     */
    public Map lookupBunchByName(User user, String bunchName) {
        return (Map) invoke("tasko.lookupBunchByName", bunchName);
    }

    /**
     * List all reposync schedules within an organization
     * @param org organization
     * @return list of schedules
     */
    private List<TaskoSchedule> listActiveRepoSyncSchedules(Org org) {
        try {
            return TaskoFactory.listActiveSchedulesByOrgAndBunch(org.getId().intValue(),
                    "repo-sync-bunch");
        }
        catch (NoSuchBunchTaskException e) {
            // no such schedules available
            return new ArrayList<TaskoSchedule>();
        }
    }


    /**
     * unschedule all outdated repo-sync schedules within an org
     * @param orgIn organization
     * @return number of removed schedules
     */
    public int unscheduleInvalidRepoSyncSchedules(Org orgIn) {
        int count = 0;
        for (TaskoSchedule schedule : listActiveRepoSyncSchedules(orgIn)) {
            String channelIdStr = (String) schedule.getDataMap().get("channel_id");
            Long channelId = null;
            try {
                channelId = Long.parseLong(channelIdStr);
            }
            catch (NumberFormatException nfe) {
                // no valid channel id given
            }
            if (channelId == null || ChannelFactory.lookupById(channelId) == null) {
                invoke("tasko.unscheduleBunch", orgIn.getId(), schedule.getJobLabel());
                count++;
            }
        }
        return count;
    }
}
