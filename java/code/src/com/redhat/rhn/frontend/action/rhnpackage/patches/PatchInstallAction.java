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
package com.redhat.rhn.frontend.action.rhnpackage.patches;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.solarispackage.SolarisManager;

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
 * PatchListAction
 * @version $Rev: 53116 $
 */
public class PatchInstallAction extends RhnSetAction {

    /**
     * Applies the selected patches
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward applyPatch(ActionMapping mapping,
                                     ActionForm formIn,
                                     HttpServletRequest request,
                                     HttpServletResponse response) {
        RhnSet set = updateSet(request);
        Map params = new HashMap();
        StrutsDelegate strutsDelegate = getStrutsDelegate();

        if (set.isEmpty()) {
            ActionMessages msg = new ActionMessages();
            msg.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("patch.applynone"));
            params = makeParamMap(formIn, request);
            strutsDelegate.saveMessages(request, msg);
            return strutsDelegate.forwardParams(mapping.findForward("default"), params);
        }

        processParamMap(formIn, request, params);

        return strutsDelegate.forwardParams(mapping.findForward("install"), params);
    }

    protected void processMethodKeys(Map map) {
        map.put("packagelist.jsp.installpatch", "applyPatch");
    }

    protected void processParamMap(ActionForm formIn,
                                   HttpServletRequest request,
                                   Map params) {
        Long sid = new RequestContext(request).getParamAsLong("sid");
        if (sid != null) {
            params.put("sid", sid);
        }
    }

    protected DataResult getDataResult(User user,
                                       ActionForm formIn,
                                       HttpServletRequest request) {
        Long sid = new RequestContext(request).getParamAsLong("sid");
        return SolarisManager.systemAvailablePatchList(sid, null);
    }

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.PATCH_INSTALL;
    }

}
