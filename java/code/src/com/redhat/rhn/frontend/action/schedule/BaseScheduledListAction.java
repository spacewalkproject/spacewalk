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
package com.redhat.rhn.frontend.action.schedule;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * Base action for scheduled action lists
 * @version $Rev$
 */
public abstract class BaseScheduledListAction extends RhnAction implements Listable {

    /**
     *
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext context = new RequestContext(request);
        ListRhnSetHelper helper = new ListRhnSetHelper(this, request, getSetDecl());
        helper.execute();
        if (helper.isDispatched()) {
            return handleSubmit(mapping, formIn, request, response);
        }

        return mapping.findForward("default");
    }


    /**
     * Gets the set decl
     * @return the set decl
     */
    protected abstract RhnSetDecl getSetDecl();

    /**
     *
     * {@inheritDoc}
     */
    public abstract List getResult(RequestContext context);

    /**
     * Handle the submit
     * @return an action forward
     */
    protected abstract ActionForward handleSubmit(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response);


    /**
     * Archives the actions.
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward archiveAction(ActionMapping mapping,
                                       ActionForm formIn,
                                       HttpServletRequest request,
                                       HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();

        User user = requestContext.getLoggedInUser();
        //Update the set first and get the size so we know
        //how many actions we have archived.
        RhnSet set = getSetDecl().get(user);

        //Archive the actions
        ActionManager.archiveActions(user, getSetDecl().getLabel());


        ActionMessages msgs = new ActionMessages();
        /**
         * If there was only one action archived, display the "action" archived
         * message, else display the "actions" archived message.
         */
        if (set.size() == 1) {
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                     new ActionMessage("message.actionArchived",
                             LocalizationService.getInstance()
                                                .formatNumber(new Integer(set.size()))));
        }
        else {
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                     new ActionMessage("message.actionsArchived",
                             LocalizationService.getInstance()
                                                .formatNumber(new Integer(set.size()))));
        }
        strutsDelegate.saveMessages(request, msgs);

        return mapping.findForward("archive");
    }

}
