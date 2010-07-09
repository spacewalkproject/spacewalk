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
package com.redhat.rhn.frontend.action.systems;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.DynaActionForm;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;

/**
 * SystemSearchAction
 * @version $Rev$
 */
public class SystemSearchAction extends RhnSetAction {

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.SYSTEMS;
    }

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User user, ActionForm formIn,
            HttpServletRequest request) {
        DynaActionForm daForm = (DynaActionForm) formIn;
        String searchString = (String) daForm.get(SystemSearchSetupAction.SEARCH_STRING);
        String viewMode = (String) daForm.get(SystemSearchSetupAction.VIEW_MODE);
        Boolean invertResults = (Boolean) daForm
                                          .get(SystemSearchSetupAction.INVERT_RESULTS);
        String whereToSearch = daForm.getString(SystemSearchSetupAction.WHERE_TO_SEARCH);
        return SystemManager.systemSearch(user,
                                          searchString,
                                          viewMode,
                                          invertResults,
                                          whereToSearch,
                                          null);
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm form, HttpServletRequest request,
            Map params) {
        DynaActionForm daForm = (DynaActionForm) form;
        params.put(RhnAction.SUBMITTED, daForm.get(RhnAction.SUBMITTED));
        params.put(SystemSearchSetupAction.SEARCH_STRING,
                   daForm.get(SystemSearchSetupAction.SEARCH_STRING));
        params.put(SystemSearchSetupAction.INVERT_RESULTS,
                   daForm.get(SystemSearchSetupAction.INVERT_RESULTS));
        params.put(SystemSearchSetupAction.WHERE_TO_SEARCH,
                   daForm.get(SystemSearchSetupAction.WHERE_TO_SEARCH));
        params.put(SystemSearchSetupAction.VIEW_MODE,
                   daForm.get(SystemSearchSetupAction.VIEW_MODE));
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
         //no-op
    }

}
