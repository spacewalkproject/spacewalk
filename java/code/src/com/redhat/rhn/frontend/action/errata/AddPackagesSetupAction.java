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
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.util.LabelValueBean;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * AddPackagesSetupAction
 * @version $Rev$
 */
public class AddPackagesSetupAction extends BaseErrataSetupAction {
    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        
        //Get the errata from the eid in the request
        Errata errata = requestContext.lookupErratum();
        //Get the logged in user
        User user = requestContext.getLoggedInUser();
        
        //Setup the page control for this user
        PageControl pc = new PageControl();
        pc.setIndexData(true);
        pc.setFilterColumn("package_nvre");
        pc.setFilter(true);
        clampListBounds(pc, request, user);
        
        DataResult dr;
        if (request.getParameter("view_channel") == null || //first time customer
            request.getParameter("view_channel").equals("any_channel")) {
            /*
             * Get packages for *all* channels.
             * View: All managed packages
             */
            dr = PackageManager.packagesAvailableToErrata(errata, user, pc);
        }
        else { //must have a cid for view_channel
            Long cid = new Long(request.getParameter("view_channel"));
            //TODO: add some error checking here
            dr = PackageManager.packagesAvailableToErrataInChannel(errata, cid, 
                                                                   user, pc);
        }
        
        request.setAttribute("pageList", dr);
        RhnSet set = RhnSetDecl.PACKAGES_TO_ADD.get(user);
        request.setAttribute("set", set);
        request.setAttribute("viewoptions", getViewOptions(user));
        //return default mapping
        return super.execute(mapping, formIn, request, response);
    }
    
    /**
     * Helper method to init the viewoptions list. This becomes the drop-down
     * select box for channels.
     * @param user The logged in user
     * @return Returns a list of LabelValueBeans to set in the request for
     * the page.
     */
    private List getViewOptions(User user) {
        //subscribableChannels is a list containing the names of the 
        //channels this user has permissions to. 
        List subscribableChannels = ChannelManager.channelsForUser(user);
        
        //Init the viewoptions list to contain the "any_channel" option
        List viewoptions = new ArrayList();
        viewoptions.add(new LabelValueBean("All managed packages", 
                                           "any_channel"));
        
        Org org = user.getOrg();
        Set channels = org.getOwnedChannels();
        
        /*
         * Loop through the channels and see if the channel name is in the 
         * list of subscribable channels. If so, add it to the viewoptions
         * list.
         */
        Iterator itr = channels.iterator();
        while (itr.hasNext()) {
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
