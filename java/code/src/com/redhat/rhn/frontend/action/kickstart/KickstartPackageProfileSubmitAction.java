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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.rhnpackage.profile.Profile;
import com.redhat.rhn.domain.rhnpackage.profile.ProfileFactory;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.kickstart.KickstartPackageProfileCommand;
import com.redhat.rhn.manager.profile.ProfileManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * KickstartPackageProfileSubmitAction
 * @version $Rev$
 */
public class KickstartPackageProfileSubmitAction extends
        BaseKickstartListSubmitAction {

    public static final String UPDATE_METHOD = "kickstart.packageprofile.jsp.submit";
    public static final String CLEAR_METHOD = "kickstart.packageprofile.jsp.clear";
    
    /**
     * {@inheritDoc}
     */
    protected void operateOnRemovedElements(List elements,
            HttpServletRequest request) {
        
        if (elements.size() > 0) {
            RequestContext rctx = new RequestContext(request);
            KickstartPackageProfileCommand cmd = new 
                KickstartPackageProfileCommand(
                        rctx.getRequiredParam(RequestContext.KICKSTART_ID),
                        rctx.getCurrentUser());
            cmd.setProfile(null);
            cmd.store();
        }
    }

    /**
     * {@inheritDoc}
     */
    protected void operateOnAddedElements(List elements,
            HttpServletRequest request) {
        
        RequestContext rctx = new RequestContext(request);
        KickstartPackageProfileCommand cmd = new 
            KickstartPackageProfileCommand(
                    rctx.getRequiredParam(RequestContext.KICKSTART_ID),
                    rctx.getCurrentUser());
        Long pid = null;
        if (elements.size() > 0) {
            pid = ((RhnSetElement) elements.get(0)).getElement();
            Profile p = ProfileFactory.lookupByIdAndOrg(pid, 
                    rctx.getCurrentUser().getOrg());
            cmd.setProfile(p);
            cmd.store();
        }
            
    }

    /**
     * {@inheritDoc}
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.PACKAGE_PROFILES;
    }

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User user, 
                                       ActionForm formIn, 
                                       HttpServletRequest request) {
        
        RequestContext rctx = new RequestContext(request);
        KickstartData ksdata = KickstartFactory
            .lookupKickstartDataByIdAndOrg(rctx.getCurrentUser().getOrg(),
                    rctx.getRequiredParam(RequestContext.KICKSTART_ID));
    
        DataResult dr = ProfileManager.compatibleWithChannel(
                ksdata.getKickstartDefaults().getKstree().getChannel(),
                rctx.getCurrentUser().getOrg(), null);
        return dr;
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put(UPDATE_METHOD, "operateOnDiff");
        map.put(CLEAR_METHOD, "clearSelection");
    }

    protected Iterator getCurrentItemsIterator(RequestContext ctx) {
        KickstartData ksdata = KickstartFactory
            .lookupKickstartDataByIdAndOrg(ctx.getCurrentUser().getOrg(),
                    ctx.getRequiredParam(RequestContext.KICKSTART_ID));
        
        List l = new LinkedList();
        if (ksdata.getKickstartDefaults().getProfile() != null) {
            l.add(ksdata.getKickstartDefaults().getProfile());
        }
        return l.iterator();
        
    }
    
    /**
     * This is executed if the clear button is pushed. Clears all associated package 
     *      profiles from from the selected kickstart
     * 
     * @param mapping The ActionMapping used to select this instance
     * @param formIn The optional ActionForm bean for this request (if any)
     * @param request The HTTP request we are processing
     * @param response The HTTP response we are creating
     * @return Describes where and how control should be forwarded.
     */
    public ActionForward clearSelection(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        
        RequestContext rctx = new RequestContext(request);
        KickstartPackageProfileCommand cmd = new 
            KickstartPackageProfileCommand(
                    rctx.getRequiredParam(RequestContext.KICKSTART_ID),
                    rctx.getCurrentUser());
        cmd.setProfile(null);
        cmd.store();
        
        ArrayList added = new ArrayList();
        ArrayList removed = new ArrayList();

        RhnSet currentSet = updateSet(request);
        for (Iterator it = currentSet.getElements().iterator(); it.hasNext();) {
            removed.add(it.next());
        }
        currentSet.clear();
        RhnSetManager.store(currentSet);
        
        generateUserMessage(added, removed, request);
        Map params = makeParamMap(formIn, request);
        return getStrutsDelegate().forwardParams(mapping.findForward("default"), params);
    }

}
