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
package com.redhat.rhn.frontend.action.systems;

import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * SSMUpdateSoftwareProfileConfirm
 * @version $Rev$
 */
public class SSMUpdateSoftwareProfileConfirm extends RhnAction implements Listable {
    /**
     *
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        RequestContext context = new RequestContext(request);

        User user = context.getLoggedInUser();
        RhnSet set = RhnSetDecl.SYSTEMS.get(user);
        request.setAttribute("system_count", set.size());
        DynaActionForm daForm = (DynaActionForm)formIn;
        Map params = makeParamMap(request);

        if (isSubmitted(daForm)) {
            Iterator it = set.iterator();
            Set<Long> serverIds = new HashSet<Long>();
            while (it.hasNext()) {
                Long sid = ((RhnSetElement)it.next()).getElement();
                serverIds.add(sid);
                Server server = SystemManager.lookupByIdAndUser(sid, user);
            }
            Date now = new Date();
            PackageAction a = (PackageAction) ActionManager.schedulePackageAction(user,
                    (List) null, ActionFactory.TYPE_PACKAGES_REFRESH_LIST, now, serverIds);
            ActionFactory.save(a);
            ActionMessages msg = new ActionMessages();
            String profileStr = "profiles";
            if (set.size() == 1) {
                profileStr = "profile";
            }
            msg.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("ssm.sw.systems.confirmmessage", set.size(),
                    profileStr));
            getStrutsDelegate().saveMessages(request, msg);
            return getStrutsDelegate().forwardParams(
                    mapping.findForward("success"), params);
        }

        return getStrutsDelegate().forwardParams(
                mapping.findForward(RhnHelper.DEFAULT_FORWARD), params);
    }

    /**
     * {@inheritDoc}
     */
    public List getResult(RequestContext contextIn) {
        return SystemManager.inSet(contextIn.getLoggedInUser(),
                                        RhnSetDecl.SYSTEMS.getLabel());
    }

}
