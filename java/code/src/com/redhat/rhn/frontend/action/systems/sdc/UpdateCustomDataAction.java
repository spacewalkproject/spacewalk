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

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.org.CustomDataKey;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.server.CustomDataValue;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListSessionSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import org.hibernate.Session;

import java.util.Date;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Handles updating a System's custom value
 */
public class UpdateCustomDataAction extends RhnAction {

    private final String CIKID_PARAM = "cikid";
    private final String LABEL_PARAM = "label";
    private final String VAL_PARAM = "value";
    private final String CREATE_PARAM = "created";
    private final String MODIFY_PARAM = "modified";
    private final String CREATOR_PARAM = "creator";
    private final String MODIFIER_PARAM = "modifier";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext context = new RequestContext(request);
        DynaActionForm form = (DynaActionForm)formIn;

        User loggedInUser = context.getLoggedInUser();
        Long sid = context.getRequiredParam(RequestContext.SID);
        Server server = SystemManager.lookupByIdAndUser(sid, loggedInUser);

        User user =  context.getLoggedInUser();
        Long cikid = context.getParamAsLong(CIKID_PARAM);
        CustomDataKey key = OrgFactory.lookupKeyById(cikid);

        Session session = HibernateFactory.getSession();
        CustomDataValue cdv = (CustomDataValue) session.getNamedQuery(
                "CustomDataValue.findByServerAndKey").setEntity("server", server)
                .setEntity("key", key)
                .setCacheable(true).uniqueResult();

        form.set(LABEL_PARAM, key.getLabel());
        request.setAttribute("system", server);
        request.setAttribute("sid", server.getId());
        request.setAttribute(CIKID_PARAM, cikid);
        request.setAttribute(LABEL_PARAM, key.getLabel());
        request.setAttribute(CREATE_PARAM, cdv.getCreated());
        request.setAttribute(MODIFY_PARAM, cdv.getModified());
        request.setAttribute(CREATOR_PARAM, cdv.getCreator().getLogin());
        User lastModifier = cdv.getLastModifier();
        if (lastModifier != null) {
            request.setAttribute(MODIFIER_PARAM, cdv.getLastModifier().getLogin());
        }
        else {
            request.setAttribute(MODIFIER_PARAM, "");
        }

        if (context.isSubmitted()) {
            server.addCustomDataValue(key.getLabel(), (String)form.get(VAL_PARAM), user);
System.out.println("setting value to " + (String)form.get(VAL_PARAM));
            return mapping.findForward("updated");
        }
        else {
            request.setAttribute(VAL_PARAM, cdv.getValue());
        }

        return mapping.findForward("default");
    }

}
