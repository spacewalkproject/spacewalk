/**
 * Copyright (c) 2010 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.systems.duplicate;

import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.helper.ListSessionSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * DuplicateSystemsCompareAction
 * @version $Rev$
 */
public class DuplicateSystemsCompareAction extends RhnAction implements Listable {
    public static final String KEY = "key";
    public static final String KEY_TYPE = "key_type";
    public static final String REFRESH_BUTTON = "refresh";

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        
        Map params = new HashMap();
        params.put(KEY, context.getRequiredParamAsString(KEY));
        params.put(KEY_TYPE, context.getRequiredParamAsString(KEY_TYPE));
        
        ListSessionSetHelper helper = new ListSessionSetHelper(this, request);
        helper.execute();
        if (helper.isDispatched()) {
            return handleConfirm(context, mapping);
        }
        
        if (request.getParameter(REFRESH_BUTTON) != null) {
            //TODO - Logic to delete profiles 
        }        
        
        List<Long> sids = new LinkedList<Long>();
        for (String sid : helper.getSet()) {
            sids.add(Long.valueOf(sid));
        }
        request.setAttribute("systems", 
                SystemManager.hydrateServerFromIds(sids, context.getLoggedInUser()));
        return mapping.findForward("default");
    }

    private ActionForward handleConfirm(RequestContext context,
            ActionMapping mapping) {
        getStrutsDelegate().saveMessage("duplicate.systems.delete.confirm.message",
                context.getRequest());
        return mapping.findForward("confirm");
    }

    /**
     * {@inheritDoc}
     */
    public List getResult(RequestContext contextIn) {
        String key = contextIn.getRequiredParamAsString(KEY);
        String keyType = contextIn.getRequiredParamAsString(KEY_TYPE);
        if (DuplicateSystemsAction.HOSTNAME.equals(keyType)) {
            return SystemManager.listDuplicatesByHostname
                                (contextIn.getLoggedInUser(), key);
        }
        else if (DuplicateSystemsAction.MAC_ADDRESS.equals(keyType)) {
            return SystemManager.listDuplicatesByMac(contextIn.getLoggedInUser(), key);
        }
        return SystemManager.listDuplicatesByIP(contextIn.getLoggedInUser(), key);
    }
}
