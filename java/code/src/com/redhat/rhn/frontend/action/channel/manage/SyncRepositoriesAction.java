/**
 * Copyright (c) 2010 Red Hat, Inc.
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

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.ContentSource;
import com.redhat.rhn.domain.task.TaskFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.taskomatic.task.RepoSyncTask;

/**
 *
 * SyncRepositoriesAction
 * @version $Rev$
 */
public class SyncRepositoriesAction extends RhnAction implements Listable {

  /**
   *
   * {@inheritDoc}
   */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext context = new RequestContext(request);
        User user =  context.getLoggedInUser();

        long cid = context.getRequiredParam("cid");
        Channel chan = ChannelFactory.lookupByIdAndUser(cid, user);
        request.setAttribute("channel_name", chan.getName());

        Map params = new HashMap();
        params.put(RequestContext.CID, chan.getId().toString());

        ListHelper helper = new ListHelper(this, request, params);

        helper.execute();

        if (context.isSubmitted()) {

            TaskFactory.createTask(user.getOrg(),
                    RepoSyncTask.DISPLAY_NAME, chan.getId());

            StrutsDelegate strutsDelegate = getStrutsDelegate();
            createSuccessMessage(request, "message.syncscheduled",
                    chan.getName());

            return strutsDelegate.forwardParams
            (mapping.findForward("success"), params);
        }

        return mapping.findForward("default");
    }

        /**
         *
         * {@inheritDoc}
         */
        public List<ContentSource> getResult(RequestContext context) {
            User user =  context.getLoggedInUser();
            long cid = context.getRequiredParam("cid");
            Channel chan = ChannelFactory.lookupByIdAndUser(cid, user);
            return ChannelFactory.lookupContentSources(user.getOrg(), chan);
        }
}
