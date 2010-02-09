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
package com.redhat.rhn.frontend.action.configuration.files;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.BaseListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.configuration.ConfigurationManager;

import javax.servlet.http.HttpServletRequest;

/**
 * CompareRevisionAction extends RhnAction - Class representation of the table ###TABLE###.
 * @version $Rev$
 */
public class CompareRevisionAction extends BaseListAction {
    
    protected void processRequestAttributes(RequestContext rctxIn) {
        ConfigActionHelper.processRequestAttributes(rctxIn);
    }

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(RequestContext rctxIn, PageControl pcIn) {
        HttpServletRequest request = rctxIn.getRequest();
        User user = rctxIn.getLoggedInUser();
        
        ConfigFile file = ConfigActionHelper.getFile(request);
        ConfigRevision revision = ConfigActionHelper.getRevision(request, file);
        
        ConfigurationManager cm = ConfigurationManager.getInstance();
        return cm.listRevisionsForCompare(user, file, revision, pcIn);
    }
    
}
