/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.systems.monitoring;

import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ProbesListSetupAction
 * @version $Rev: 59372 $
 */
public class ProbesListSetupAction extends RhnAction implements Listable {

    /**
     *
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping actionMapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        Server server = requestContext.lookupAndBindServer();
        request.setAttribute("sid", server.getId());

        ListRhnSetHelper helper =
                new ListRhnSetHelper(this, request, RhnSetDecl.PROBES_TO_DELETE);
        helper.execute();

        if (helper.isDispatched()) {
            Map params = new HashMap();
            params.put("sid", server.getId());
            return getStrutsDelegate().forwardParams(
                    actionMapping.findForward("continue"), params);
        }

        // request.setAttribute("sid", server.getId());
        return actionMapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /**
     *
     * {@inheritDoc}
     */
    public List getResult(RequestContext rctx) {
        Server server = rctx.lookupAndBindServer();
        return MonitoringManager.getInstance().
            probesForSystem(rctx.getCurrentUser(), server, null);
    }
}
