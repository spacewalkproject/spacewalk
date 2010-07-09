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
package com.redhat.rhn.frontend.action.systems.provisioning;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnSetHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * PreservationListDeleteSingleAction
 * @version $Rev$
 */
public class PreservationListDeleteSingleAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        RhnSetHelper helper = new RhnSetHelper(mapping,  RhnSetDecl.FILE_LISTS, request);

        RequestContext ctx = new RequestContext(request);
        Map params = ctx.makeParamMapWithPagination();
        params.put("dispatch", LocalizationService.getInstance().
                getMessage("preservation_list.jsp.deletelist"));
        params.put("items_selected",
                ctx.getRequiredParam(RequestContext.FILE_LIST_ID).toString());
        return helper.unselectall(params);
    }
}
