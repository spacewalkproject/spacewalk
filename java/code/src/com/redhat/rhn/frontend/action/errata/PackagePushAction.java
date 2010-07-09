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
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * PackagePushAction
 * @version $Rev$
 */
public class PackagePushAction extends RhnSetAction {

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.PACKAGES_TO_PUSH;
    }

    /**
     * We push the packages the user has selected into
     * the channel sent by the form. We then push
     * any packages that don't need user confirmation
     * into the channel, remove the channel from
     * the CHANNELS_FOR_ERRATA set and forward
     * the user back to the PackagePushSetupAction
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return The ActionForward to go to next
     */
    public ActionForward pushPackages(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        RhnSet set = updateSet(request);
        DynaActionForm daForm = (DynaActionForm) formIn;
        RequestContext rctx = new RequestContext(request);
        User user = rctx.getLoggedInUser();
        Long eid = (Long) daForm.get("eid");
        Long cid = (Long) daForm.get("cid");
        Errata errata = ErrataManager.lookupErrata(eid, user);


        Channel c = ChannelManager.lookupByIdAndUser(cid, user);


        //Load up all the packages
        Set<Package> filePackages = new HashSet<Package>();
        for (Iterator i = set.getElements().iterator(); i.hasNext();) {
            RhnSetElement element = (RhnSetElement) i.next();
            Package p = PackageManager.lookupByIdAndUser(element.getElement(), user);
            filePackages.add(p);
        }
        //publish them and the errata to the channel
        errata = ErrataFactory.publishToChannel(errata, c, user, filePackages);

        RhnSet targetChannels = RhnSetDecl.CHANNELS_FOR_ERRATA.get(user);
        targetChannels.removeElement(cid);
        RhnSetManager.store(targetChannels);

        set.clear();
        RhnSetManager.store(set);

        if (filePackages.isEmpty()) {
            getStrutsDelegate().saveMessage("errata.publish.packagepush.nopackages_pushed",
                                                new String[] {c.getName()},
                                                          request);
        }
        else {
            getStrutsDelegate().saveMessage("errata.publish.packagepush.packages_pushed",
                                                new String[] {c.getName(),
                                            String.valueOf(filePackages.size())},
                                                        request);
        }

        request.setAttribute("eid", eid);
        return mapping.findForward("defaultWithoutRedirect");
    }

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User user, ActionForm formIn,
            HttpServletRequest request) {
        DynaActionForm daForm = (DynaActionForm) formIn;
        Long cid = (Long) daForm.get("cid");
        Long eid = (Long) daForm.get("eid");
        return PackageManager.possiblePackagesForPushingIntoChannel(cid, eid, null);
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm form, HttpServletRequest request,
            Map params) {
        DynaActionForm daForm = (DynaActionForm) form;
        params.put("eid", daForm.get("eid"));

    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("errata.publish.packagepush.continue", "pushPackages");
    }

}
