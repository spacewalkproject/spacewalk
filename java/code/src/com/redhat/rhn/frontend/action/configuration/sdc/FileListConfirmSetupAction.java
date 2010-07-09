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
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.BaseListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnSetHelper;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.DynaActionForm;

import java.util.List;


/**
 * FileListConfirmSetupAction, for sdc configuration
 * @version $Rev$
 */
public class FileListConfirmSetupAction extends BaseListAction {
    public static final String SELECT_ALL = "selectall";
    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(RequestContext rctxIn, PageControl pcIn) {
        User user = rctxIn.getLoggedInUser();
        Server server = rctxIn.lookupAndBindServer();
        // if a var called selectall=true is bound, then do a select all
        String selectAll = rctxIn.getParam(SELECT_ALL, false);
        if (Boolean.TRUE.toString().equalsIgnoreCase(selectAll)) {
            selectAll(user, server);
        }

        return ConfigurationManager.getInstance().listFileNamesInSet(user, server,
                getSetDecl().getLabel(), pcIn);
    }

    protected void processRequestAttributes(RequestContext rctxIn) {
        rctxIn.lookupAndBindServer();
    }

    protected void processForm(RequestContext ctxt, ActionForm form) {
        DatePicker picker = getStrutsDelegate().prepopulateDatePicker(ctxt.getRequest(),
                (DynaActionForm) form, "date", DatePicker.YEAR_RANGE_POSITIVE);
        ctxt.getRequest().setAttribute("date", picker);
    }


    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_FILE_NAMES;
    }

    /**
     *
     * @param user the logged in user
     * @param server containing the filenames
     */
    private void selectAll(User user, Server server) {
        RhnSetHelper helper = new RhnSetHelper(getSetDecl());

        List list =  ConfigurationManager.getInstance()
                            .listFileNamesForSystem(user, server, null);
        helper.selectAllData(list, user);
    }
}
