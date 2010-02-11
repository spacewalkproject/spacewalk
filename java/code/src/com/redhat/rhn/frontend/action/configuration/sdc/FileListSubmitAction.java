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
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * FileListSubmitAction, for sdc configuration pages
 * @version $Rev$
 */
public class FileListSubmitAction extends RhnSetAction {

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User user, ActionForm formIn,
            HttpServletRequest request) {
        Server server = new RequestContext(request).lookupAndBindServer();
        return ConfigurationManager.getInstance()
                .listFileNamesForSystem(user, server, null);
    }

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_FILE_NAMES;
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("sdcdeployfile.jsp.confirm", "goToConfirm");
        map.put("sdcdifffile.jsp.confirm", "goToConfirm");
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm formIn,
            HttpServletRequest request, Map params) {
        params.put("sid", new RequestContext(request).getRequiredParam("sid"));
    }
    
    /**
     * Forwards to the confirm page unless the user hasn't selected anything.
     * @param mapping struts ActionMapping
     * @param formIn struts ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return struts ActionForward to the confirm page.
     */
    public ActionForward goToConfirm(ActionMapping mapping,
                                     ActionForm formIn,
                                     HttpServletRequest request,
                                     HttpServletResponse response) {
        //They didn't select anything. Tell them to select something.
        if (updateSet(request).size() < 1) {
            ActionErrors errors = new ActionErrors();
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("sdcfilelist.jsp.noSelected"));
            addErrors(request, errors);
            return getStrutsDelegate().forwardParams(
                    mapping.findForward(RhnHelper.DEFAULT_FORWARD),
                    makeParamMap(formIn, request));
        }
        
        //They selected stuff! send them to the confirm page.
        Map params = new HashMap();
        processParamMap(formIn, request, params);
        return getStrutsDelegate().forwardParams(mapping.findForward(
                "confirm"), params);
    }

}
