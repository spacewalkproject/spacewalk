/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.configuration.ssm;

import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.action.configuration.ConfigChannelSetComparator;
import com.redhat.rhn.frontend.dto.ConfigSystemDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * SubscribeConfirmSetup, for ssm config subscribe.
 * @version $Rev$
 */
public class SubscribeConfirm extends RhnAction {
    private static final String REPLACE = "replace";
    private static final String LOWEST = "lowest";
    private static final String HIGHEST = "highest";
    private static final String POSITION = "position";

    /**
     * Set up the page.
     * @param mapping struts ActionMapping
     * @param formIn struts ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return an ActionForward to the same page
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn, HttpServletRequest request,
            HttpServletResponse response) {
        //check that we have a viable priority
        checkPosition(request);

        //typical stuff
        RequestContext context = new RequestContext(request);
        User user = context.getLoggedInUser();

        //Decide whether we are visiting the same page or
        //performing the subscribe.
        String dispatch = request.getParameter("dispatch");
        if (dispatch != null && dispatch.equals(LocalizationService
                .getInstance().getMessage("ssm.config.subscribeconfirm.jsp.confirm"))) {
            return confirm(mapping, request, user);
        }
        return setup(mapping, request, user);

    }

    private ActionForward setup(ActionMapping mapping,
            HttpServletRequest request, User user) {
        //Get the data
        ConfigurationManager cm = ConfigurationManager.getInstance();
        List channels = cm.ssmChannelsInSetForSubscribe(user);
        List systems = cm.ssmSystemsForSubscribe(user);

        //Create the parent url. Copy the one important parameter.
        StringBuffer parentUrl = new StringBuffer();
        parentUrl.append(request.getRequestURI());
        parentUrl.append("?");
        parentUrl.append(POSITION);
        parentUrl.append("=");
        parentUrl.append(request.getParameter(POSITION));

        //store the data so the list tag can see it
        request.setAttribute(ListTagHelper.PARENT_URL, parentUrl.toString());
        request.setAttribute("channelList", channels);
        request.setAttribute("systemList", systems);

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /**
     * Subscribe to config channels
     * @param mapping struts ActionMapping
     * @param request HttpServletRequest
     * @param user The user confirming config subscriptions.
     * @return an ActionForward to a page with a success message.
     */
    private ActionForward confirm(ActionMapping mapping,
            HttpServletRequest request, User user) {
        //get where we are supposed to put new channels
        //validate the position parameter
        String position = request.getParameter(POSITION);
        checkPosition(request);

        List systems = ConfigurationManager.getInstance().ssmSystemsForSubscribe(user);
        RhnSet channels = RhnSetDecl.CONFIG_CHANNELS.get(user);

        //visit every server and change their subscriptions
        //keep track of how many servers we have changed
        int successes = 0;
        Iterator i = systems.iterator();
        while (i.hasNext()) {
            Long sid = ((ConfigSystemDto)i.next()).getId();
            try {
                Server server = SystemManager.lookupByIdAndUser(sid, user);

                if (subscribeServer(user, server, channels, position)) {
                    successes++;
                }
            }
            catch (LookupException e) {
                //skip this server
            }
        }

        ConfigActionHelper.clearRhnSets(user);

        //Give the user a message about how many servers we have changed.
        if (successes == 1) {
            getStrutsDelegate().saveMessage("ssm.config.subscribeconfirm.jsp.onesuccess",
                    request);
        }
        else {
            String[] params = {new Integer(successes).toString()};
            getStrutsDelegate().saveMessage("ssm.config.subscribeconfirm.jsp.success",
                    params, request);
        }

        return mapping.findForward("success");
    }

    private boolean subscribeServer(User user, Server server,
            RhnSet toSubsChs, String position) {
        boolean retval = false; // whether subscriptions have changed
        // save the currently subscribed channels
        List currentChs = new ArrayList(server.getConfigChannels());
        ConfigurationManager cm = ConfigurationManager.getInstance();

        // for LOWEST the current channel subscription stays preserved
        if (!position.equals(LOWEST)) {
            server.getConfigChannels().clear();
        }

        // Order the new channels in the order requested by user
        List rankElements = new ArrayList(
                RhnSetDecl.CONFIG_CHANNELS_RANKING.get(user).getElements());
        Collections.sort(rankElements, new ConfigChannelSetComparator());
        Iterator i = rankElements.iterator();

        // subscribe to the new channels
        while (i.hasNext()) {
            Long ccid = ((RhnSetElement)i.next()).getElement();
            ConfigChannel channel = cm.lookupConfigChannel(user, ccid);

            if (currentChs.contains(channel)) {
                // for REPLACE we need to re-subscribe current channels
                // in order requested by user
                if (position.equals(REPLACE)) {
                    server.subscribe(channel);
                }
            }
            else {
                if (toSubsChs.contains(channel.getId())) {
                    // subscribe new channels
                    server.subscribe(channel);
                    retval = true;
                }
            }
        }

        if (position.equals(HIGHEST)) {
            // for HIGHEST we have to re-subscribe to the channels the system was
            // originally subscribed to
            Iterator j = currentChs.iterator();
            while (j.hasNext()) {
                server.subscribe((ConfigChannel)j.next());
            }
        }
        return retval;
    }

    private void checkPosition(HttpServletRequest request) {
        String position = request.getParameter(POSITION);
        String[] valids = {REPLACE, LOWEST, HIGHEST};
        if (!Arrays.asList(valids).contains(position)) {
            throw new BadParameterException("Invalid position value!");
        }
    }

}
