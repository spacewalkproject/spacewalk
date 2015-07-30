/**
 * Copyright (c) 2009--2015 Red Hat, Inc.
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

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;



/**
 * Repo Sync
 *  Used for syncing repos (like yum repos) to a channel
 *  This really just calls a python script
 *
 * @version $Rev$
 */
public class RepoSyncTask extends RhnJavaJob {

    /**
     *
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext context)
        throws JobExecutionException {

        String channelIdString = (String)
                    context.getJobDetail().getJobDataMap().get("channel_id");
        String [] lparams = {"no-errata", "latest", "sync-kickstart", "fail"};
        List<String> ltrue = Arrays.asList("true", "1");
        List<String> params = new ArrayList<String>();
        for (String p : lparams) {
            if (context.getJobDetail().getJobDataMap().containsKey(p)) {
                if (ltrue.contains(context.getJobDetail().getJobDataMap()
                        .get(p).toString().toLowerCase().trim())) {
                    params.add("--" + p);
               }
            }
        }
        Long channelId;
        try {
            channelId = Long.parseLong(channelIdString);
        }
        catch (Exception e) {
            throw new JobExecutionException("No valid channel_id given.");
        }

        Channel c = ChannelFactory.lookupById(channelId);
        if (c == null) {
            throw new JobExecutionException("No such channel with channel_id " + channelId);
        }
        log.info("Syncing repos for channel: " + c.getName());
        executeExtCmd(getSyncCommand(c, params).toArray(new String[0]));
        c.setLastSynced(new Date());
    }

    private static List<String> getSyncCommand(Channel c, List<String> params) {
        List<String> cmd = new ArrayList<String>();
        cmd.add(Config.get().getString(ConfigDefaults.SPACEWALK_REPOSYNC_PATH,
                "/usr/bin/spacewalk-repo-sync"));
        cmd.add("--channel");
        cmd.add(c.getLabel());
        cmd.add("--type");
        cmd.add(ChannelFactory.CONTENT_SOURCE_TYPE_YUM.getLabel());
        cmd.addAll(params);
        return cmd;
    }
}
