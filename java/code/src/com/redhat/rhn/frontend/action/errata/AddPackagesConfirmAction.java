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

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;


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

/**
 * AddPackagesConfirmAction
 * @version $Rev$
 */
public class AddPackagesConfirmAction extends RhnSetAction {

    /**
     * Adds the packages identified in the packages_to_add set to the errata.
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request The request
     * @param response The response
     * @return Returns either a success or failure message
     */
    public ActionForward addPackagesToErrata(ActionMapping mapping,
                                             ActionForm formIn,
                                             HttpServletRequest request,
                                             HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        
        //Get the Logged in user and the errata in question
        User user = requestContext.getLoggedInUser();
        Errata errata = requestContext.lookupErratum();
        
        //Retrieve the set containing the ids of the packages we want to add
        RhnSet packageIdsToAdd = RhnSetDecl.PACKAGES_TO_ADD.get(user);
        
        /*
         * We now need to loop through the set and get the package corresponding to
         * the id stored in ElementOne of the set. If the package exists, add it
         * to the errata.
         */
        Iterator itr = packageIdsToAdd.getElements().iterator();
        int packagesAdded = 0; 
        while (itr.hasNext()) {
            Long pid = ((RhnSetElement) itr.next()).getElement(); //package id
            Package pkg = PackageManager.lookupByIdAndUser(pid, user); //package
            if (pkg != null) {
                //add the package to the errata
                errata.addPackage(pkg);
                //We need to keep track of the number of packages that were successfully
                //added to the errata.
                packagesAdded++;
            }
        }
        //Save the errata
        ErrataManager.storeErrata(errata);

        //Clean up
        RhnSetDecl.PACKAGES_TO_ADD.clear(user);

        //Update Errata Cache
        if (errata.isPublished()) {
            List<Long> list = new ArrayList<Long>();
            for (Channel chan : errata.getChannels()) {
                list.add(chan.getId());
            }
            ErrataCacheManager.insertCacheForChannelErrataAsync(list, errata);
        }
        
        //Set the correct action message and return to the success mapping
        ActionMessages msgs = getMessages(packagesAdded, errata.getAdvisory());
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
    private ActionMessages getMessages(int packagesAdded, String advisory) {
        ActionMessages msgs = new ActionMessages();
        if (packagesAdded < 2) {
            msgs.add(ActionMessages.GLOBAL_MESSAGE, 
                     new ActionMessage("errata.edit.packages.add.success.singular", 
                                       String.valueOf(packagesAdded), advisory));
        }
        else { //plural version
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                     new ActionMessage("errata.edit.packages.add.success.plural",
                                       String.valueOf(packagesAdded), advisory));
        }
        return msgs;
    }
    
    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User user, 
                                       ActionForm formIn, 
                                       HttpServletRequest request) {
        //no-op
        return null;
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("errata.edit.packages.confirm.confirm", "addPackagesToErrata");
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
        return RhnSetDecl.PACKAGES_TO_ADD;
    }

}
