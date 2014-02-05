/**
 * Copyright (c) 2013 SUSE
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

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.frontend.taglibs.list.helper.ListSessionSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;


/**
 * Reboot Systems in the SSM miscellaneous actions.
 *
 * @author Bo Maryniuk <bo@suse.de>
 */
public class RebootSystemAction
        extends RhnListAction
        implements Listable<SystemOverview> {

    /** {@inheritDoc} */
    @Override
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        ListSessionSetHelper helper = new ListSessionSetHelper(this, request);
        helper.setDataSetName(RequestContext.PAGE_LIST);
        helper.setListName("systemList");
        helper.execute();

        if (helper.isDispatched()) {
            ActionForward forward =
                handleDispatch(helper, mapping, request);
            return forward;
        }
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    private ActionForward handleDispatch(
            ListSessionSetHelper helper,
            ActionMapping mapping,
            HttpServletRequest request) {

        RequestContext context = new RequestContext(request);
        RhnSet set = RhnSetDecl.SSM_SYSTEMS_REBOOT.get(context.getCurrentUser());

        set.clear();
        for (String item : helper.getSet()) {
            set.addElement(item);
        }
        RhnSetManager.store(set);
        return mapping.findForward("confirm");
    }

    /**
     * Get the dataset result.
     *
     * @param context Request context.
     * @return List of SystemOverview objects.
     */
    public List<SystemOverview> getResult(RequestContext context) {
        List<SystemOverview> systems = SystemManager.inSet(context.getCurrentUser(),
                RhnSetDecl.SYSTEMS.getLabel());
        for (SystemOverview systemOverview : systems) {
            systemOverview.setSelectable(1);
        }

        return systems;
    }
}
