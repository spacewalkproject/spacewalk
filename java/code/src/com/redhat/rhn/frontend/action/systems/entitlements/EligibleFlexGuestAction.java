/**
 * Copyright (c) 2010--2012 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.systems.entitlements;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ChannelFamilySystem;
import com.redhat.rhn.frontend.dto.ChannelFamilySystemGroup;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.helper.ListSessionSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.system.VirtualizationEntitlementsManager;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * EligibleFlexGuestAction
 * @version $Rev$
 */
public class EligibleFlexGuestAction extends RhnAction implements Listable {

    private static final String SELECTABLE = "selectable";
    private static final String SELECTED_FAMILY = "channel_family";
    private static final String ALL = "all";

    /**
     *
     * {@inheritDoc}
     */
    @Override
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        request.setAttribute(SELECTABLE, Boolean.TRUE);

        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getLoggedInUser();
        //user.hasRole(RoleFactory.ORG_ADMIN)
        ListSessionSetHelper helper = new ListSessionSetHelper(this, request);
        helper.execute();
        if (helper.isDispatched()) {
            RequestContext context = new RequestContext(request);
            return handleConfirm(helper, context, mapping);
        }

        request.setAttribute("selected_family", getSelectedChannel(requestContext));
        return mapping.findForward("default");
    }

    protected String getSelectedChannel(RequestContext requestContext) {
        if (requestContext.isSubmitted()) {
            if (requestContext.getRequest().getParameter("show") == null) {
               return requestContext.getRequest().getParameter("selected_family");
            }
            String selected = requestContext.getRequest().getParameter(SELECTED_FAMILY);
            return  selected == null ? "" : selected;
        }
        return ALL;
    }


    private ActionForward handleConfirm(ListSessionSetHelper helper, RequestContext context,
            ActionMapping mapping) {

        String chanFamily = getSelectedChannel(context);

        Map<Long, Set<Long>> familyGroups = new HashMap<Long, Set<Long>>();
        if (chanFamily.equals(ALL)) {
            for (String selectionKey : helper.getSet()) {
                Server s = ServerFactory.lookupById(Long.parseLong(selectionKey));
                for (Channel c : s.getChannels()) {
                    Long cfid = c.getChannelFamily().getId();
                    if (!familyGroups.containsKey(cfid)) {
                        familyGroups.put(cfid, new HashSet<Long>());
                    }
                    familyGroups.get(cfid).add(s.getId());
                }
            }
        }
        else {
            Long familyId = Long.parseLong(chanFamily);
            familyGroups.put(Long.parseLong(chanFamily), new HashSet<Long>());
            for (String selectionKey : helper.getSet()) {
                    familyGroups.get(familyId).add(Long.parseLong(selectionKey));
            }
        }


        Set<Long> success = new HashSet<Long>();
        for (Long cfid : familyGroups.keySet()) {
            List<Long> sids = new ArrayList<Long>(familyGroups.get(cfid));
            success.addAll(VirtualizationEntitlementsManager.
                    getInstance().convertToFlex(sids, cfid, context.getLoggedInUser()));
        }

        helper.destroy();

        getStrutsDelegate().saveMessage("eligible.flexguest.systems.confirm.message",
                new String [] { String.valueOf(success.size())},
                context.getRequest());
        return  mapping.findForward("success");
    }



    protected List<ChannelFamilySystemGroup> query(RequestContext contextIn) {
        return VirtualizationEntitlementsManager.getInstance().
        listEligibleFlexGuests(contextIn.getLoggedInUser());
    }

    /**
     * {@inheritDoc}
     */
    public List getResult(RequestContext contextIn) {
        //set channel family list
        List<ChannelFamilySystemGroup> list = query(contextIn);

        //Not really the right place to do this, but I want to touch the manager layer
        //  as little as possible
        Collections.sort(list);
        contextIn.getRequest().setAttribute("family_list", list);


        String famId = getSelectedChannel(contextIn);
        if (StringUtils.isEmpty(famId) || famId.equals(ALL)) {
            Map sysMap = new HashMap();

            for (ChannelFamilySystemGroup grp : list) {
                for (ChannelFamilySystem sys : grp.expand()) {
                    sysMap.put(sys.getId(), sys);
                }
            }
            return new ArrayList(sysMap.values());
        }
        for (ChannelFamilySystemGroup grp : list) {
            if (grp.getId().toString().equals(famId)) {
                return grp.expand();
            }
        }

        return new ArrayList();
    }
}
