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
package com.redhat.rhn.frontend.action.errata;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.errata.cache.ErrataCacheManager;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * RemovePackages
 * @version $Rev$
 */
public class RemovePackagesAction extends RhnSetAction {

    /**
     * Remove packages corresponding to the ids in the packages_to_remove set from the 
     * errata.
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request The request
     * @param response The response
     * @return Returns a success ActionForward if packages were removed.
     */
    public ActionForward removePackagesFromErrata(ActionMapping mapping,
                                                  ActionForm formIn,
                                                  HttpServletRequest request,
                                                  HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        
        //Get the Logged in user and the errata in question
        User user = requestContext.getLoggedInUser();
        Errata errata = requestContext.lookupErratum();
        
        //Retrieve the set containing the ids of the packages we want to remove
        RhnSet packageIdsToRemove = RhnSetDecl.PACKAGES_TO_REMOVE.get(user);
        
        /*
         * We now need to loop through the set and get the package corresponding to
         * the id stored in ElementOne of the set. If the package exists, remove it
         * to the errata.
         */
        Iterator itr = packageIdsToRemove.getElements().iterator();
        int packagesRemoved = 0; 
        while (itr.hasNext()) {
            Long pid = ((RhnSetElement) itr.next()).getElement(); //package id
            Package pkg = PackageManager.lookupByIdAndUser(pid, user); //package
            if (pkg != null) {
                //remove the package from the errata
                errata.removePackage(pkg);
                //We need to keep track of the number of packages that were successfully
                //removed from the errata.
                packagesRemoved++;
            }
        }
        //Save the errata
        ErrataManager.storeErrata(errata);
        
        
        //Update Errata Cache
        //First we remove all errata cache entries
        if (errata.isPublished()) {
            List pList = new ArrayList();
            pList.addAll(packageIdsToRemove.getElementValues());
            ErrataCacheManager.deleteCacheEntriesForErrataPackages(errata.getId(), pList);
        }
        
        //Now since we didn't actually remove the packages, we need to 
        //      re-insert entries for the packages that are still in teh channel
        //      in case they aren't there
        List<Long> cList = new ArrayList<Long>();
        for (Channel chan : errata.getChannels()) {
            cList.add(chan.getId());
        }
        List<Long> pList = new ArrayList<Long>();
        pList.addAll(RhnSetDecl.PACKAGES_TO_REMOVE.get(user).getElementValues());
        ErrataCacheManager.insertCacheForChannelPackagesAsync(cList, pList);
        
        
        
        //Clean up
        RhnSetDecl.PACKAGES_TO_REMOVE.clear(user);
        

        
        //Set the correct action message and return to the success mapping
        ActionMessages msgs = getMessages(packagesRemoved, errata.getAdvisory());
        strutsDelegate.saveMessages(request, msgs);
        return strutsDelegate.forwardParam(mapping.findForward("success"), 
                                      "eid", errata.getId().toString());
    }
    
    /**
     * Helper method that gets the correct success action message depending on how
     * many packages were successfully added to the errata.
     * @param packagesAdded The number of packages added to the errata
     * @param advisory The advisory for the errata (displayed in the message)
     * @return Returns an ActionMessages object containing the correct success message.
     */
    private ActionMessages getMessages(int packagesRemoved, String advisory) {
        ActionMessages msgs = new ActionMessages();
        if (packagesRemoved < 2) {
            msgs.add(ActionMessages.GLOBAL_MESSAGE, 
                     new ActionMessage("errata.edit.packages.remove.success.singular", 
                                       String.valueOf(packagesRemoved), advisory));
        }
        else { //plural version
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                     new ActionMessage("errata.edit.packages.remove.success.plural",
                                       String.valueOf(packagesRemoved), advisory));
        }
        return msgs;
    }
    
    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User user, 
                                       ActionForm formIn, 
                                       HttpServletRequest request) {
        return null;
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("errata.edit.packages.confirm.confirm", "removePackagesFromErrata");
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm formIn, 
                                   HttpServletRequest request, 
                                   Map params) {
        params.put("eid", request.getParameter("eid"));
    }

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.PACKAGES_TO_REMOVE;
    }

}
