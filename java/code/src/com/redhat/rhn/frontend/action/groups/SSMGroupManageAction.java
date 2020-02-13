/**
 * Copyright (c) 2015--2018 Red Hat, Inc.
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

import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.SystemGroupOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * SSMGroupManageAction
 * @version $Rev$
 */
public class SSMGroupManageAction extends RhnAction
    implements Listable<SystemGroupOverview> {

    public static final Long ADD = 1L;
    public static final Long REMOVE = 0L;
    public static final Long NO_CHANGE = -1L;

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

        ListRhnSetHelper helper =
                        new ListRhnSetHelper(this, request, RhnSetDecl.SSM_GROUP_LIST);
        helper.ignoreEmptySelection();
        helper.execute();

        Map<Long, Long> addRmvSet = processList(user, request);

        if (helper.isDispatched()) {
            return mapping.findForward(RhnHelper.CONFIRM_FORWARD);
        }
        else {
            request.setAttribute("actions_set", addRmvSet);
        }

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    private Map<Long, Long> processList(User user, HttpServletRequest request) {
        List<Long> addList = new ArrayList<Long>();
        List<Long> removeList = new ArrayList<Long>();
        List<Long> noChangeList = new ArrayList<Long>();

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
            else {
                noChangeList.add(aId);
            }
        }

        RhnSet cset = RhnSetDecl.SSM_GROUP_LIST.get(user);
        for (Long id : addList) {
            cset.removeElement(id);
            cset.addElement(id, ADD);
        }
        for (Long id : removeList) {
            cset.removeElement(id);
            cset.addElement(id, REMOVE);
        }
        for (Long id : noChangeList) {
            cset.removeElement(id);
            cset.addElement(id, NO_CHANGE);
        }
        RhnSetManager.store(cset);

        Map<Long, Long> currentChoices = new HashMap<Long, Long>();
        for (RhnSetElement elt : cset.getElements()) {
            currentChoices.put(elt.getElement(), elt.getElementTwo());
        }
        return currentChoices;
    }

    @Override
    public List<SystemGroupOverview> getResult(RequestContext context) {
        User user = context.getCurrentUser();
        return SystemManager.groupList(user, null);
    }
}

