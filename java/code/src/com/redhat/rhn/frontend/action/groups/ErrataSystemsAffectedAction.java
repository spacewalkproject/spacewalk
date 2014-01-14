/**
 * Copyright (c) 2014 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.groups;

import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.taglibs.list.helper.ListSessionSetHelper;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * List Errata for server group
 */
public final class ErrataSystemsAffectedAction extends BaseListAction {

    @Override
    protected void setup(HttpServletRequest request) {
        super.setup(request);
        request.setAttribute("erratum", new RequestContext(request).lookupErratum());
    }

    @Override
    protected Map<String, Long> getParamsMap(HttpServletRequest request) {
        RequestContext context = new RequestContext(request);
        ManagedServerGroup serverGroup = context.lookupAndBindServerGroup();
        Errata erratum = context.lookupErratum();

        Map<String, Long> params = new HashMap<String, Long>();
        params.put(RequestContext.SERVER_GROUP_ID, serverGroup.getId());
        params.put(RequestContext.ERRATA_ID, erratum.getId());
        return params;
    }

    @Override
    protected ActionForward handleDispatch(
            ListSessionSetHelper helper,
            ActionMapping mapping,
            ActionForm formIn, HttpServletRequest request,
            HttpServletResponse response) {

        RhnSet set = RhnSetDecl.SYSTEMS_AFFECTED.get(
            new RequestContext(request).getCurrentUser());

        set.clear();
        for (String item : helper.getSet()) {
           set.addElement(item);
        }
        RhnSetManager.store(set);

        return getStrutsDelegate().forwardParams(mapping.findForward("confirm"),
            request.getParameterMap());
    }

    /** {@inheritDoc} */
    public List getResult(RequestContext context) {
        ManagedServerGroup group = context.lookupAndBindServerGroup();
        Errata erratum = context.lookupErratum();
        User user = context.getCurrentUser();
        return ErrataManager.systemsAffected(user, group, erratum, null);
    }
}
