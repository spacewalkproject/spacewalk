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
package com.redhat.rhn.frontend.action.multiorg;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.channel.BaseChannelTreeAction;
import com.redhat.rhn.frontend.listview.ListControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.channel.ChannelManager;

import javax.servlet.http.HttpServletRequest;

/**
 * AllChannelTreeSetupAction
 * @version $Rev$
 */
public class ChannelProvideAction extends BaseChannelTreeAction {

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(RequestContext requestContext, ListControl lc) {

        Long oid = requestContext.getParamAsLong(RequestContext.ORG_ID);
        //grab the trusted org id passed in
        Org provideOrg = OrgFactory.lookupById(oid);
        User user = requestContext.getCurrentUser();
        Org org = requestContext.getCurrentUser().getOrg();

        /* reverse thinking here, the providing org becomes the supply org for query
           and the current logged in org becomes the leecher since its receiving
        */
        return ChannelManager.trustChannelConsume(provideOrg, org, user, lc);
    }

    /**
     * adds attributes to the request
     * @param requestContext the Request Context
     */
    protected void addAttributes(RequestContext requestContext) {
        Long oid = requestContext.getParamAsLong(RequestContext.ORG_ID);
        //grab the trusted org id passed in
        Org trustOrg = OrgFactory.lookupById(oid);
        HttpServletRequest request = requestContext.getRequest();
        request.setAttribute("trustorg", trustOrg.getName());
    }

}
