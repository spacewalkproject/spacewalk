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
import com.redhat.rhn.domain.config.ConfigFileName;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.BaseListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.configuration.ConfigurationManager;

/**
 * DiffSystemsAction
 * @version $Rev$
 */
public class DiffSystemsAction extends BaseListAction {

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(RequestContext rctxIn, PageControl pc) {
        User user = rctxIn.getLoggedInUser();
        Long cfnid = rctxIn.getRequiredParam("cfnid");
        
        return ConfigurationManager.getInstance().listSystemsForFileName(user, cfnid, pc);
    }
    
    /**
     * {@inheritDoc}
     */
    protected void processRequestAttributes(RequestContext rctxIn) {
        Long cfnid = rctxIn.getRequiredParam("cfnid");
        ConfigFileName name = ConfigurationFactory.lookupConfigFileNameById(cfnid);
        rctxIn.getRequest().setAttribute("filepath", name.getPath());
    }
    
    protected void processPageControl(PageControl pcIn) {
        pcIn.setFilter(true);
        pcIn.setFilterColumn("name");
    }

}
