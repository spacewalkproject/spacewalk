/**
 * Copyright (c) 2015 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.groups;

import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.SystemGroupOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * SSMGroupManageAction
 * @version $Rev$
 */
public class SSMGroupManageAction extends RhnAction {
    public static final Long ADD = 1L;
    public static final Long REMOVE = 0L;

    /**
     * {@inheritDoc}
     */
    @Override
    public ActionForward execute(ActionMapping mapping,
            ActionForm form,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        RequestContext rctx = new RequestContext(request);
        User user = rctx.getCurrentUser();
        DynaActionForm daForm = (DynaActionForm)form;

        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());

        List<SystemGroupOverview> groups = SystemManager.groupList(user, null);

        // If submitted, save the user's choices for the confirm page
        if (isSubmitted(daForm)) {
            processList(user, request);
            return mapping.findForward("confirm");
        }

        request.setAttribute(RequestContext.PAGE_LIST, groups);
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    private int processList(User user, HttpServletRequest request) {
        List<Long> addList = new ArrayList<Long>();
        List<Long> removeList = new ArrayList<Long>();

        Enumeration<String> names = request.getParameterNames();
        while (names.hasMoreElements()) {
            String aName = names.nextElement();
            String aValue = request.getParameter(aName);
            Long aId = null;
            try {
                aId = Long.parseLong(aName);
            }
            catch (NumberFormatException e) {
                // not a param we care about; skip
                continue;
            }
            if ("add".equals(aValue)) {
                addList.add(aId);
            }
            else if ("remove".equals(aValue)) {
                removeList.add(aId);
            }
        }

        if (addList.size() + removeList.size() > 0) {
            RhnSet cset = RhnSetDecl.SSM_GROUP_LIST.get(user);
            cset.clear();
            for (Long id : addList) {
                cset.addElement(id, ADD);
            }
            for (Long id : removeList) {
                cset.addElement(id, REMOVE);
            }
            RhnSetManager.store(cset);
        }
        return addList.size() + removeList.size();
    }
}

