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
package com.redhat.rhn.frontend.action.monitoring;

import com.redhat.rhn.domain.monitoring.TemplateProbe;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
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
 * List the probes in a suite
 *
 * @version $Rev$
 */
public class ProbeSuiteListProbesSetupAction extends RhnAction implements Listable {

    /**
     *
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext ctx = new RequestContext(request);
        User user = ctx.getLoggedInUser();

        ProbeSuite suite = ctx.lookupProbeSuite();

        ListRhnSetHelper helper = new ListRhnSetHelper(this, request, getSetDecl());
        helper.execute();

        request.setAttribute("suite_id", suite.getId());

        if (helper.isDispatched()) {
            int updatedCount = 0;
            for (Long element : helper.getSet().getElementValues()) {
                TemplateProbe probe = (TemplateProbe)
                MonitoringManager.getInstance().lookupProbe(user, element);
                if (probe != null) {
                    MonitoringManager.getInstance().deleteProbe(probe, user);
                    updatedCount++;
                }
            }
            helper.destroy();
            MonitoringManager.getInstance().storeProbeSuite(suite, user);

            createSuccessMessage(request, "probes.jsp.probesdeleted",
                    new Integer(updatedCount).toString());
            Map params = new HashMap();
            params.put("suite_id", suite.getId());
            return getStrutsDelegate().forwardParams(mapping.findForward("remove"),
                    params);
        }


        return mapping.findForward("default");

    }

    /**
     * {@inheritDoc}
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.SUITE_PROBES_TO_DELETE;
    }

    /**
     * {@inheritDoc}
     */
    public List getResult(RequestContext context) {
        Long id = context.getRequiredParam(RequestContext.SUITE_ID);
        return MonitoringManager.getInstance().listProbesInSuite(id,
                context.getLoggedInUser(), null);
    }

}
