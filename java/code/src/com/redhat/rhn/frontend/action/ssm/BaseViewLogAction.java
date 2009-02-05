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
package com.redhat.rhn.frontend.action.ssm;

import java.util.List;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.ssm.SsmOperationManager;

/**
 * Responsible for populating the request to display a list of SSM operation log
 * entries. The simplest way to use this class is to subclass it and call the setters
 * to indicate what subset of operations to show. 
 * 
 * @author Jason Dobies
 * @version $Revision$
 */
public abstract class BaseViewLogAction extends RhnListAction implements Listable {

    private static final String DATA_SET = "pageList";

    /**
     * Allows the subclass to control the data being returned by the
     * {@link #getResult(RequestContext)} call.
     *
     * @return cannot be <code>null</code>
     */
    protected abstract Mode getMode();

    /**
     * Allows the subclass to introduce a message key specific to the data it provides.
     *
     * @return cannot be <code>null</code>; this value should be a key in the
     *         StringResources bundles.
     */
    protected abstract String getSummaryKey();

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping actionMapping,
                                 ActionForm actionForm,
                                 HttpServletRequest request,
                                 HttpServletResponse response)
        throws Exception {

        ListHelper helper = new ListHelper(this, request);
        helper.setDataSetName(DATA_SET);
        helper.execute();

        request.setAttribute("summaryKey", getSummaryKey());

        return actionMapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /** {@inheritDoc} */
    public List getResult(RequestContext context) {
        User user = context.getLoggedInUser();

        DataResult result;

        if (getMode() == Mode.ALL) {
            result = SsmOperationManager.allOperations(user);
        }
        else {
            result = SsmOperationManager.inProgressOperations(user);
        }

        return result;
    }

    /**
     * Dictates which set of operations is displayed by this action.
     */
    protected enum Mode {
        IN_PROGRESS, ALL
    }
}

