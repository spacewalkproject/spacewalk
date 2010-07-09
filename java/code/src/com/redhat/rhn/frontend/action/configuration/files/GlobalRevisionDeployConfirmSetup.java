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
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.BaseListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.DynaActionForm;

/**
 * GlobalRevisionDeploySetup
 * @version $Rev$
 */
public class GlobalRevisionDeployConfirmSetup extends BaseListAction {

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(RequestContext ctx, PageControl pc) {
        User usr = ctx.getLoggedInUser();
        ConfigFile cf = ConfigActionHelper.getFile(ctx.getRequest());
        ConfigChannel cc = cf.getConfigChannel();
        DataResult dr = ConfigurationManager.getInstance().
            listGlobalFileDeployInfo(usr, cc, cf, pc,
                    RhnSetDecl.CONFIG_FILE_DEPLOY_SYSTEMS.getLabel());
        return dr;
    }

    /**
     * {@inheritDoc}
     */
    protected void processRequestAttributes(RequestContext rctxIn) {
        ConfigActionHelper.processRequestAttributes(rctxIn);
        super.processRequestAttributes(rctxIn);
    }

    /**
     * {@inheritDoc}
     */
    protected void processForm(RequestContext ctxt, ActionForm formIn) {
        super.processForm(ctxt, formIn);
        DynaActionForm dynaForm = (DynaActionForm) formIn;
        DatePicker picker = getStrutsDelegate().prepopulateDatePicker(ctxt.getRequest(),
                dynaForm, "date", DatePicker.YEAR_RANGE_POSITIVE);
        ctxt.getRequest().setAttribute("date", picker);
    }
}
