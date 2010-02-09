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
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.ActionType;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BaseSetOperateOnSelectedItemsAction;
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
 * DiffSubmitAction
 * @version $Rev$
 */
public class ConfigListSubmitAction extends BaseSetOperateOnSelectedItemsAction {

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User userIn, 
                                       ActionForm formIn, 
                                       HttpServletRequest requestIn) {
        return ConfigurationManager.getInstance().listFileNamesForSsm(userIn, null);
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
    protected void processMethodKeys(Map mapIn) {
        mapIn.put("ssmdiff.jsp.schedule", "scheduleDiff");
        mapIn.put("ssmdeploy.jsp.schedule", "scheduleDeploy");
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm formIn, 
                                   HttpServletRequest requestIn, 
                                   Map paramsIn) {
        //no-op
    }
    
    /**
     * @param mapping struts ActionMapping
     * @param formIn struts ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return forward to the confirm page
     */
    public ActionForward scheduleDeploy(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        return schedule(mapping, formIn, request,  
                ActionFactory.TYPE_CONFIGFILES_DEPLOY);
    }

    
    /**
     * @param mapping struts ActionMapping
     * @param formIn struts ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return forward to the confirm page
     */
    public ActionForward scheduleDiff(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        return schedule(mapping, formIn, request,  
                ActionFactory.TYPE_CONFIGFILES_DIFF);
    }
    
    /**
     * @param mapping struts ActionMapping
     * @param formIn struts ActionForm
     * @param request HttpServletRequest
     * @param feature the feature to schedule on configfiles.deploy /diff ...
     * @return forward to the confirm page
     */
    private ActionForward schedule(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            ActionType feature) {
        RhnSet set = updateSet(request);
        if (set.isEmpty()) {
            return handleEmptySelection(mapping, formIn, request);
        }
        Map params = new HashMap();
        params.put("feature", feature.getLabel());
        return getStrutsDelegate().forwardParams(mapping.findForward("confirm"), 
                params);        
    }    
}
