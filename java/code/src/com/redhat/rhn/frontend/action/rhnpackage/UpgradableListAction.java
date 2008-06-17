/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.rhnpackage;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

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
 * UpgradableListAction
 * @version $Rev$
 */
public class UpgradableListAction extends RhnSetAction {
    
    /**
     * Downloads the selected packages
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward download(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {
        RhnSet set = updateSet(request);
        Map params = new HashMap();
        
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        
        //if they chose no packages, return to the same page with a message
        if (set.isEmpty()) {
            ActionMessages msg = new ActionMessages();
            msg.add(ActionMessages.GLOBAL_MESSAGE, 
                    new ActionMessage("download.none"));
            params = makeParamMap(formIn, request);
            strutsDelegate.saveMessages(request, msg);
            return strutsDelegate.forwardParams(mapping.findForward("default"), params);
        }
        
        //if they chose too many packages, send a message to the screen
        if (set.size() > Config.get().getInt("download_tarball_max")) {
            ActionMessages msg = new ActionMessages();
            msg.add(ActionMessages.GLOBAL_MESSAGE, 
                    new ActionMessage("download.toomany", 
                            new Integer(Config.get().getInt("download_tarball_max"))));
            params = makeParamMap(formIn, request);
            strutsDelegate.saveMessages(request, msg);
            return strutsDelegate.forwardParams(mapping.findForward("default"), params);
        }
        
        //if they chose packages, send them to the download confirmation page
        Long sid = new RequestContext(request).getParamAsLong("sid");
        if (sid != null) {
            params.put("sid", sid);
        }
        return strutsDelegate.forwardParams(mapping.findForward("download"), params);
    }
    
    /**
     * Upgrades the selected packages
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward upgrade(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        RhnSet set = updateSet(request);
        Map params = new HashMap();
        
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        RequestContext requestContext = new RequestContext(request);
        
        //if they chose no packages, return to the same page with a message
        if (set.isEmpty()) {
            ActionMessages msg = new ActionMessages();
            msg.add(ActionMessages.GLOBAL_MESSAGE, 
                    new ActionMessage("upgrade.none"));
            params = makeParamMap(formIn, request);
            strutsDelegate.saveMessages(request, msg);
            return strutsDelegate.forwardParams(mapping.findForward("default"), params);
        }
        
        //if they chose packages, send them to the upgrade confirmation page
        Long sid = requestContext.getParamAsLong("sid");
        if (sid != null) {
            params.put("sid", sid);
        }
        return strutsDelegate.forwardParams(mapping.findForward("upgrade"), params);
    }
    
    protected DataResult getDataResult(User user,
            ActionForm formIn, HttpServletRequest request) {
        return PackageManager.upgradable(
                new RequestContext(request).getRequiredParam("sid"), null);
    }
    
    protected void processMethodKeys(Map map) {
        map.put("upgradable.jsp.download", "download");
        map.put("upgradable.jsp.upgrade", "upgrade");
    }
    
    protected void processParamMap(ActionForm formIn, 
                                   HttpServletRequest request, 
                                   Map params) {
        params.put("sid", new RequestContext(request).getRequiredParam("sid"));
    }

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.PACKAGES_UPGRADABLE;
    }

}
