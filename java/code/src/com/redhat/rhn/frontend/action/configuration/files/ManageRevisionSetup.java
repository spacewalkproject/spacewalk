/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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

    public static final String CSRF_TOKEN = "csrfToken";
    public static final String MAX_SIZE = "max_size";

    /**
     * {@inheritDoc}
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_REVISIONS;
    }

    protected void processRequestAttributes(RequestContext rctxIn) {
        rctxIn.getRequest().setAttribute(ManageRevisionSetup.MAX_SIZE,
                 StringUtil.displayFileSize(ConfigFile.getMaxFileSize()));
        rctxIn.getRequest().setAttribute(CSRF_TOKEN,
            rctxIn.getRequest().getSession().getAttribute("csrf_token"));
        ConfigActionHelper.processRequestAttributes(rctxIn);
        super.processRequestAttributes(rctxIn);
    }

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(RequestContext rctxIn, PageControl pcIn) {
        User user = rctxIn.getCurrentUser();
        ConfigFile file = ConfigActionHelper.getFile(rctxIn.getRequest());
        ConfigActionHelper.processRequestAttributes(rctxIn);
        return ConfigurationManager.getInstance().listRevisionsForFile(user, file, pcIn);
    }



}
