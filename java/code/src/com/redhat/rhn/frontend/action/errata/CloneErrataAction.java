/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.errata;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.commons.lang.BooleanUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * CloneErrataSubmitAction
 * @version $Rev$
 */
public class CloneErrataAction extends RhnSetAction {
    
    /**
     * Updates the set with the selected errata to clone
     * and forwards the user to the clone errata page.
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward cloneErrata(ActionMapping mapping,
                                     ActionForm formIn,
                                     HttpServletRequest request,
                                     HttpServletResponse response) {
        RhnSet set = updateSet(request);
        Map params = makeParamMap(formIn, request);
        
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        
        //if they chose no errata, return to the same page with a message
        if (set.isEmpty()) {
            ActionMessages msg = new ActionMessages();
            msg.add(ActionMessages.GLOBAL_MESSAGE, 
                    new ActionMessage("errata.applynone"));
            strutsDelegate.saveMessages(request, msg);
            return strutsDelegate.forwardParams(mapping.findForward("default"), params);
        }
        
        return mapping.findForward("clone");
    }

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.ERRATA_CLONE;
    }

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User user, 
                                       ActionForm formIn, 
                                       HttpServletRequest request) {
        RequestContext rctx = new RequestContext(request);
        return CloneErrataActionHelper.getSubmittedDataResult(rctx, 
                                                              (DynaActionForm) formIn, 
                                                              null);
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("cloneerrata.jsp.cloneerrata", "cloneErrata");
    }
    
    protected boolean isShowCloned(DynaActionForm daForm) {
        return BooleanUtils.toBoolean((Boolean) daForm.get("showalreadycloned"));
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm formIn, 
                                   HttpServletRequest request, 
                                   Map params) {
        DynaActionForm daForm = (DynaActionForm) formIn;
        params.put(RhnAction.SUBMITTED, daForm.get(RhnAction.SUBMITTED));
        params.put(CloneErrataActionHelper.CHANNEL, 
                   daForm.get(CloneErrataActionHelper.CHANNEL));
        params.put(CloneErrataActionHelper.SHOW_ALREADY_CLONED, 
                   daForm.get(CloneErrataActionHelper.SHOW_ALREADY_CLONED));
    }

}
