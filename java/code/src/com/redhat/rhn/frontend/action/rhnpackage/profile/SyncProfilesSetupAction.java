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
package com.redhat.rhn.frontend.action.rhnpackage.profile;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.rhnpackage.profile.Profile;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.SessionSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.profile.ProfileManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * SyncProfilesSetupAction
 * @version $Rev$
 */
public class SyncProfilesSetupAction extends RhnAction implements Listable {

    private static final CompareProfileSetupAction DECL_ACTION = 
        new CompareProfileSetupAction();

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);

        Long prid = requestContext.getRequiredParam(RequestContext.PRID);
        Long sid = requestContext.getRequiredParam(RequestContext.SID);
        
        User user = requestContext.getLoggedInUser();
        Server server = SystemManager.lookupByIdAndUser(sid, user);
        Profile profile = ProfileManager.lookupByIdAndOrg(prid, user.getOrg());

        ListHelper helper = new ListHelper(this, request);
        helper.execute();

        DynaActionForm dynaForm = (DynaActionForm) formIn;
        getStrutsDelegate().prepopulateDatePicker(request, dynaForm,
                "date", DatePicker.YEAR_RANGE_POSITIVE);

        if (requestContext.wasDispatched("schedulesync.jsp.schedulesync")) {
            Date time = getStrutsDelegate().readDatePicker(dynaForm, "date",
                    DatePicker.YEAR_RANGE_POSITIVE);
            Map syncParam = new HashMap();
            syncParam.put(RequestContext.SID, sid);
            syncParam.put(RequestContext.PRID, prid);
            syncParam.put(RequestContext.DISPATCH,
                    request.getParameter(RequestContext.DISPATCH));
            syncParam.put("time", time.getTime());
            return getStrutsDelegate().forwardParams(mapping.findForward("sync"),
                    syncParam);
        }

        request.setAttribute("system", server);
        request.setAttribute("profilename", profile.getName());
        return getStrutsDelegate().forwardParams(mapping.findForward("default"),
                                       request.getParameterMap());
    }

    /**
     * Get the page list for this action
     * @param context RequestContext
     * @return list of packages prepared for synchronization
     */
    public List getResult(RequestContext context) {
        Long sid = context.getRequiredParam("sid");
        Long prid = context.getRequiredParam("prid");
        User user = context.getLoggedInUser();

        Set <String> pkgIdCombos = SessionSetHelper.lookupAndBind(context.getRequest(), 
                getDecl(sid));

        DataResult dr = ProfileManager.prepareSyncToProfile(sid, prid,
                user.getOrg().getId(), null, pkgIdCombos);
        
        return dr;
    }
    
    protected String getDecl(Long sid) {
        return DECL_ACTION.getDecl(sid);
    }
}
