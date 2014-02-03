/**
 * Copyright (c) 2013 SUSE
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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.SetLabels;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.events.SsmErrataEvent;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

/**
 *
 * @author bo
 */
public class ErrataListAction extends RhnAction implements Listable {
    public static final String LIST_NAME = "errataList";

    /**
     * Entry-point caller.
     * <p/>
     * @param mapping    The ActionMapping used to select this instance.
     * @param actionForm The optional ActionForm bean for this request.
     * @param request    The HTTP Request we are processing.
     * @param response   The HTTP Response we are processing.
     * <p/>
     * @return ActionForward returns an action forward
     * @throws java.lang.Exception General exception.
     */
    @Override
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm actionForm,
                                 HttpServletRequest request,
                                 HttpServletResponse response)
            throws Exception {
        RequestContext requestContext = new RequestContext(request);
        DynaActionForm form = (DynaActionForm) actionForm;

        ListRhnSetHelper setHelper = this.bindDatasets(request);

        if (setHelper.isDispatched()) {
            if (requestContext.wasDispatched("errata.jsp.apply")) {
                return handleConfirm(mapping, form, requestContext, setHelper, request);
            }
        }

        getStrutsDelegate().prepopulateDatePicker(
                request, form, "date", DatePicker.YEAR_RANGE_POSITIVE);
        request.setAttribute("parentUrl", request.getRequestURI());

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    private ActionForward handleConfirm(ActionMapping mapping,
            DynaActionForm form,
            RequestContext context,
            ListRhnSetHelper helper,
            HttpServletRequest request) {
        User user = context.getLoggedInUser();

        List<SystemOverview> srv = SystemManager.inSet(user, SetLabels.SYSTEM_LIST);
        List<Long> serverIds = new ArrayList<Long>(srv.size());
        for (SystemOverview s : srv) {
            serverIds.add(s.getId());
        }

        RhnSet erratas = helper.getSet();
        List<Long> errataIds = new ArrayList<Long>(erratas.size());
        errataIds.addAll(erratas.getElementValues());

        Date scheduleDate = this.getStrutsDelegate().readDatePicker(
                form, "date", DatePicker.YEAR_RANGE_POSITIVE);

        MessageQueue.publish(new SsmErrataEvent(
                user.getId(),
                scheduleDate,
                errataIds,
                serverIds)
        );
        createMessage(request, "ssm.errata.message.scheduled",
                new String[] {LocalizationService.getInstance().formatDate(
                        scheduleDate, request.getLocale())});
        return mapping.findForward("confirm");
    }

    private ListRhnSetHelper bindDatasets(HttpServletRequest request) {
        ListRhnSetHelper shlp = new ListRhnSetHelper(this,
                request, ErrataListAction.getSetDecl());
        shlp.setListName(LIST_NAME);
        shlp.setParentUrl(request.getRequestURI());
        shlp.execute();

        return shlp;
    }

    /**
     * @return Returns RhnSetDecl.ERRATA
     */
    private static RhnSetDecl getSetDecl() {
        return RhnSetDecl.ERRATA;
    }

    /** {@inheritDoc} */
    public List getResult(RequestContext context) {
        return ErrataManager.relevantErrataToSystemSet(context.getLoggedInUser());
    }
}
