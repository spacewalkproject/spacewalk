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
package com.redhat.rhn.frontend.action.channel.manage;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.PatchSetOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.Iterator;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 
 * PatchSetListAction
 * @version $Rev$
 */
public class PatchSetListAction extends RhnListAction {
    
    private final String LIST_NAME = "patchsetlist";
    
    /**
     * 
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        

        RequestContext requestContext = new RequestContext(request);
        
        User user = requestContext.getCurrentUser();
        Channel chan = ChannelFactory.lookupByIdAndUser(
                Long.parseLong(request.getParameter("cid")), user);
        
        if (!(UserManager.verifyChannelAdmin(user, chan) ||
                user.hasRole(RoleFactory.CHANNEL_ADMIN))) {
              throw new PermissionCheckFailureException();
        }
        
        
        RhnSet set =  getDecl().get(user);
        if (!requestContext.isSubmitted()) {
            set.clear();
            RhnSetManager.store(set);
        }        
        

        DataResult<PatchSetOverview> patchSets = 
            PackageManager.listPatchSetsForChannel(chan.getId());
        
        
        RhnListSetHelper helper = new RhnListSetHelper(request);
 
  
        if (request.getParameter(RequestContext.DISPATCH) != null) {
            // if its one of the Dispatch actions handle it..            
            helper.updateSet(set, LIST_NAME);
        }
        
        if (ListTagHelper.getListAction(LIST_NAME, request) != null) {
            helper.execute(set, LIST_NAME, patchSets);
        }

        if (!set.isEmpty()) {
            helper.syncSelections(set, patchSets);
            ListTagHelper.setSelectedAmount(LIST_NAME, set.size(), request);            
        }
        
        if (requestContext.wasDispatched("channel.manage.patchset.delete")) {
            for (Iterator<Long> itr = set.getElementValues().iterator(); itr.hasNext();) {
                Logger logger = Logger.getLogger(this.getClass());
                logger.fatal("SIZE" + chan.getPackageCount());
                chan.removePackage(PackageFactory.lookupByIdAndOrg(itr.next(), 
                        user.getOrg()), user);
            }
            
            ActionMessages msg = new ActionMessages();
            Object[] args = new Object[3];
            args[0] = set.size();
            msg.add(ActionMessages.GLOBAL_MESSAGE, 
                    new ActionMessage("channel.manage.patchset.deleteconfirm", args));
            getStrutsDelegate().saveMessages(request, msg);
            
            
            patchSets = PackageManager.listPatchSetsForChannel(chan.getId());
        }
        
        
        
        request.setAttribute("cid", chan.getId());
        request.setAttribute("pageList", patchSets);
        request.setAttribute("parentUrl", request.getRequestURI());
        ListTagHelper.bindSetDeclTo(LIST_NAME, getDecl(), request);
        
        
        return mapping.findForward("default");
        
    }
    
    private RhnSetDecl getDecl() {
        return RhnSetDecl.PATCHSETS_TO_REMOVE;
        
    }

}
