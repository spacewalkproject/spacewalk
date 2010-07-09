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
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BaseSetOperateOnSelectedItemsAction;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * GlobalRevisionDeploySubmit
 * @version $Rev$
 */
public class GlobalRevisionDeploySubmit extends BaseSetOperateOnSelectedItemsAction {

    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_FILE_DEPLOY_SYSTEMS;
    }

    protected DataResult getDataResult(User user, ActionForm formIn,
            HttpServletRequest request) {
        RequestContext ctx = new RequestContext(request);
        User usr = ctx.getLoggedInUser();
        ConfigFile cf = ConfigActionHelper.getFile(ctx.getRequest());
        ConfigChannel cc = cf.getConfigChannel();
        DataResult dr = ConfigurationManager.getInstance().
            listGlobalFileDeployInfo(usr, cc, cf, null);
        return dr;
    }

    protected void processParamMap(
            ActionForm form, HttpServletRequest request, Map params) {
        ConfigActionHelper.processParamMap(request, params);
    }

    protected void processMethodKeys(Map map) {
        map.put("deploy.jsp.deploybutton", "navToConfirm");
    }

    /**
     * The only thing we do for this page, is to navigate forward to the confirm page
     * @param mapping Struts mapping
     * @param formIn Form bean (isSubmitted)
     * @param request incoming request
     * @param response outgoing response
     * @return page to continue to
     */
    public ActionForward navToConfirm(
            ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        updateSet(request);
        Map params = new HashMap();
        processParamMap(formIn, request, params);
        return getStrutsDelegate().forwardParams(mapping.findForward("confirm"), params);
    }
}
