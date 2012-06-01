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
package com.redhat.rhn.frontend.action.systems.sdc;

import com.redhat.rhn.domain.org.CustomDataKey;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.server.CustomDataValue;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import org.hibernate.Session;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Handles the deletion of a key.
 */
public class DeleteCustomDataAction extends RhnAction {

    private final String CIKID_PARAM = "cikid";
    private final String LABEL_PARAM = "label";
    private final String DESC_PARAM = "description";
    private final String CREATOR_PARAM = "creator";
    private final String CREATED_PARAM = "created";
    private final String MODIFIED_PARAM = "modified";
    private final String LAST_MODIFIER_PARAM = "lastModifier";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        User user =  requestContext.getLoggedInUser();
        Long cikid = requestContext.getParamAsLong(CIKID_PARAM);

        Long sid = requestContext.getRequiredParam(RequestContext.SID);
        Server server = SystemManager.lookupByIdAndUser(sid, user);
        CustomDataKey key = OrgFactory.lookupKeyById(cikid);
        Map params = new HashMap();
        StrutsDelegate strutsDelegate = getStrutsDelegate();

        params.put(RequestContext.SID, request.getParameter(RequestContext.SID));

        Session session = HibernateFactory.getSession();
        CustomDataValue cdv = (CustomDataValue) session.getNamedQuery(
                "CustomDataValue.findByServerAndKey").setEntity("server", server)
                .setEntity("key", key)
                .setCacheable(true).uniqueResult();

        request.setAttribute(CIKID_PARAM, cikid);
        request.setAttribute(LABEL_PARAM, cdv.getKey().getLabel());
        request.setAttribute(DESC_PARAM, cdv.getValue());
        request.setAttribute(CREATOR_PARAM, cdv.getCreator().getLogin());
        request.setAttribute(CREATED_PARAM, cdv.getCreated());
        if (cdv.getLastModifier() != null) {
            request.setAttribute(LAST_MODIFIER_PARAM, cdv.getLastModifier().getLogin());
        }
        else {
            request.setAttribute(LAST_MODIFIER_PARAM, "");
        }
        request.setAttribute(MODIFIED_PARAM, cdv.getModified());
        request.setAttribute("system", server);

        if (requestContext.isSubmitted()) {
            ServerFactory.removeCustomDataValue(server, key);

            return getStrutsDelegate().forwardParams(mapping.findForward("deleted"),
                    params);
        }

        return getStrutsDelegate().forwardParams(
                mapping.findForward(RhnHelper.DEFAULT_FORWARD), params);
    }

}
