/**
 * Copyright (c) 2008 Red Hat, Inc.
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
        List<Long> unsubs = setupList(user, request);
        
        // If submitted, save the user's choices for the confirm page
        if (isSubmitted(daForm) && request.getParameter("dispatch") != null) {
            return processList(user, unsubs, request, mapping);
        }
        // Otherwise let the JSP display the list
        else {
            return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
        }
    }

    // Get the list of child-channels available to the System Set
    // and create a data-structure mapping them to their respective base-channels
    // Return list of channels that might be unsubscribed-from
    protected List<Long> setupList(User user, HttpServletRequest request) {
        
        DataResult dr = ChannelManager.childrenAvailableToSet(user);
        List<ChildChannelDto> children = new ArrayList(dr);
        List<Long> noSubsChildren = new ArrayList();
        
        dr = ChannelManager.baseChannelsInSet(user);
        List<SystemsPerChannelDto> bases = new ArrayList(dr);
        request.setAttribute("bases", bases);
        
        int debugFound = 0;
        int nullParentsFound = 0;
        Set<ChildChannelDto> nullParented = new HashSet<ChildChannelDto>();
        // Build a map of parents-to-children
        // (the combinatorics of this algorithm aren't very good, there is
        // room for a little optimisation here
        for (SystemsPerChannelDto spc : bases) {
            List<ChildChannelDto> c4b = new ArrayList();
            spc.setAvailableChildren(c4b);
            
            // Find all the children for "this" parent
            for (ChildChannelDto ccd : children) {
                if (ccd.getParentId() == null) {
                    if (!nullParented.contains(ccd)) {
                        nullParented.add(ccd);
                        nullParentsFound++;
                        debugFound++;
                    }
                }
                else if (ccd.getParentId().equals(spc.getId())) {
                    DataResult sis = SystemManager.systemsSubscribedToChannelInSet(
                            ccd.getId().longValue(), user, RhnSetDecl.SYSTEMS.getLabel());
                    // Is anybody subscribed?  Then we might unsubscribe
                    if (sis.size() > 0) {
                        noSubsChildren.add(ccd.getId().longValue());
                    }
                    ccd.setSystemCount(0L + sis.size());
                    c4b.add(ccd);
                    debugFound++;
                }
            }
        }
        assert debugFound == children.size();
        return noSubsChildren;
    }

    // Check all incoming parameters.  For any whose value is "subscribe", the name is the 
    // CID of the affected channel.  Once all such are extracted, store the data in an 
    // RhnSet for future pages to take advantage of
    protected ActionForward processList(User user, List<Long> unsubs,
            HttpServletRequest request, ActionMapping mapping) {
        // Create the list of all channels that have "subscribe" selected
        List<String> subList = new ArrayList();

        Enumeration names = request.getParameterNames();
        while (names.hasMoreElements()) {
            String aName = (String)names.nextElement();
            String aValue = request.getParameter(aName);
            if ("subscribe".equals(aValue)) {
                subList.add(aName);
            }
        }

        setupChannelListSet(user, subList, unsubs);
        return mapping.findForward("success");
    }

    // Store the sub/unsub info in the SSM_CHANNEL_LIST
    protected void setupChannelListSet(User u, List<String> subs, List<Long> unsubs) {
        // Keep track of things we want to subscribe-to
        Set<Long> subscribingTo = new HashSet(); 
        
        RhnSet cset = RhnSetDecl.SSM_CHANNEL_LIST.create(u);
        cset.clear();
        
        for (String idStr : subs) {
            try {
                Long id = Long.parseLong(idStr);
                cset.addElement(id, ChannelActionDAO.SUBSCRIBE);
                subscribingTo.add(id);
            }
            catch (NumberFormatException nfe) {
                // We can't possibly be here - what to do?!?
            }
        }
        
        // List of channels available to be unsubscribed-from
        for (Long id : unsubs) {
            // If we're not SUBSCRIBING, then we're UNSUBSCRIBING
            if (!subscribingTo.contains(id)) {
                cset.addElement(id, ChannelActionDAO.UNSUBSCRIBE);
            }
        }
        RhnSetManager.store(cset);
    }
}
