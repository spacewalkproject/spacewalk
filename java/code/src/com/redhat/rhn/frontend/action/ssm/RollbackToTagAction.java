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
package com.redhat.rhn.frontend.action.ssm;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.ServerSnapshot;
import com.redhat.rhn.domain.server.SnapshotTag;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * RollbackToTagAction
 */
public class RollbackToTagAction extends RhnAction implements Listable {
    protected static final String TAG_ID = "tag_id";
    protected static final String TAG_NAME = "tag_name";
    /**
     * ${@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) throws Exception {
        RequestContext context = new RequestContext(request);
        Long tagId = context.getRequiredParam(TAG_ID);
        if (context.wasDispatched("ssm.provisioning.rollbacktotag.rollback-button")) {
            rollback(context, tagId);
            return mapping.findForward(RhnHelper.CONFIRM_FORWARD);
        }

        SnapshotTag tag = ServerFactory.lookupSnapshotTagbyId(tagId);

        ListHelper helper = new ListHelper(this, request);
        helper.execute();

        Map<String, Object> params = makeParamMap(request);
        params.put(TAG_ID, tagId);
        params.put(TAG_NAME, tag.getName().getName());

        return getStrutsDelegate().forwardParams(
                mapping.findForward(RhnHelper.DEFAULT_FORWARD), params);
    }

    /**
     * ${@inheritDoc}
     */
    public List getResult(RequestContext context) {
        Long uid = context.getCurrentUser().getId();
        Long tagid = context.getRequiredParam(TAG_ID);
        return SystemManager.systemsInSetWithTag(uid, tagid);
    }

    private void rollback(RequestContext context, Long tagId) {
        User user = context.getCurrentUser();
        DataResult<Map<String, Object>> systems =
                    SystemManager.systemsInSetWithTag(user.getId(), tagId);
        for (Map<String, Object> system : systems) {
            ServerSnapshot snapshot = ServerFactory.lookupSnapshotById(
                                         ((Long) system.get("snapshot_id")).intValue());
            snapshot.cancelPendingActions();
            snapshot.rollbackChannels();
            snapshot.rollbackGroups();
            snapshot.rollbackPackages(user);
            snapshot.rollbackConfigFiles(user);
        }
    }
}
