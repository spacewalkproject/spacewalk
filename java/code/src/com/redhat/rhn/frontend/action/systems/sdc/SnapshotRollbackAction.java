/**
 * Copyright (c) 2014 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.systems.sdc;

import com.redhat.rhn.domain.server.InvalidSnapshotReason;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.ServerSnapshot;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * SnapshotRollbackAction
 */
public class SnapshotRollbackAction extends RhnAction {

    private static final String SNAPSHOT_ID = "ss_id";
    private static final String SNAPSHOT_NAME = "snapshot_name";
    private static final String INVALID_REASON_LABEL = "invalid_reason_label";
    private static final String INVALID_REASON_NAME  = "invalid_reason_name";
    private static final String GROUP_CHANGES   = "group_changes";
    private static final String CHANNEL_CHANGES = "channel_changes";
    private static final String PACKAGE_CHANGES = "package_changes";
    private static final String CONFIG_CHANGES  = "config_changes";
    private static final String GROUPS_CHANGED_MSG   =
                                                "system.history.snapshot.groups_changed";
    private static final String PACKAGES_CHANGED_MSG =
                                                "system.history.snapshot.packages_changed";
    private static final String CONFIGS_CHANGED_MSG  =
                                                "system.history.snapshot.configs_changed";

    private static final String HISTORY_FORWARD = "history";

    /**
     * {@inheritDoc}
     */
    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        User user = context.getCurrentUser();
        Long sid = context.getRequiredParam(RequestContext.SID);
        Long ssid = context.getRequiredParam(SNAPSHOT_ID);
        context.lookupAndBindServer();
        ServerSnapshot snapshot = ServerFactory.lookupSnapshotById(ssid.intValue());

        Map<String, Object> params = makeParamMap(request);
        params.put(RequestContext.SID, sid);
        params.put(SNAPSHOT_ID, ssid);

        if (context.isSubmitted()) {
            String forward = rollback(request, user, snapshot);
            return getStrutsDelegate().forwardParams(
                        mapping.findForward(forward), params);
        }

        InvalidSnapshotReason reason = snapshot.getInvalidReason();
        params.put(SNAPSHOT_NAME, snapshot.getName());
        params.put(INVALID_REASON_LABEL, (reason != null ? reason.getLabel() : ""));
        params.put(INVALID_REASON_NAME, (reason != null ? reason.getName() : ""));
        params.put(GROUP_CHANGES,   snapshot.groupDiffs(sid));
        params.put(CHANNEL_CHANGES, snapshot.channelDiffs(sid));
        params.put(PACKAGE_CHANGES, snapshot.packageDiffs(sid));
        params.put(CONFIG_CHANGES,  snapshot.configChannelsDiffs(sid));
        if (snapshot.getUnservablePackages() != null) {
            params.put("snapshot_unservable_packages", true);
        }

        return getStrutsDelegate().forwardParams(
                mapping.findForward(RhnHelper.DEFAULT_FORWARD), params);
    }

    private String rollback(HttpServletRequest request, User user,
                            ServerSnapshot snapshot) {
        boolean packagesChanged = false;
        boolean configsChanged  = false;
        snapshot.cancelPendingActions();
        snapshot.rollbackChannels();
        snapshot.rollbackGroups();
        packagesChanged = snapshot.rollbackPackages(user);
        configsChanged   = snapshot.rollbackConfigFiles(user);

        createSuccessMessage(request, GROUPS_CHANGED_MSG, null);
        if (packagesChanged) {
            createSuccessMessage(request, PACKAGES_CHANGED_MSG, null);
        }
        if (configsChanged) {
            createSuccessMessage(request, CONFIGS_CHANGED_MSG, null);
        }
        return HISTORY_FORWARD;
    }
}
