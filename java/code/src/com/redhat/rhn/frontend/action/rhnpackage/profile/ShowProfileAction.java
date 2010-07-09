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

import com.redhat.rhn.domain.rhnpackage.profile.Profile;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.systems.sdc.SdcHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.profile.ProfileManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.util.LabelValueBean;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ShowProfileAction
 * @version $Rev$
 */
public class ShowProfileAction extends RhnAction {

    private static Logger log = Logger.getLogger(ShowProfileAction.class);
    private static final String BTN_CREATE = "createBtn";
    private static final String BTN_COMPARE_PROFILES = "compareProfilesBtn";
    private static final String BTN_COMPARE_SYSTEMS = "compareSystemsBtn";

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);

        ActionForward forward = null;
        DynaActionForm f = (DynaActionForm)form;
        Long sid = requestContext.getRequiredParam("sid");
        User user = requestContext.getLoggedInUser();
        Server server = SystemManager.lookupByIdAndUser(sid, user);
        request.setAttribute("system", server);
        SdcHelper.ssmCheck(request, server.getId(), user);
        if (!isSubmitted(f)) {
            setup(request, f);
            forward =  getStrutsDelegate().forwardParams(mapping.findForward("default"),
                    request.getParameterMap());
        }
        else if (buttonPressed(BTN_CREATE, f)) {
            forward = create(mapping, f, request, response);
        }
        else if (buttonPressed(BTN_COMPARE_PROFILES, f)) {
            forward = compareProfiles(mapping, f, request, response);
        }
        else if (buttonPressed(BTN_COMPARE_SYSTEMS, f)) {
            forward = compareSystems(mapping, f, request, response);
        }

        return forward;
    }

    private boolean buttonPressed(String btnName, DynaActionForm form) {
        String btn = (String) form.get(btnName);
        return (btn != null && !"".equals(btn));
    }

    private ActionForward compareSystems(ActionMapping mapping,
            DynaActionForm f, HttpServletRequest request,
            HttpServletResponse response) {

        User user = new RequestContext(request).getLoggedInUser();
        RhnSetDecl.PACKAGES_FOR_SYSTEM_SYNC.clear(user);
        Map params = new HashMap();
        params.put("sid", request.getParameter("sid"));
        params.put("sid_1", f.get("server"));
        return getStrutsDelegate().forwardParams(mapping.findForward("comparesystems"),
                params);
    }

    private ActionForward compareProfiles(ActionMapping mapping,
            DynaActionForm f, HttpServletRequest request,
            HttpServletResponse response) {
        User user = new RequestContext(request).getLoggedInUser();
        RhnSetDecl.PACKAGES_FOR_SYSTEM_SYNC.clear(user);
        Map params = new HashMap();
        params.put("sid", request.getParameter("sid"));
        params.put("prid", f.get("profile"));
        return getStrutsDelegate().forwardParams(mapping.findForward("compareprofiles"),
                params);
    }

    private ActionForward create(ActionMapping mapping, DynaActionForm f,
            HttpServletRequest request, HttpServletResponse response) {

        Map params = new HashMap();
        params.put("sid", request.getParameter("sid"));
        return getStrutsDelegate().forwardParams(mapping.findForward("create"),
                params);
    }

    private void setup(HttpServletRequest request, DynaActionForm form) {
        if (log.isDebugEnabled()) {
            log.debug("Setting up form with default values.");
        }
        // get lits of Profiles
        // create a new list of label, value pairs
        User user = new RequestContext(request).getLoggedInUser();
        Server server = (Server) request.getAttribute("system");
        List dbprofiles = ProfileManager.compatibleWithServer(server, user.getOrg());
        List profiles = new ArrayList(dbprofiles.size());
        for (Iterator itr = dbprofiles.iterator(); itr.hasNext();) {
            Profile p = (Profile) itr.next();
            profiles.add(new LabelValueBean(p.getName(), p.getId().toString()));
        }

        List dbservers = SystemManager.compatibleWithServer(user, server);
        List servers = new ArrayList(dbservers.size());
        for (Iterator itr = dbservers.iterator(); itr.hasNext();) {
            Map m = (Map) itr.next();
            servers.add(new LabelValueBean((String)m.get("name"), m.get("id").toString()));
        }

        request.setAttribute("profiles", profiles);
        request.setAttribute("servers", servers);
        form.set("profile", new Long(0));
        form.set("server", new Long(0));
    }
}
