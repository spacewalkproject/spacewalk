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
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.ssm.SsmOperationManager;

import java.util.List;

/**
 * Configures the {@link BaseViewLogAction} and its pages to display all operation
 * log entries for the current user.
 * 
 * @author Jason Dobies
 * @version $Revision$
 */
public class ViewAllLogAction extends BaseViewLogAction {

    /** {@inheritDoc} */
    public List getResult(RequestContext context) {
        User user = context.getLoggedInUser();
        DataResult result = SsmOperationManager.allOperations(user);
        return result;
    }

    /** {@inheritDoc} */
    protected String getSummaryKey() {
        return "ssm.operations.all.summary";
    }
}
