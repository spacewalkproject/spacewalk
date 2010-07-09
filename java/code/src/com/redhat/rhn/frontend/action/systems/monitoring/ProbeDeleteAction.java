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
package com.redhat.rhn.frontend.action.systems.monitoring;

import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.monitoring.MonitoringManager;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.HashMap;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Action for the probe details page. Note that there is no correpsonding
 * SetupAction since there isn't really a good separation between setup
 * and performing the action.
 *
 * @version $Rev: 53910 $
 */
public class ProbeDeleteAction extends BaseProbeAction {

    private static Logger log = Logger.getLogger(ProbeDeleteAction.class);

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest req, HttpServletResponse resp) {
        DynaActionForm form = (DynaActionForm) formIn;

        RequestContext rctx = new RequestContext(req);
        Probe probe = rctx.lookupProbe();
        Server server = rctx.lookupAndBindServer();
        User user = rctx.getCurrentUser();

        // Handle the submit
        boolean submitted = handleSubmit(probe, user, form, req);

        req.setAttribute("probe", probe);

        if (submitted) {
            HashMap params = new HashMap();
            params.put(RequestContext.SID, server.getId());
            log.debug("Deleted probe: " + probe.getId());
            return getStrutsDelegate().forwardParams(mapping.findForward("deleted"),
                    params);
        }
        return mapping.findForward("default");
    }

    // Copy values from the DynaActionForm into the ServerProbe object
    // and store it to the DB.
    private boolean handleSubmit(Probe probe, User user, DynaActionForm form,
            HttpServletRequest req) {

        boolean submitted = isSubmitted(form);
        if (submitted) {
            MonitoringManager.getInstance().deleteProbe(probe, user);
            createSuccessMessage(req, "probeedit.probedeleted",
                    StringEscapeUtils.escapeHtml(probe.getDescription()));
        }
        return submitted;
    }

}
