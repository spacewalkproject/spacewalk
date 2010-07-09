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
package com.redhat.rhn.frontend.action.ssm;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.OperationDetailsDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.ssm.SsmOperationManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Loads the data for a particular SSM operation (identified by its ID in
 * a request parameter).
 *
 * @author Jason Dobies
 * @version $Revision$
 */
public class ViewLogDetailsAction extends RhnListAction implements Listable {

    private static final String DATA_SET = "pageList";
    private static final String PARAM_OPERATION_ID = "oid";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping actionMapping,
                                 ActionForm actionForm,
                                 HttpServletRequest request,
                                 HttpServletResponse response)
        throws Exception {

        // Load the operation details for display
        long oid = Long.parseLong(request.getParameter(PARAM_OPERATION_ID));
        RequestContext context = new RequestContext(request);
        User user = context.getLoggedInUser();

        OperationDetailsDto operationData = SsmOperationManager.
                                                findOperationById(user, oid);
        request.setAttribute("operationData", operationData);

        // List stuff for the server list
        ListHelper helper = new ListHelper(this, request);
        helper.setDataSetName(DATA_SET);

        Map<String, String> helperParams = new HashMap<String, String>(1);
        helperParams.put("oid", request.getParameter("oid"));
        helper.setParamMap(helperParams);
        helper.execute();

        return actionMapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /** {@inheritDoc} */
    public List getResult(RequestContext context) {
        HttpServletRequest request = context.getRequest();
        long oid = Long.parseLong(request.getParameter(PARAM_OPERATION_ID));

        DataResult result = SsmOperationManager.findServerDataForOperation(oid);

        return result;
    }
}
