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
package com.redhat.rhn.frontend.action.configuration.sdc;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.systems.sdc.SdcHelper;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.BaseSetListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;


/**
 * FileListSetupAction, for sdc configuration pages
 * @version $Rev$
 */
public class FileListSetupAction extends BaseSetListAction {

    /**
     * {@inheritDoc}
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_FILE_NAMES;
    }

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(RequestContext rctxIn, PageControl pc) {
        User user = rctxIn.getLoggedInUser();
        Server server = rctxIn.lookupAndBindServer();
        return ConfigurationManager.getInstance().listFileNamesForSystem(user, server, pc);
    }

    protected void processPageControl(PageControl pc) {
        pc.setFilter(true);
        pc.setFilterColumn("path");
    }

    protected void processRequestAttributes(RequestContext rctxIn) {
        super.processRequestAttributes(rctxIn);
        rctxIn.lookupAndBindServer();
        User user = rctxIn.getLoggedInUser();
        Server server = rctxIn.lookupAndBindServer();
        SdcHelper.ssmCheck(rctxIn.getRequest(), server.getId(), user);

        if (!rctxIn.isSubmitted()) {
            RhnSet set = getSetDecl().get(rctxIn.getLoggedInUser());
            set.clear();
            RhnSetManager.store(set);
        }
    }

}
