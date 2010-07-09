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
package com.redhat.rhn.frontend.action.multiorg;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.dto.OrgTrust;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * Abstract POST action class that provides for setup->confirm->commit
 * lifecycle.  This should probably be added as a <i>real</i> class and
 * promoted for general use as I suspect that many other pages using the rhn
 * list tag need to work the same way.
 * @version $Rev$
 */
abstract class FormDispatcher extends RhnAction {

    static final String AFFECTED_SYSTEMS = "affectedSystems";

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
        if (context.hasParam(AFFECTED_SYSTEMS)) {
            return affectedSystemsAction(mapping, form, request, response);
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

    protected abstract ActionForward affectedSystemsAction(
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
        Org theOrg = OrgFactory.lookupById(oid);
        List<OrgTrust> dataSet = getOrgs(theOrg);

        if (!context.isSubmitted()) {
            set.clear();
            for (OrgTrust t : dataSet) {
                if (theOrg.getTrustedOrgs().contains(t.getOrg())) {
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

        request.setAttribute("org", theOrg);
        request.setAttribute(DATA_SET, dataSet);
        request.setAttribute(
            ListTagHelper.PARENT_URL,
            request.getRequestURI() + "?oid=" + oid);

        ListTagHelper.bindSetDeclTo(LIST_NAME, RHNSET, request);
        return mapping.findForward("default");
    }

    private List<OrgTrust> getOrgs(Org theOrg) {
        List<OrgTrust> list = new ArrayList<OrgTrust>();
        for (Org org : OrgFactory.lookupAllOrgs()) {
            if (theOrg != org) {
                list.add(new OrgTrust(org));
            }
        }
        return list;
    }

    private List<Org> getAdded(Org theOrg, RhnSet set) {
        List<Org> list = new ArrayList<Org>();
        Set<Org> myTrusted = theOrg.getTrustedOrgs();
        for (OrgTrust trust : getOrgs(theOrg)) {
            if (set.contains(trust.getId().longValue()) &&
                !myTrusted.contains(trust.getOrg())) {
                list.add(trust.getOrg());
            }
        }
        return list;
    }

    private List<Org> getRemoved(Org theOrg, RhnSet set) {
        List<Org> list = new ArrayList<Org>();
        Set<Org> myTrusted = theOrg.getTrustedOrgs();
        for (OrgTrust trust : getOrgs(theOrg)) {
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
        Org theOrg = OrgFactory.lookupById(oid);
        helper.updateSet(set, LIST_NAME);
        List<OrgTrust> removed = new ArrayList<OrgTrust>();
        for (Org org : getRemoved(theOrg, set)) {
            DataResult<Map> dr =
                SystemManager.subscribedInOrgTrust(theOrg.getId(), org.getId());
            if (dr.size() == 0) {
                continue;
            }
            OrgTrust trust = new OrgTrust(org);
            for (Map m : dr) {
                Long sid = (Long)m.get("id");
                trust.getSubscribed().add(sid);
            }
            removed.add(trust);
        }
        if (removed.size() == 0) {
            return commitAction(mapping, form, request, response);
        }
        request.setAttribute("org", theOrg);
        request.setAttribute("removed", removed);
        request.setAttribute(
                ListTagHelper.PARENT_URL,
                request.getRequestURI() + "?oid=" + oid);
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
        Org theOrg = OrgFactory.lookupById(oid);
        helper.updateSet(set, LIST_NAME);

        for (Org added : getAdded(theOrg, set)) {
            theOrg.addTrust(added);
        }

        User orgUser = UserFactory.findRandomOrgAdmin(theOrg);
        for (Org removed : getRemoved(theOrg, set)) {
            User orgAdmin = UserFactory.findRandomOrgAdmin(removed);
            DataResult<Map> dr =
                SystemManager.subscribedInOrgTrust(theOrg.getId(), removed.getId());

              for (Map item : dr) {
                Long sid = (Long)item.get("id");
                Server s = ServerFactory.lookupById(sid);
                Long cid = (Long)item.get("cid");
                Channel channel = ChannelFactory.lookupById(cid);
                if (channel.getParentChannel() == null) {
                    // unsubscribe children first if subscribed
                    List<Channel> children = channel
                            .getAccessibleChildrenFor(orgUser);
                    Iterator<Channel> i = children.iterator();
                    while (i.hasNext()) {
                        Channel child = (Channel) i.next();
                        if (s.isSubscribed(child)) {
                            // unsubscribe server from child channel
                            child.getTrustedOrgs().remove(theOrg);
                            ChannelFactory.save(child);
                            s = SystemManager.
                            unsubscribeServerFromChannel(s, child);
                        }
                    }
                }
                ChannelFactory.save(channel);
                SystemManager.unsubscribeServerFromChannel(orgUser, sid, cid);
            }
            theOrg.removeTrust(removed);
        }

        OrgFactory.save(theOrg);
        createSuccessMessage(request, "org.trust.updated", theOrg.getName());
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        makeParamMap(request);
        Map params = makeParamMap(request);
        params.put("oid", theOrg.getId());
        ActionForward success = mapping.findForward("success");
        return strutsDelegate.forwardParams(success, params);
    }

    @SuppressWarnings("unchecked")
    protected ActionForward affectedSystemsAction(
            ActionMapping mapping,
            ActionForm form,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        Long userorg =
            Long.valueOf(request.getParameter(RequestContext.ORG_ID));
        Org usrOrg = OrgFactory.lookupById(userorg);
        String[] strings = request.getParameterValues("oid");
        Long[] oid = { Long.valueOf(strings[0]), Long.valueOf(strings[1]) };
        Org orgA = OrgFactory.lookupById(Long.valueOf(oid[0]));
        Org orgB = OrgFactory.lookupById(Long.valueOf(oid[1]));
        request.setAttribute("orgA", orgA);
        request.setAttribute("orgB", orgB);
        DataResult<Map> dr = SystemManager.subscribedInOrgTrust(oid[0], oid[1]);
        List<Map> sysA = new ArrayList<Map>();
        List<Map> sysB = new ArrayList<Map>();
        for (Map m : dr) {
            long orgId = (Long)m.get("org_id");
            if (orgId == oid[0]) {
                sysA.add(m);
            }
            else {
                sysB.add(m);
            }
        }
        request.setAttribute("usrOrg", usrOrg);
        request.setAttribute("sysA", sysA);
        request.setAttribute("sysB", sysB);
        request.setAttribute(
                ListTagHelper.PARENT_URL,
                request.getRequestURI() + "?oid=" + orgA);
        return mapping.findForward("affectedsystems");
    }
}

