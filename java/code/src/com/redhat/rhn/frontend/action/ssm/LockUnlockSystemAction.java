/**
 * Copyright (c) 2013 SUSE LLC
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
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;
import java.util.Iterator;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

/**
 *
 * @author bo
 */
public class LockUnlockSystemAction extends RhnListAction {

    /**
     * {@inheritDoc}
     */
    @Override
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm actionForm,
                                 HttpServletRequest request,
                                 HttpServletResponse response)
            throws Exception {

        ActionMessages actionMessages = new ActionMessages();
        ActionErrors actionErrors = new ActionErrors();
        RequestContext context = new RequestContext(request);
        DynaActionForm form = (DynaActionForm) actionForm;
        RhnListSetHelper listHelper = new RhnListSetHelper(request);
        RhnSet set = RhnSetDecl.SSM_SYSTEMS_SET_LOCK.get(context.getCurrentUser());

        if (request.getParameter("dispatch") != null) {
            int locledSys = 0;
            int unlockedSys = 0;
            boolean lck = context.wasDispatched("ssm.misc.lockunlock.dispatch.lock");
            boolean unlck = context.wasDispatched("ssm.misc.lockunlock.dispatch.unlock");
            if (lck || unlck) {
                String reason = StringUtil.nullIfEmpty(form.getString("lock_reason"));
                Iterator<Long> serverIdsIterator = set.getElementValues().iterator();
                while (serverIdsIterator.hasNext()) {
                    Server server = SystemManager.lookupByIdAndUser(
                            serverIdsIterator.next(), context.getCurrentUser());
                    if (lck && (server.getLock() == null)) {
                        if (reason == null) {
                            reason = LocalizationService.getInstance()
                                         .getMessage("sdc.details.overview.lock.reason");
                        }

                        SystemManager.lockServer(context.getCurrentUser(),
                                                 server, reason);
                        locledSys++;
                    }
                    else if (unlck && (server.getLock() != null)) {
                        SystemManager.unlockServer(context.getCurrentUser(), server);
                        unlockedSys++;
                    }
                }

                if (lck) {
                    actionMessages.add(ActionMessages.GLOBAL_MESSAGE,
                          new ActionMessage("ssm.misc.lockunlock.message.locked" +
                                            (set.size() == locledSys ? ".all" : "") +
                                            (locledSys > 0 ? ".success" : ".skipped"),
                            set.size(), locledSys));
                }
                else if (unlck) {
                    actionMessages.add(ActionMessages.GLOBAL_MESSAGE,
                          new ActionMessage("ssm.misc.lockunlock.message.unlocked" +
                                            (set.size() == unlockedSys ? ".all" : "") +
                                            (unlockedSys > 0 ? ".success" : ".skipped"),
                            set.size(), unlockedSys));
                }
            }
        }

        this.bindData(listHelper, set, request);
        this.getStrutsDelegate().saveMessages(request, actionMessages);
        this.getStrutsDelegate().saveMessages(request, actionErrors);

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }


    private void bindData(RhnListSetHelper listHelper,
                          RhnSet set, HttpServletRequest request) {
        List result = this.getResult(new RequestContext(request));
        if (ListTagHelper.getListAction("systemList", request) != null) {
            listHelper.execute(set, "systemList", result);
        }

        if (!set.isEmpty()) {
            listHelper.syncSelections(set, result);
            ListTagHelper.setSelectedAmount("systemList", set.size(), request);
        }

        ListTagHelper.bindSetDeclTo("systemList",
                                    RhnSetDecl.SSM_SYSTEMS_SET_LOCK,
                                    request);
        request.setAttribute(RequestContext.PAGE_LIST, result);
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        TagHelper.bindElaboratorTo("systemList",
                                   ((DataResult) result).getElaborator(), request);
    }


    /**
     * {@inheritDoc}
     */
    public List getResult(RequestContext context) {
        List<SystemOverview> systems = SystemManager.inSet(context.getCurrentUser(),
                                                           RhnSetDecl.SYSTEMS.getLabel());
        for (int i = 0; i < systems.size(); i++) {
            SystemOverview systemOverview = systems.get(i);
            systemOverview.setSelectable(1);
            Channel channel = SystemManager.lookupByIdAndUser(systemOverview.getId(),
                    context.getCurrentUser()).getBaseChannel();
            if (channel != null) {
                systemOverview.setChannelLabels(channel.getName());
            }
        }

        return systems;
    }

}
