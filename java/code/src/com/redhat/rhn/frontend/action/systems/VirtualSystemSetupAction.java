/**
 * Copyright (c) 2009--2013 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.systems;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.VirtualSystemOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * VirtualSystemsListSetupAction
 * @version $Rev$
 */
public class VirtualSystemSetupAction extends RhnAction
        implements Listable<VirtualSystemOverview> {

    /** {@inheritDoc} */
    @Override
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        ListRhnSetHelper helper =
                new ListRhnSetHelper(this, request, RhnSetDecl.SYSTEMS);
        helper.setDataSetName(RequestContext.PAGE_LIST);
        helper.setListName("virtSystemList");
        helper.execute();

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }


    @Override
    public List<VirtualSystemOverview> getResult(RequestContext context) {
        User user = context.getCurrentUser();

        DataResult<VirtualSystemOverview> dr = SystemManager.virtualSystemsList(user, null);

        for (VirtualSystemOverview current : dr) {
            if (current.isFakeNode()) {
                continue;
            }
            else if (current.getUuid() == null && current.getHostSystemId() != null) {
                current.setSystemId(current.getHostSystemId());
            }
            else {
                current.setSystemId(current.getVirtualSystemId());
            }
            // Filter works on name field
            if (current.getServerName() != null) {
                current.setName(current.getServerName());
            }
        }

        VirtualSystemOverview.processList(dr);

        return dr;
    }

}
