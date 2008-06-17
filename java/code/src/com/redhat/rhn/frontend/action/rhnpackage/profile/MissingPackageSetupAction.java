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
package com.redhat.rhn.frontend.action.rhnpackage.profile;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.rhnpackage.profile.Profile;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.BaseSetListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.profile.ProfileManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * MissingPackageSetupAction
 * @version $Rev$
 */
public class MissingPackageSetupAction extends BaseSetListAction {
    
    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(RequestContext requestContext,
            PageControl pc) {

        RhnSet pkgs = getSetDecl().get(requestContext.getCurrentUser());
        Long sid = requestContext.getRequiredParam("sid");
        String type = requestContext.getParam("sync", true);
        
        if ("system".equals(type)) {
            Long sid1 = requestContext.getRequiredParam("sid_1");
            return ProfileManager.getMissingSystemPackages(
                    requestContext.getCurrentUser(), sid, sid1, pkgs, pc);
        }
        else if ("profile".equals(type)) {
            Long prid = requestContext.getRequiredParam("prid");
            return ProfileManager.getMissingProfilePackages(
                    requestContext.getCurrentUser(), sid, prid, pkgs.getElementValues(), 
                    pc);
            
        }
        
        // if we get here we're screwed.
        throw new BadParameterException(
            "Missing one or more of the required paramters [sync,sid,sid_1,prid]"); 
    }

    /**
     * {@inheritDoc}
     */
    protected void processRequestAttributes(RequestContext rctx) {
        super.processRequestAttributes(rctx);
        rctx.lookupAndBindServer();
        Long time = rctx.getParamAsLong("date");
        if (time != null) {
            rctx.getRequest().setAttribute("time", time);
        }
        
        String type = rctx.getParam("sync", true);
        if ("system".equals(type)) {
            Long sid1 = rctx.getRequiredParam("sid_1");
            Server server1 = SystemManager.lookupByIdAndUser(sid1, rctx.getCurrentUser());
            rctx.getRequest().setAttribute("system1", server1);
        }
        else if ("profile".equals(type)) {
            Long prid = rctx.getRequiredParam("prid");
            Profile profile = ProfileManager.lookupByIdAndOrg(prid,
                    rctx.getCurrentUser().getOrg());
            rctx.getRequest().setAttribute("profilename", profile.getName());
        }
    }

    /**
     * {@inheritDoc}
     */
    protected void processPageControl(PageControl pc) {
        // no op
    }

    /**
     * {@inheritDoc}
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.PACKAGES_FOR_SYSTEM_SYNC;
    }

}
