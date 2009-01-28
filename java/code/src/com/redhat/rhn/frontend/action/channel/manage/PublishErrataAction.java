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
package com.redhat.rhn.frontend.action.channel.manage;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.errata.impl.PublishedClonedErrata;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.errata.cache.ErrataCacheManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;


/**
 * 
 * PublishErrataAction
 * @version $Rev$
 */
public class PublishErrataAction extends RhnListAction {

    
    private static final String CID = "cid";

    /**
     * 
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        User user =  requestContext.getLoggedInUser();
        Long cid = Long.parseLong(request.getParameter(CID));
        Channel currentChan = ChannelFactory.lookupByIdAndUser(cid, user);
   
        PublishErrataHelper.checkPermissions(user);
        
        RhnSet  packageSet = RhnSetDecl.PACKAGES_TO_ADD.get(user);
        Set<Long> packageIds = packageSet.getElementValues();
        
       
        List<Errata> errataSet = ErrataFactory.lookupErrataInSet(user); 
        for (Errata errata : errataSet) {
            if (errata instanceof PublishedClonedErrata) {
                errata.addChannel(currentChan);
            }
            else {
                Set<Channel> channelSet = new HashSet<Channel>();
                channelSet.add(currentChan);
                
                Errata published = PublishErrataHelper.cloneErrataFast(errata, 
                        user.getOrg());
                published.setChannels(channelSet);
            }
        }
 
        List<Long> pids = new ArrayList<Long>();
        for (Package pack : PackageFactory.lookupPackagesFromSet(user)) {
            currentChan.addPackage(pack); 
            pids.add(pack.getId());
        }
        
        //update the errata info
        List chanList = new ArrayList();
        chanList.add(currentChan.getId());
        ErrataCacheManager.insertCacheForChannelPackagesAsync(chanList, pids);
        ChannelManager.refreshWithNewestPackages(currentChan, "web.errata_push");
        request.setAttribute("cid", cid);
        
        ActionMessages msg = new ActionMessages();
        String[] params = {errataSet.size() + "", packageIds.size() + "", 
                currentChan.getName()};
        msg.add(ActionMessages.GLOBAL_MESSAGE, 
                new ActionMessage("frontend.actions.channels.manager.add.success", 
                        params));
        
        getStrutsDelegate().saveMessages(requestContext.getRequest(), msg);
        
        return mapping.findForward("default");
    }

    
    

    
}
