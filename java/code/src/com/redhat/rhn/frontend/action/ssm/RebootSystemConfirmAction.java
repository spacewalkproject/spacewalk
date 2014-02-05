/**
 * Copyright (c) 2014 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.ssm;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.events.SsmSystemRebootEvent;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * Confirm reboot of given systems
 */
public class RebootSystemConfirmAction extends RhnAction
    implements Listable<SystemOverview> {

    /** {@inheritDoc} */
    @Override
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {


        ListRhnSetHelper helper = new ListRhnSetHelper(this, request, getSetDecl());
        helper.setWillClearSet(false);
        helper.setDataSetName(RequestContext.PAGE_LIST);
        helper.setListName("systemList");
        helper.execute();
        if (helper.isDispatched()) {
            return handleDispatch(mapping, (DynaActionForm) formIn, request);
        }

        getStrutsDelegate().prepopulateDatePicker(request,
                (DynaActionForm) formIn, "date", DatePicker.YEAR_RANGE_POSITIVE);

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /** {@inheritDoc} */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.SSM_SYSTEMS_REBOOT;
    }

    private ActionForward handleDispatch(
            ActionMapping mapping,
            DynaActionForm formIn,
            HttpServletRequest request) {

        RequestContext context = new RequestContext(request);
        RhnSet set = getSetDecl().get(context.getCurrentUser());
        List<Long> systemsToReboot = new ArrayList<Long>();
        systemsToReboot.addAll(set.getElementValues());

        Date earliest = getStrutsDelegate().readDatePicker(formIn,
                "date", DatePicker.YEAR_RANGE_POSITIVE);

        MessageQueue.publish(new SsmSystemRebootEvent(
                context.getLoggedInUser().getId(),
                earliest, systemsToReboot));

        int n = set.size();
        if (n == 1) {
            createSuccessMessage(request, "ssm.misc.reboot.message.success.singular",
                    LocalizationService.getInstance().formatNumber(new Integer(n)));
        }
        else {
            createSuccessMessage(request, "ssm.misc.reboot.message.success.plural",
                    LocalizationService.getInstance().formatNumber(new Integer(n)));
        }

        set.clear();
        RhnSetManager.store(set);

        return mapping.findForward("confirm");
    }

    /** {@inheritDoc} */
    public List<SystemOverview> getResult(RequestContext context) {
        return SystemManager.inSet(context.getCurrentUser(),
              getSetDecl().getLabel());
    }
}
