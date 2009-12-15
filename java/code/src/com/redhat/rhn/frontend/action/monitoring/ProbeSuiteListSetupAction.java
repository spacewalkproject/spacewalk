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
package com.redhat.rhn.frontend.action.monitoring;

import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ProbeSuiteListSetupAction
 * @version $Rev: 55183 $
 */
public class ProbeSuiteListSetupAction extends RhnAction implements Listable {
    
    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        ListRhnSetHelper helper = new ListRhnSetHelper(this, request, getSetDecl());
        helper.execute();
        if (helper.isDispatched()) {
            if (helper.getSet().size() == 0) {
                getStrutsDelegate().saveMessage("probesuites.jsp.selectasuite", request);
                return  mapping.findForward("default");
            }
            return  mapping.findForward("remove");
        }

        return mapping.findForward("default");

    }


    /**
     * {@inheritDoc}
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.PROBE_SUITES_TO_DELETE;
    }

    /**
     *
     * {@inheritDoc}
     */
    public List getResult(RequestContext context) {
        return MonitoringManager.getInstance().listProbeSuites(
                context.getLoggedInUser(), null);
    }
}
