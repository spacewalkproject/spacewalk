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
import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.SetLabels;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.events.SsmErrataEvent;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListSessionSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

/**
 *
 * @author bo
 */
public class ErrataListAction extends RhnAction implements Listable {
    //public static final String LIST_NAME = "errataList";
    public static final String SELECTOR = "type";
    public static final String RP_AFFECTED_SYSTEMS = "afs"; // Request param
    private static final String MULTIBIND = "_bind_." +
                                            ErrataListAction.class.getCanonicalName();
    private static final String MULTIBIND_SUMMARY = "summaryList";
    private static final String MULTIBIND_DETAILS = "detailsList";

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
        User user = requestContext.getLoggedInUser();
        DynaActionForm form = (DynaActionForm) actionForm;
        ActionMessages actionMessages = new ActionMessages();

        String forwardId = RhnHelper.DEFAULT_FORWARD;

        ListRhnSetHelper setHelper = this.bindDatasets(request);

        if (setHelper.isDispatched()) {
            if (requestContext.wasDispatched("errata.jsp.apply")) {
                List<SystemOverview> srv = SystemManager.inSet(user, SetLabels.SYSTEM_LIST);
                List<Long> serverIds = new ArrayList<Long>();
                for (int i = 0; i < srv.size(); i++) {
                    serverIds.add(srv.get(i).getId());
                }

                RhnSet packages = setHelper.getSet();
                List<Long> errataIds = new ArrayList<Long>();
                Iterator<Long> iter = packages.getElementValues().iterator();
                while (iter.hasNext()) {
                    errataIds.add(iter.next());
                }

                Date scheduleDate = this.getStrutsDelegate().readDatePicker(
                        form, "date", DatePicker.YEAR_RANGE_POSITIVE);

                MessageQueue.publish(new SsmErrataEvent(
                        user.getId(),
                        scheduleDate,
                        errataIds,
                        serverIds)
                );
                actionMessages.add(
                        ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("ssm.errata.message.scheduled",
                                          LocalizationService.getInstance().formatDate(
                        scheduleDate, request.getLocale())));
                forwardId = "confirm";
            }
        }

        this.getStrutsDelegate().saveMessages(request, actionMessages);

        request.setAttribute("date", this.getStrutsDelegate().prepopulateDatePicker(
                request, (DynaActionForm) form, "date", DatePicker.YEAR_RANGE_POSITIVE));
        request.setAttribute("parentUrl", request.getRequestURI());
        request.setAttribute(SELECTOR, request.getParameter(SELECTOR));

        return mapping.findForward(forwardId);
    }


    private ListRhnSetHelper bindDatasets(HttpServletRequest request) {
        request.setAttribute(ErrataListAction.MULTIBIND,
                             ErrataListAction.MULTIBIND_SUMMARY);
        ListRhnSetHelper shlp = new ListRhnSetHelper(this,
                request, ErrataListAction.getSetDecl(0L));
        shlp.setListName((String) request.getAttribute(ErrataListAction.MULTIBIND));
        shlp.setParentUrl(request.getRequestURI());
        shlp.execute();

        if (request.getParameter(ErrataListAction.RP_AFFECTED_SYSTEMS) != null) {
            request.setAttribute(ErrataListAction.MULTIBIND,
                                 ErrataListAction.MULTIBIND_DETAILS);
            ListSessionSetHelper h = new ListSessionSetHelper(this, request, new HashMap());
            h.setDataSetName((String) request.getAttribute(ErrataListAction.MULTIBIND));
            h.execute();
        }

        return shlp;
    }


    /**
     * @return Returns RhnSetDecl.ERRATA
     */
    static RhnSetDecl getSetDecl(Long sid) {
        return RhnSetDecl.ERRATA.createCustom(sid);
    }

    /** {@inheritDoc} */
    @Override
    public List getResult(RequestContext context) {
        List<SystemOverview> systems = null;
        if (context.getRequest().getAttribute(ErrataListAction.MULTIBIND)
                .equals(ErrataListAction.MULTIBIND_SUMMARY)) {
            systems = ErrataManager.relevantErrataToSystemSet(context.getLoggedInUser());
        }
        else if (context.getRequest().getAttribute(ErrataListAction.MULTIBIND)
                .equals(ErrataListAction.MULTIBIND_DETAILS)) {
            systems = ErrataManager.systemsAffectedInSet(
                    context.getCurrentUser(),
                    Long.parseLong(
                            context.getRequest().getParameter(
                                    ErrataListAction.RP_AFFECTED_SYSTEMS)
                    )
            );
            if (systems != null) {
                for (int i = 0; i < systems.size(); i++) {
                    SystemOverview systemOverview = systems.get(i);
                    Server server = SystemManager.lookupByIdAndUser(systemOverview.getId(),
                                                                context.getLoggedInUser());
                    systemOverview.setChannelId(server.getBaseChannel().getId());
                    systemOverview.setChannelLabels(server.getBaseChannel().getName());

                    List entitlement = new ArrayList();
                    for (Iterator<Entitlement> itr = server.getEntitlements().iterator();
                            itr.hasNext();) {
                        entitlement.add(itr.next().getLabel());
                    }

                    systemOverview.setEntitlement(entitlement);
                }
            }
        }

        return systems;
    }
}
