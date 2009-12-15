/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.errata;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.util.LabelValueBean;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/** @version $Revision$ */
public class AddPackagesAction extends RhnAction implements Listable {

    private static final String DATA_SET = "pageList";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping actionMapping,
                                 ActionForm actionForm,
                                 HttpServletRequest request,
                                 HttpServletResponse response)
        throws Exception {

        request.setAttribute("parentUrl", request.getRequestURI());

        RequestContext context = new RequestContext(request);
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("eid", context.getRequiredParam("eid"));


        RhnSetDecl decl = RhnSetDecl.PACKAGES_TO_ADD.createCustom(
                context.getRequiredParam("eid"));

        if (request.getParameter("view_clicked") != null) {
            RhnSet set = decl.get(context.getCurrentUser());
            set.clear();
            RhnSetManager.store(set);
        }
        ListRhnSetHelper helper = new ListRhnSetHelper(this, request, decl);
        helper.setDataSetName(DATA_SET);


        // If it's a view change, don't throw a message saying there was nothing selected
        if (request.getParameter("view_channel") != null) {
            helper.ignoreEmptySelection();
        }

        helper.execute();

        if (helper.isDispatched()) {
            Long eid = context.getRequiredParam("eid");
            StrutsDelegate strutsDelegate = getStrutsDelegate();
            return strutsDelegate.forwardParam(actionMapping.findForward("confirm"),
                "eid", eid.toString());
        }

        StrutsDelegate strutsDelegate = getStrutsDelegate();
        return strutsDelegate.forwardParams(
            actionMapping.findForward(RhnHelper.DEFAULT_FORWARD), params);
    }

    /** {@inheritDoc} */
    public List getResult(RequestContext context) {
        HttpServletRequest request = context.getRequest();
        User user = context.getLoggedInUser();

        // Put the advisory into the request for the page header
        Errata errata = new RequestContext(request).lookupErratum();
        request.setAttribute("advisory", errata.getAdvisory());

        // Add the view options for the page to use in the drop down
        request.setAttribute("viewoptions", getViewOptions(user));

        String viewChannel = getSelectedCid(context);

        DataResult result;
        if (viewChannel.equals("any_channel")) {
            // Packages from all channels should be displayed
            result = PackageManager.packagesAvailableToErrata(errata);
        }
        else {
            // Packages from a specific channel should be displayed
            Long cid = new Long(viewChannel);
            result =
                PackageManager.packagesAvailableToErrataInChannel(errata, cid, user);
        }

        TagHelper.bindElaboratorTo("groupList", result.getElaborator(), request);

        return result;
    }


    private String getSelectedCid(RequestContext context) {
        String viewChannel = context.getRequest().getParameter("view_channel");
        if (viewChannel == null) {
            return "any_channel";
        }
        return viewChannel;
    }

    /**
     * Helper method to init the viewoptions list. This becomes the drop-down
     * select box for channels.
     *
     * @param user The logged in user
     * @return Returns a list of LabelValueBeans to set in the request for
     *         the page.
     */
    private List getViewOptions(User user) {
        // List containing the names of the channels this user has permissions to. 
        List subscribableChannels = ChannelManager.channelsForUser(user);

        //Init the viewoptions list to contain the "any_channel" option
        List<LabelValueBean> viewoptions = new ArrayList<LabelValueBean>();
        viewoptions.add(new LabelValueBean("All managed packages",
            "any_channel"));

        Org org = user.getOrg();
        Set channels = org.getOwnedChannels();

        // Loop through the channels and see if the channel name is in the list of
        // subscribable channels. If so, add it to the viewoptions list.
        for (Iterator itr = channels.iterator(); itr.hasNext();) {
            //get the channel from the list
            Channel channel = (Channel) itr.next();
            if (subscribableChannels.contains(channel.getName())) {
                //Channel is subscribable by this user so add it to the list of options
                viewoptions.add(new LabelValueBean(channel.getName(),
                    channel.getId().toString()));
            }
        }

        return viewoptions;
    }

}
