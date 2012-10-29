/**
 * Copyright (c) 2012 Red Hat, Inc.
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

/**
 * Copyright (c) 2012 Novell
 */

package com.redhat.rhn.frontend.action.systems;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.manager.system.SystemManager;


/**
 * ExtraPackagesSystemsAction
 */
public class ExtraPackagesSystemsAction extends BaseSystemsAction {
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
        HttpServletRequest request, HttpServletResponse response) {
        request.setAttribute("extraPackagesMode", Boolean.TRUE);
        return super.execute(mapping, formIn, request, response);
    }

    protected DataResult<SystemOverview> getDataResult(User user, PageControl pc,
        ActionForm formIn) {
        return SystemManager.getExtraPackagesSystems(user, pc);
    }
}
