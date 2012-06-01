/**
 * Copyright (c) 2010 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.ssm;

import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.org.MigrationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * MigrateSystemsAction
 * @version $Rev$
 */
public class MigrateSystemsAction extends RhnAction implements Listable {
    /**
     *
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        RequestContext context = new RequestContext(request);

        RequestContext rctx = new RequestContext(request);
        User user = rctx.getLoggedInUser();

        if (context.wasDispatched("ssm.migrate.systems.confirmbutton")) {
            RhnSet set = RhnSetDecl.SYSTEMS.get(context.getLoggedInUser());
            List<Server> serverList = new ArrayList<Server>();

            Iterator it = set.iterator();
            while (it.hasNext()) {
                Long sid = ((RhnSetElement)it.next()).getElement();
                Server server = SystemManager.lookupByIdAndUser(sid, user);
                serverList.add(server);
            }

            DynaActionForm daForm = (DynaActionForm)formIn;

            if (daForm.getString("org").equals("")) {
                getStrutsDelegate().saveMessage("ssm.migrate.systems.orgnone",
                                                            context.getRequest());
            }
            else {
                Org toOrg = OrgFactory.lookupByName(daForm.getString("org"));
                MigrationManager.migrateServers(user, toOrg, serverList);

                // Empty the set as we no longer have access to these systems
                RhnSetDecl.SYSTEMS.clear(user);

                getStrutsDelegate().saveMessage("ssm.migrate.systems.confirmmessage",
                                                            context.getRequest());
            }
            return mapping.findForward("confirm");
        }

        request.setAttribute("trustedOrgs", user.getOrg().getTrustedOrgs().size());
        request.setAttribute("orgs", user.getOrg().getTrustedOrgs());
        ListHelper helper = new ListHelper(this, request);
        helper.setListName("systemList");
        helper.setDataSetName("pageList");
        helper.execute();

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /**
     * {@inheritDoc}
     */
    public List getResult(RequestContext contextIn) {
        return SystemManager.inSet(contextIn.getLoggedInUser(),
                                        RhnSetDecl.SYSTEMS.getLabel());
    }

}
