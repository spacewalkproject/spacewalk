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
package com.redhat.rhn.frontend.action.channel.ssm;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ChildChannelDto;
import com.redhat.rhn.frontend.dto.SystemsPerChannelDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ChildChannelAction
 * @version $Rev$
 */
public class ChildChannelAction extends RhnAction {

    private final Log log = LogFactory.getLog(this.getClass());

    /**
     * {@inheritDoc}
     */
    @Override
    public ActionForward execute(ActionMapping mapping,
            ActionForm form,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        RequestContext rctx = new RequestContext(request);
        User user = rctx.getLoggedInUser();
        DynaActionForm daForm = (DynaActionForm)form;

        request.setAttribute("parentUrl", request.getRequestURI());

        // Provide the list of all child-channels for all systems in the SSM
        setupList(user, request);

        // If submitted, save the user's choices for the confirm page
        if (isSubmitted(daForm) && request.getParameter("dispatch") != null) {
            processList(user, request);
            return mapping.findForward("success");
        }
        // Otherwise let the JSP display the list
        else {
            return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
        }
    }

    // Get the list of child-channels available to the System Set
    // and create a data-structure mapping them to their respective base-channels
    protected void setupList(User user, HttpServletRequest request) {

        DataResult dr = ChannelManager.childrenAvailableToSet(user);
        List<ChildChannelDto> children = new ArrayList<ChildChannelDto>(dr);

        dr = ChannelManager.baseChannelsInSet(user);
        List<SystemsPerChannelDto> bases = new ArrayList<SystemsPerChannelDto>(dr);
        request.setAttribute("bases", bases);

        int debugFound = 0;
        Set<ChildChannelDto> nullParented = new HashSet<ChildChannelDto>();

        // Build a map of parents-to-children
        // (the combinatorics of this algorithm aren't very good, there is
        // room for a little optimisation here
        for (SystemsPerChannelDto systemsPerChannelDto : bases) {

            List<ChildChannelDto> availableChildren = new ArrayList<ChildChannelDto>();
            systemsPerChannelDto.setAvailableChildren(availableChildren);

            // Find all the children for "this" parent
            for (ChildChannelDto childChannelDto : children) {
                if (childChannelDto.getParentId() == null) {
                    if (!nullParented.contains(childChannelDto)) {
                        nullParented.add(childChannelDto);
                        debugFound++;
                    }
                }
                else if (childChannelDto.getParentId().equals(
                    systemsPerChannelDto.getId())) {
                    DataResult sis = SystemManager.systemsSubscribedToChannelInSet(
                            childChannelDto.getId().longValue(), user,
                        RhnSetDecl.SYSTEMS.getLabel());
                    childChannelDto.setSystemCount(0L + sis.size());
                    availableChildren.add(childChannelDto);
                    debugFound++;
                }
            }
        }

        if (debugFound != children.size()) {
            log.error("Did not process an equal number of children originally found. " +
                "Children: " + children.size() + ", Found: " + debugFound);
        }
    }

    /**
     * Processes the submitted parameters to determine which channels are being
     * subscribed, unsubscribed, or ignored. The first two sets will be stored as
     * RhnSets for later usage.
     *
     * @param user    user making the request
     * @param request http request to grab the user submitted data from
     */
    protected void processList(User user, HttpServletRequest request) {

        List<String> subList = new ArrayList<String>();
        List<String> unsubList = new ArrayList<String>();

        Enumeration names = request.getParameterNames();
        while (names.hasMoreElements()) {
            String aName = (String)names.nextElement();
            String aValue = request.getParameter(aName);
            if ("subscribe".equals(aValue)) {
                subList.add(aName);
            }
            else if ("unsubscribe".equals(aValue)) {
                unsubList.add(aName);
            }
        }

        storeChannelChanges(user, subList, unsubList);
    }

    /**
     * Stores the user-selected lists of channels to (un)subscribe to in RhnSets
     * to be used later.
     *
     * @param user   user making the request
     * @param subs   subscriptions to be created
     * @param unsubs subscriptions to be removed
     */
    protected void storeChannelChanges(User user, List<String> subs, List<String> unsubs) {
        RhnSet cset = RhnSetDecl.SSM_CHANNEL_LIST.create(user);
        cset.clear();

        for (String idStr : subs) {
            try {
                Long id = Long.parseLong(idStr);
                cset.addElement(id, ChannelActionDAO.SUBSCRIBE);
            }
            catch (NumberFormatException nfe) {
                // Should never get here
                log.error("Attempting to parse a channel id from: " + idStr, nfe);
            }
        }

        for (String idStr : unsubs) {
            try {
                Long id = Long.parseLong(idStr);
                cset.addElement(id, ChannelActionDAO.UNSUBSCRIBE);
            }
            catch (NumberFormatException nfe) {
                // Should never get here
                log.error("Attempting to parse a channel id from: " + idStr, nfe);
            }
        }

        RhnSetManager.store(cset);
    }
}
