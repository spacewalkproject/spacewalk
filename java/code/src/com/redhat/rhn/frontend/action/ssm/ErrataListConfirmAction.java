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
import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.SetLabels;
import com.redhat.rhn.frontend.dto.ErrataOverview;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.events.SsmErrataEvent;
import com.redhat.rhn.frontend.struts.ActionChainHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * Confirm application of errata to systems in SSM.
 */
public class ErrataListConfirmAction extends RhnAction implements
        Listable<ErrataOverview> {
    /** {@inheritDoc} */
    @Override
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {


        ListRhnSetHelper helper = new ListRhnSetHelper(this, request, getSetDecl());
        helper.setWillClearSet(false);
        helper.setListName("errataList");
        helper.execute();

        if (helper.isDispatched()) {
            return handleDispatch(mapping, (DynaActionForm) formIn, request);
        }

        getStrutsDelegate().prepopulateDatePicker(request,
                (DynaActionForm) formIn, "date", DatePicker.YEAR_RANGE_POSITIVE);

        ActionChainHelper.prepopulateActionChains(request);

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    private ActionForward handleDispatch(
            ActionMapping mapping,
            DynaActionForm formIn,
            HttpServletRequest request) {
        RequestContext context = new RequestContext(request);
        User user = context.getCurrentUser();

        Date earliest = getStrutsDelegate().readDatePicker(formIn,
                "date", DatePicker.YEAR_RANGE_POSITIVE);
        ActionChain actionChain = ActionChainHelper.readActionChain(formIn, user);

        List<SystemOverview> systems = SystemManager.inSet(user, SetLabels.SYSTEM_LIST);
        List<Long> serverIds = new ArrayList<Long>(systems.size());
        for (SystemOverview s : systems) {
            serverIds.add(s.getId());
        }

        RhnSet erratas = getSetDecl().get(context.getCurrentUser());
        List<Long> errataIds = new ArrayList<Long>(erratas.size());
        errataIds.addAll(erratas.getElementValues());

        MessageQueue.publish(new SsmErrataEvent(
                user.getId(),
                earliest,
                actionChain,
                errataIds,
                serverIds)
        );

        if (actionChain == null) {
            createMessage(
                request,
                "ssm.errata.message.scheduled",
                new String[] {LocalizationService.getInstance().formatDate(earliest,
                    request.getLocale())});
        }
        else {
            createMessage(request, "ssm.errata.message.queued", new String[] {
                actionChain.getId().toString(), actionChain.getLabel()});
        }

        RhnSet set = getSetDecl().get(context.getCurrentUser());
        set.clear();
        RhnSetManager.store(set);

        return mapping.findForward("confirm");
    }

    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.ERRATA;
    }

    /** {@inheritDoc} */
    public List<ErrataOverview> getResult(RequestContext context) {
        return ErrataManager.lookupErrataListFromSet(context.getCurrentUser(),
                getSetDecl().getLabel());
    }
}
