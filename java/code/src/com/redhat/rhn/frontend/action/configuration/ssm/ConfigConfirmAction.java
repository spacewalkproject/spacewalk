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
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.BaseListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.DynaActionForm;

/**
 * DiffConfirmAction
 * @version $Rev$
 */
public class ConfigConfirmAction extends BaseListAction {

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(RequestContext rctxIn, PageControl pcIn) {
        User user = rctxIn.getLoggedInUser();
        String feature  = rctxIn.getRequest().getParameter("feature");
        return ConfigurationManager.getInstance().listSystemsForConfigAction(user, pcIn, 
                                    feature);
    }
    
    protected void processRequestAttributes(RequestContext rctxIn) {
        User user = rctxIn.getLoggedInUser();
        int size = RhnSetDecl.CONFIG_FILE_NAMES.get(user).size();
        rctxIn.getRequest().setAttribute("filenum", new Integer(size));
        super.processRequestAttributes(rctxIn);
    }
    
    protected void processPageControl(PageControl pcIn) {
        pcIn.setFilter(true);
        pcIn.setFilterColumn("name");
    }
    
    /**
     * {@inheritDoc}
     */
    protected void processForm(RequestContext ctxt, ActionForm formIn) {
        if (formIn == null) {
            return; //no date picker on diff page
        }
        
        
        DynaActionForm dynaForm = (DynaActionForm) formIn;
        DatePicker picker = getStrutsDelegate().prepopulateDatePicker(ctxt.getRequest(),
                dynaForm, "date", DatePicker.YEAR_RANGE_POSITIVE);
        ctxt.getRequest().setAttribute("date", picker);
    }
}
