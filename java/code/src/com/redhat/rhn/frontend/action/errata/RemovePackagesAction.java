/**
 * Copyright (c) 2009--2016 Red Hat, Inc.
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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.errata.cache.ErrataCacheManager;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

/**
 * RemovePackages
 */
public class RemovePackagesAction extends RhnAction implements Listable {

    /**
     * {@inheritDoc}
     */
    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm form,
                    HttpServletRequest request, HttpServletResponse response) {

        RequestContext ctxt = new RequestContext(request);
        //put advisory in request for the toolbar
        request.setAttribute("advisory", ctxt.lookupErratum().getAdvisory());
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());

        ListRhnSetHelper helper = new ListRhnSetHelper(this, request,
                                                       RhnSetDecl.PACKAGES_TO_REMOVE);
        helper.setDataSetName(ListPackagesAction.DATASET_NAME);
        helper.setListName(ListPackagesAction.LIST_NAME);
        helper.setWillClearSet(false);
        helper.execute();

        if (helper.isDispatched()) {
            StrutsDelegate delegate = getStrutsDelegate();
            Errata errata = ctxt.lookupErratum();
            User user = ctxt.getCurrentUser();
            RhnSet idsToRemove = helper.getSet();
            int packagesRemoved = processRemovePackagesFrom(errata, user, idsToRemove);
            doMessages(request, packagesRemoved, errata.getAdvisory());
            helper.destroy();

            Long eid = ctxt.getRequiredParam(ListPackagesAction.EID_PARAM);
            Map<String, Object> params = new HashMap<String, Object>();
            params.put(ListPackagesAction.EID_PARAM, eid);
            return delegate.forwardParams(
                            mapping.findForward(RhnHelper.CONFIRM_FORWARD), params);
        }
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    //
    // Business Logic in the Controller - Fun!
    //
    protected int processRemovePackagesFrom(Errata errata,
                                            User user,
                                            RhnSet packageIdsToRemove) {
        /*
         * We now need to loop through the set and get the corresponding packages.
         * If the package exists, remove it from the erratum.
         */
        List<Long> pids = new ArrayList<Long>();
        for (Long pid : packageIdsToRemove.getElementValues()) {
            Package pkg = PackageManager.lookupByIdAndUser(pid, user); //package
            if (pkg != null) {
                //remove the package from the errata
                errata.removePackage(pkg);
                pids.add(pid);
            }
        }
        // Erratum is fixed, save it
        ErrataManager.storeErrata(errata);

        // Now, Update Errata Cache
        // First we remove all errata cache entries
        if (errata.isPublished()) {
            ErrataCacheManager.deleteCacheEntriesForErrataPackages(errata.getId(), pids);
        }

        // Now since we didn't actually remove the packages, but simply broke the
        // connection between them and an erratum, we need to rebuild Cache entries
        // for the packages that may still be in any channels associated w/the erratum
        // (2016-04-04: Inexplicable magic! but it's the way the code has worked for
        //  at least 6 years...)
        List<Long> cList = new ArrayList<Long>();
        for (Channel chan : errata.getChannels()) {
            cList.add(chan.getId());
        }
        ErrataCacheManager.insertCacheForChannelPackagesAsync(cList, pids);

        return pids.size();
    }

    /**
     * Helper method that gets the correct success action message depending on how
     * many packages were successfully added to the errata.
     * @param req Incoming HttpRequest
     * @param packagesAdded The number of packages added to the errata
     * @param advisory The advisory for the errata (displayed in the message)
     * @return Returns an ActionMessages object containing the correct success message.
     */
    private void doMessages(HttpServletRequest req, int packagesRemoved, String advisory) {
        String[] params = {String.valueOf(packagesRemoved), advisory};
        if (packagesRemoved < 2) {
            createMessage(req, "errata.edit.packages.remove.success.singular", params);
        }
        else { //plural version
            createMessage(req, "errata.edit.packages.remove.success.plural", params);
        }
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public List getResult(RequestContext context) {
        return PackageManager.packageIdsInSet(context.getCurrentUser(),
                                              RhnSetDecl.PACKAGES_TO_REMOVE.getLabel());
    }

}
