/**
 * Copyright (c) 2010--2015 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.channel.manage;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.FileUtils;
import com.redhat.rhn.common.util.RecurringEventPicker;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.ContentSource;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.satellite.SystemCommandExecutor;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.download.DownloadManager;
import com.redhat.rhn.manager.user.UserManager;
import com.redhat.rhn.taskomatic.TaskomaticApi;
import com.redhat.rhn.taskomatic.TaskomaticApiException;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * SyncRepositoriesAction
 * @version $Rev$
 */
public class SyncRepositoriesAction extends RhnAction implements Listable {

    private static final String REPOSYNC_LOCKFILE = "/var/run/spacewalk-repo-sync.pid";

  /**
   *
   * {@inheritDoc}
   */
    @Override
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext context = new RequestContext(request);
        User user =  context.getCurrentUser();

        long cid = context.getRequiredParam("cid");
        Channel chan = ChannelFactory.lookupByIdAndUser(cid, user);
        request.setAttribute("channel_name", chan.getName());
        request.setAttribute("cid",  chan.getId());

        boolean inProgress = isSyncInProgress(chan);
        if (inProgress) {
            addMessage(request, "message.syncinprogress");
            request.setAttribute("in_progress", true);
        }

        request.setAttribute("status", parseSyncLog(chan, inProgress));

        if (!chan.getSources().isEmpty()) {
            String lastSync = LocalizationService.getInstance().getMessage(
                    "channel.edit.repo.neversynced");
            if (chan.getLastSynced() != null) {
                lastSync = LocalizationService.getInstance().formatCustomDate(
                        chan.getLastSynced());
            }
            request.setAttribute("last_sync", lastSync);
            if (!ChannelManager.getLatestSyncLogFiles(chan).isEmpty()) {
                request.setAttribute("log_url",
                        DownloadManager.getChannelSyncLogDownloadPath(chan,
                                context.getCurrentUser()));
            }
        }

        Map<String, Object> params = new HashMap<String, Object>();
        params.put(RequestContext.CID, chan.getId().toString());

        ListHelper helper = new ListHelper(this, request, params);
        helper.execute();


        TaskomaticApi taskomatic = new TaskomaticApi();
        String oldCronExpr = null;
        try {
            oldCronExpr = taskomatic.getRepoSyncSchedule(chan, user);
        }
        catch (TaskomaticApiException except) {
            params.put("inactive", true);
            request.setAttribute("inactive", true);
            createErrorMessage(request,
                    "repos.jsp.message.taskomaticdown", null);
        }

        RecurringEventPicker picker = RecurringEventPicker.prepopulatePicker(
                request, "date", oldCronExpr);


        if (context.isSubmitted()) {
            StrutsDelegate strutsDelegate = getStrutsDelegate();

            // check user permissions first
            if (!UserManager.verifyChannelAdmin(user, chan)) {
                createErrorMessage(request,
                        "frontend.actions.channels.manager.add.permsfailure", null);
                return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
            }

            if (chan.getSources().isEmpty()) {
                createErrorMessage(request,
                        "repos.jsp.channel.norepos", null);
                return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
            }

            try {
                Map<String, String> mparams = new HashMap<String, String>();
                String [] lparams = {"no-errata", "latest", "sync-kickstart", "fail"};

                for (String p : lparams) {
                    if  (request.getParameter(p) != null) {
                        mparams.put(p, "true");
                    }
                }

                if (context.wasDispatched("repos.jsp.button-sync")) {
                    // schedule one time repo sync
                    taskomatic.scheduleSingleRepoSync(chan, user, mparams);
                    createSuccessMessage(request, "message.syncscheduled",
                            chan.getName());

                }
                else if (context.wasDispatched("schedule.button")) {
                    if ((picker.isDisabled() ||
                            StringUtils.isEmpty(picker.getCronEntry())) &&
                                oldCronExpr != null) {
                        taskomatic.unscheduleRepoSync(chan, user);
                        createSuccessMessage(request, "message.syncschedule.disabled",
                                chan.getName());
                    }
                    else if (!StringUtils.isEmpty(picker.getCronEntry())) {
                        Date date = taskomatic.scheduleRepoSync(chan, user,
                                picker.getCronEntry(), mparams);
                        createSuccessMessage(request, "message.syncscheduled",
                                chan.getName());
                    }
                }
            }
            catch (TaskomaticApiException e) {
                if (e.getMessage().contains("InvalidParamException")) {
                    createErrorMessage(request,
                            "repos.jsp.message.invalidcron", picker.getCronEntry());
                }
                else {
                    createErrorMessage(request,
                            "repos.jsp.message.schedulefailed", null);
                }
                return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
            }

            Map forwardParams = new HashMap();
            forwardParams.put("cid", chan.getId());
            return getStrutsDelegate().forwardParams(mapping.findForward("success"),
                    forwardParams);
        }

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    private boolean isSyncInProgress(Channel chan) {
        String pid;
        try {
            pid = FileUtils.readStringFromFile(REPOSYNC_LOCKFILE).trim();
        }
        catch (RuntimeException e) {
            return false;
        }

        // Is this PID running?
        String[] cmd = {"ps", "-o", "args", "-p", pid};
        SystemCommandExecutor ce = new SystemCommandExecutor();
        ce.execute(cmd);
        return ce.getLastCommandOutput().contains(" " + chan.getLabel() + " ");
    }

    private String getLastSyncLog(Channel chan) {
        List<String> files = ChannelManager.getLatestSyncLogFiles(chan);
        String lastLog = "";
        if (!files.isEmpty()) {
            // Most recent file only
            String allLogs = FileUtils.readStringFromFile(files.get(0));
            int lastLogStart = allLogs.lastIndexOf("Sync started:");
            if (lastLogStart > -1) {
                lastLog = allLogs.substring(lastLogStart);
            }
        }
        return lastLog;
    }

    private Map<String, Map<String, Object>> parseSyncLog(
            Channel chan, boolean inProgress) {

        String log = getLastSyncLog(chan);

        Map<String, Map<String, Object>> repositories =
                new HashMap<String, Map<String, Object>>();

        String[] allRepoLog = log.split("Repo URL: ");

        for (String repoLog : allRepoLog) {
            Map<String, Object> syncingRepo = new HashMap<String, Object>();
            String[] lines = repoLog.split("\\n");

            String lastLine = lines[lines.length - 1];
            // Downloading packages
            if (lastLine.matches("\\d+/\\d+ : .+")) {
                String[] progress = lastLine.split(" : ")[0].split("/");
                int done = Integer.parseInt(progress[0]);
                int total = Integer.parseInt(progress[1]);
                int percentage = done * 100 / total;
                syncingRepo.put("progress", String.valueOf(percentage));
                syncingRepo.put("title", lastLine);
                // Mark as failed if reposync stopped running
                syncingRepo.put("failed", !inProgress);
            }
            else {
                for (String line : lines) {
                    // Packages are downloaded
                    if (line.equals("No new packages to sync.") ||
                            (line.equals("Linking packages to channel."))) {
                        syncingRepo.put("progress", "100");
                        // Mark as finished when all repos are synced
                        syncingRepo.put("finished", !inProgress);
                    }
                    else if (line.startsWith("ERROR: ")) {
                        syncingRepo.put("failed", true);
                        syncingRepo.put("title", line);
                        break;
                    }
                }
            }

            // Using URL as a key
            repositories.put(lines[0], syncingRepo);
        }

        return repositories;
    }

        /**
         *
         * {@inheritDoc}
         */
        public List<ContentSource> getResult(RequestContext context) {
            User user =  context.getCurrentUser();
            long cid = context.getRequiredParam("cid");
            Channel chan = ChannelFactory.lookupByIdAndUser(cid, user);
            return ChannelFactory.lookupContentSources(user.getOrg(), chan);
        }
}
