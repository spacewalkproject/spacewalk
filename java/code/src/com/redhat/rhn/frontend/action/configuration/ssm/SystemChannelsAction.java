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
package com.redhat.rhn.frontend.action.configuration.ssm;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.BaseListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.configuration.ConfigurationManager;

/**
 * SystemChannelsAction
 * @version $Rev$
 */
public class SystemChannelsAction extends BaseListAction {

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(RequestContext rctxIn, PageControl pc) {
        User user = rctxIn.getLoggedInUser();
        ConfigurationManager cm = ConfigurationManager.getInstance();

        Server server = rctxIn.lookupServer();
        DataResult dr = cm.listConfigChannelsForSystem(user, server, pc);
        return dr;
    }

    /**
     * {@inheritDoc}
     */
    protected void processRequestAttributes(RequestContext rctxIn) {
        rctxIn.lookupAndBindServer();
    }

    protected void processPageControl(PageControl pcIn) {
        pcIn.setFilter(true);
        pcIn.setFilterColumn("name");
    }

}
