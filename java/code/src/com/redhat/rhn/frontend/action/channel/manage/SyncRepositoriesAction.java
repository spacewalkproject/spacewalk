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

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.util.RecurringEventPicker;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.ContentSource;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import redstone.xmlrpc.XmlRpcClient;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcFault;

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
    @Override
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


        RecurringEventPicker picker = RecurringEventPicker.prepopulatePicker(
                request, "date", null);
        helper.execute();

        if (context.isSubmitted()) {
            StrutsDelegate strutsDelegate = getStrutsDelegate();

            // check user permissions first
            if (!UserManager.verifyChannelAdmin(user, chan)) {
                createErrorMessage(request,
                        "frontend.actions.channels.manager.add.permsfailure", null);
                return mapping.findForward("default");
            }

            try {
                XmlRpcClient taskomatic = new XmlRpcClient(
                        ConfigDefaults.get().getTaskoServerUrl(), false);

                if (context.wasDispatched("repos.jsp.button-sync")) {
                    // schedule one time repo sync
                    List args = new ArrayList();
                    args.add(user.getOrg().getId());
                    args.add("repo-sync-bunch");
                    Map scheduleParams = new HashMap();
                    scheduleParams.put("channel_id", chan.getId().toString());
                    args.add(scheduleParams);

                    try {
                        taskomatic.invoke("tasko.scheduleSingleBunchRun", args);
                        createSuccessMessage(request, "message.syncscheduled",
                                chan.getName());
                    }
                    catch (XmlRpcException e) {
                        createErrorMessage(request, "repos.jsp.message.taskoaccess", null);
                    }
                    catch (XmlRpcFault e) {
                        createErrorMessage(request,
                                "repos.jsp.message.schedulefailed", null);
                        e.printStackTrace();
                    }
                }
                else if (context.wasDispatched("schedule.button")) {
                    // schedule periodic errata
                    List args = new ArrayList();
                    args.add(user.getOrg().getId());
                    args.add("repo-sync-bunch");
                    args.add("repo-sync-" + user.getOrg().getId() + "-" + cid);
                    args.add(picker.getCronEntry());
                    Map scheduleParams = new HashMap();
                    scheduleParams.put("channel_id", chan.getId().toString());
                    args.add(scheduleParams);

                    try {
                        Date date = (Date) taskomatic.invoke("tasko.scheduleBunch", args);
                        createSuccessMessage(request, "message.syncscheduled",
                                chan.getName());
                    }
                    catch (XmlRpcException e) {
                        createErrorMessage(request, "repos.jsp.message.taskoaccess", null);
                    }
                    catch (XmlRpcFault e) {
                        createErrorMessage(request,
                                "repos.jsp.message.schedulefailed", null);
                        e.printStackTrace();
                    }
                }
            }
            catch (MalformedURLException e) {
                createErrorMessage(request, "repos.jsp.message.taskoaccess", null);
            }

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
