/**
 * Copyright (c) 2009--2018 Red Hat, Inc.
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

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.SystemGroupOverview;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * SystemGroupListSetupAction
 * @version $Rev$
 */
public class SystemGroupListSetupAction extends RhnAction
    implements Listable<SystemGroupOverview> {

    private static final Logger LOG = Logger.getLogger(SystemGroupListSetupAction.class);

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        ListRhnSetHelper helper = new ListRhnSetHelper(this, request, getSetDecl());
        helper.execute();

        Map m = helper.getParamMap();
        Map m1 = request.getParameterMap();

        if (helper.isDispatched()) {
            LocalizationService l18nSvc = LocalizationService.getInstance();
            String buttonVal = request.getParameter("dispatch");

            if (l18nSvc.getMessage("grouplist.jsp.union").equals(buttonVal)) {
                union(mapping, formIn, request, response);
                clearSet(helper);
                return mapping.findForward("ssm-list-systems");
            }
            else if (l18nSvc.getMessage("grouplist.jsp.intersection").equals(buttonVal)) {
                intersection(mapping, formIn, request, response);
                clearSet(helper);
                return mapping.findForward("ssm-list-systems");
            }
        }

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    private void clearSet(ListRhnSetHelper helper) {
        RhnSet set =  helper.getSet();
        set.clear();
        RhnSetManager.store(set);
    }

    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.SYSTEM_GROUPS;
    }

    /**
     * Sends the user to the SSM with a system set representing the intersection
     * of their chosen group set
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     */
    public void intersection(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        User user = new RequestContext(request).getCurrentUser();
        RhnSet systemSet = RhnSetDecl.SYSTEMS.create(user);
        RhnSet groupSet = getSetDecl().get(user);

        List<Long> firstList = new ArrayList<Long>();
        List<Long> secondList = new ArrayList<Long>();

        //for the first group, add all the systems to firstList
        Long sgid = groupSet.getElementValues().iterator().next();
        groupSet.removeElement(sgid);

        for (SystemOverview system : SystemManager.systemsInGroup(sgid, null)) {
            Long id = system.getId();
            firstList.add(id);
        }

        //for every subsequent group, remove systems that aren't in the intersection
        for (Long groupId : groupSet.getElementValues()) { //for every group

          //for every system in each group
            for (SystemOverview sys : SystemManager.systemsInGroup(groupId, null)) {
                Long id = sys.getId();
                secondList.add(id);
            }

            firstList = listIntersection(firstList, secondList);
            secondList = new ArrayList<Long>();
        }

        //add all the systems to the set
        for (Long i : firstList) {
            systemSet.addElement(i);
        }
        RhnSetManager.store(systemSet);
        RhnSet set =  getSetDecl().get(user);
        set.clear();
        RhnSetManager.store(set);
    }


    private List<Long> listIntersection(List<Long> one, List<Long> two) {

        List<Long> retval = new ArrayList<Long>();
        for (Long i : one) {
            if (two.contains(i)) {
                retval.add(i);
            }
        }

        return retval;
    }

    /**
     * Sends the user to the SSM with a system set representing the union
     * of their chosen group set
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     */
    public void union(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        User user = new RequestContext(request).getCurrentUser();
        RhnSet systemSet = RhnSetDecl.SYSTEMS.create(user);
        RhnSet groupSet = getSetDecl().get(user);

        Iterator<RhnSetElement> groups = groupSet.getElements().iterator();
        while (groups.hasNext()) { //for every group
            Long sgid = groups.next().getElement();
            Iterator<SystemOverview> systems =
                    SystemManager.systemsInGroup(sgid, null).iterator();

            while (systems.hasNext()) { //for every system in a group
                Long id = systems.next().getId();
                if (!systemSet.contains(id)) {
                    systemSet.addElement(id);
                }
            }
        }

        RhnSetManager.store(systemSet);
    }

    @Override
    public List<SystemGroupOverview> getResult(RequestContext context) {
        User user = context.getCurrentUser();
        DataResult<SystemGroupOverview> dr =
                        SystemManager.groupListWithServerCount(user, null);
        return dr;
    }
}
