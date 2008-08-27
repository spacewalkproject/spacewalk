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
package com.redhat.rhn.frontend.action.multiorg;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.OrgTrust;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

/**
 * Abstract POST action class that provides for setup->confirm->commit
 * lifecycle.  This should probably be added as a <i>real</i> class and
 * promoted for general use as I suspect that many other pages using the rhn
 * list tag need to work the same way.
 * @version $Rev$
 */
abstract class FormDispatcher extends RhnAction {
    
    /**
     * ${@inheritDoc}
     */
    public ActionForward execute(
            ActionMapping mapping, 
            ActionForm form,
            HttpServletRequest request, 
            HttpServletResponse response) throws Exception {
        
        RequestContext context = new RequestContext(request);
        
        if (context.hasParam(RequestContext.DISPATCH)) {
            return commitAction(mapping, form, request, response);
        }
        if (context.hasParam(RequestContext.CONFIRM)) {
            return confirmAction(mapping, form, request, response);
        }
        return setupAction(mapping, form, request, response);
    }
    
    protected abstract ActionForward setupAction(
            ActionMapping mapping, 
            ActionForm form,
            HttpServletRequest request, 
            HttpServletResponse response) throws Exception;
    
    protected abstract ActionForward confirmAction(
            ActionMapping mapping, 
            ActionForm form,
            HttpServletRequest request, 
            HttpServletResponse response) throws Exception;
    
    protected abstract ActionForward commitAction(
            ActionMapping mapping, 
            ActionForm form,
            HttpServletRequest request, 
            HttpServletResponse response) throws Exception;
}

/**
 * UserListSetupAction
 * @version $Rev: 101893 $
 */
public class TrustAction extends FormDispatcher {

    private static final String LIST_NAME = "trustedOrgs";
    private static final String DATA_SET = "pageList";
    private static final RhnSetDecl RHNSET = RhnSetDecl.MULTIORG_TRUST_LIST;

    /**
     * ${@inheritDoc}
     */
    protected ActionForward setupAction(
        ActionMapping mapping, 
        ActionForm form,
        HttpServletRequest request, 
        HttpServletResponse response) throws Exception {
        
        RequestContext context = new RequestContext(request);
        RhnListSetHelper helper = new RhnListSetHelper(request);
        User user = context.getLoggedInUser();
        RhnSet set = RHNSET.get(user);
        Long oid = context.getParamAsLong(RequestContext.ORG_ID);
        Org myOrg = OrgFactory.lookupById(oid);
        List<OrgTrust> dataSet = getOrgs(myOrg);

        if (!context.isSubmitted()) {
            set.clear();
            for (OrgTrust t : dataSet) {
                if (myOrg.getTrustedOrgs().contains(t.getOrg())) {
                    set.addElement(t.getId());
                }
            }
            RhnSetManager.store(set);
        }

        if (ListTagHelper.getListAction(LIST_NAME, request) != null) {
            helper.execute(set, LIST_NAME, dataSet);
        }
        if (!set.isEmpty()) {
            helper.syncSelections(set, dataSet);
            ListTagHelper.setSelectedAmount(LIST_NAME, set.size(), request);
        }

        request.setAttribute("org", myOrg);
        request.setAttribute(DATA_SET, dataSet);
        request.setAttribute(
            ListTagHelper.PARENT_URL, 
            request.getRequestURI() + "?oid=+" + oid);

        ListTagHelper.bindSetDeclTo(LIST_NAME, RHNSET, request);
        return mapping.findForward("default");
    }

    private List<OrgTrust> getOrgs(Org myOrg) {
        List<OrgTrust> list = new ArrayList<OrgTrust>();
        for (Org org : OrgFactory.lookupAllOrgs()) {
            if (myOrg != org) {
                list.add(new OrgTrust(org));
            }
        }
        return list;
    }

    private List<Org> getAdded(Org myOrg, RhnSet set) {
        List<Org> list = new ArrayList<Org>();
        Set<Org> myTrusted = myOrg.getTrustedOrgs();
        for (OrgTrust trust : getOrgs(myOrg)) {
            if (set.contains(trust.getId().longValue()) && 
                !myTrusted.contains(trust.getOrg())) {
                list.add(trust.getOrg());
            }
        }
        return list;
    }

    private List<Org> getRemoved(Org myOrg, RhnSet set) {
        List<Org> list = new ArrayList<Org>();
        Set<Org> myTrusted = myOrg.getTrustedOrgs();
        for (OrgTrust trust : getOrgs(myOrg)) {
            if (myTrusted.contains(trust.getOrg()) &&
                 !set.contains(trust.getId().longValue())) {
                    list.add(trust.getOrg());
            }
        }
        return list;
    }
    
    @SuppressWarnings("unchecked")
    protected ActionForward confirmAction(
            ActionMapping mapping, 
            ActionForm form,
            HttpServletRequest request, 
            HttpServletResponse response) throws Exception {
        
        RequestContext context = new RequestContext(request);
        RhnListSetHelper helper = new RhnListSetHelper(request);
        User user = context.getLoggedInUser();
        RhnSet set = RHNSET.get(user);
        Long oid = context.getParamAsLong(RequestContext.ORG_ID);
        Org myOrg = OrgFactory.lookupById(oid);
        helper.updateSet(set, LIST_NAME);
        request.setAttribute("added", getAdded(myOrg, set));
        request.setAttribute("removed", getRemoved(myOrg, set));
        request.setAttribute(
                ListTagHelper.PARENT_URL, 
                request.getRequestURI() + "?oid=+" + oid);
        return mapping.findForward("confirm");
    }
    
    @SuppressWarnings("unchecked")
    protected ActionForward commitAction(
            ActionMapping mapping, 
            ActionForm form,
            HttpServletRequest request, 
            HttpServletResponse response) throws Exception {
        
        RequestContext context = new RequestContext(request);
        RhnListSetHelper helper = new RhnListSetHelper(request);
        User user = context.getLoggedInUser();
        RhnSet set = RHNSET.get(user);
        Long oid = context.getParamAsLong(RequestContext.ORG_ID);
        Org myOrg = OrgFactory.lookupById(oid);
        helper.updateSet(set, LIST_NAME);
        
        for (Org added : getAdded(myOrg, set)) {
            myOrg.addTrust(added);
        }
        for (Org removed : getRemoved(myOrg, set)) {
            myOrg.removeTrust(removed);
        }
        OrgFactory.save(myOrg);

        StrutsDelegate strutsDelegate = getStrutsDelegate();
        makeParamMap(request);
        Map params = makeParamMap(request);
        params.put("oid", myOrg.getId());
        ActionForward success = mapping.findForward("success");
        return strutsDelegate.forwardParams(success, params);
    }
}

