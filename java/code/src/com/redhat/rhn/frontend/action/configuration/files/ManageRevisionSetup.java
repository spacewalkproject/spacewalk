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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.BaseSetListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

/**
 * ManageRevisionSetup extends RhnAction - Class representation of the table ###TABLE###.
 * @version $Rev: 101893 $
 */
public class ManageRevisionSetup extends BaseSetListAction {
    
    /**
     * {@inheritDoc}
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_REVISIONS;
    }
    
    protected void processRequestAttributes(RequestContext rctxIn) {
        int max = Config.get().getInt(ConfigDefaults.CONFIG_REVISION_MAX_SIZE,
                ConfigDefaults.DEFAULT_CONFIG_REVISION_MAX_SIZE);
        
        rctxIn.getRequest().setAttribute("max_size",
                StringUtil.displayFileSize(max));
        ConfigActionHelper.processRequestAttributes(rctxIn);
        super.processRequestAttributes(rctxIn);
    }
    
    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(RequestContext rctxIn, PageControl pcIn) {
        User user = rctxIn.getLoggedInUser();
        ConfigFile file = ConfigActionHelper.getFile(rctxIn.getRequest());
        ConfigActionHelper.processRequestAttributes(rctxIn);
        return ConfigurationManager.getInstance().listRevisionsForFile(user, file, pcIn);
    }



}
