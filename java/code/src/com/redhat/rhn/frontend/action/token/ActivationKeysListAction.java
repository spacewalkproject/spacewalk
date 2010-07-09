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
package com.redhat.rhn.frontend.action.token;

import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.token.Token;
import com.redhat.rhn.domain.token.TokenFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ActivationKeyDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.kickstart.KickstartLister;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * ActivatonKeysListAction
 * @version $Rev$
 */
public class ActivationKeysListAction extends RhnAction {
    private static final String LIST_NAME = "activationKeys";
    private static final String DATA_SET = "pageList";
    private static final String DEFAULT_KEY = "default";

    /**
     *
     * @return the set declaration used to this action..
     */
    protected RhnSetDecl getDecl() {
        return RhnSetDecl.ACTIVATION_KEYS;
    }

    /**
     * ${@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) throws Exception {

        RequestContext context = new RequestContext(request);
        User user = context.getLoggedInUser();

        RhnSet set =  getDecl().get(user);
        List <ActivationKeyDto> dataSet = KickstartLister.getInstance().
                                        getActivationKeysInOrg(user.getOrg(), null);

        //if its not submitted
        // ==> this is the first visit to this page
        // clear the 'dirty set'
        if (!context.isSubmitted()) {
            set.clear();
            for (ActivationKeyDto dto : dataSet) {
                if (!dto.isDisabled()) {
                    set.addElement(dto.getId().longValue());
                }
                if (dto.isOrgDefault()) {
                    request.setAttribute(DEFAULT_KEY, dto);
                }
            }
            RhnSetManager.store(set);
        }

        RhnListSetHelper helper = new RhnListSetHelper(request);

        if (request.getParameter(RequestContext.DISPATCH) != null) {
            // if its one of the Dispatch actions handle it..
            helper.updateSet(set, LIST_NAME);
            return handleDispatchAction(mapping, context, set, dataSet);
        }

        // if its a list action update the set and the selections
        if (ListTagHelper.getListAction(LIST_NAME, request) != null) {
            helper.execute(set,
                            LIST_NAME,
                            dataSet);
        }

        // if I have a previous set selections populate data using it
        if (!set.isEmpty()) {
            helper.syncSelections(set, dataSet);
            ListTagHelper.setSelectedAmount(LIST_NAME, set.size(), request);
        }
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        request.setAttribute(DATA_SET, dataSet);
        ListTagHelper.bindSetDeclTo(LIST_NAME, getDecl(), request);
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    private ActionForward handleDispatchAction(ActionMapping mapping,
            RequestContext context, RhnSet set,
            List <ActivationKeyDto> currentKeys) {
        User user = context.getLoggedInUser();
        int numEnabled = 0;
        int numDisabled = 0;
        for (ActivationKeyDto dto : currentKeys) {
            Token token = TokenFactory.lookup(dto.getId().longValue(),
                                            user.getOrg());
            if (set.contains(dto.getId().longValue()) && token.isTokenDisabled()) {
                token.enable();
                TokenFactory.save(token);
                numEnabled++;
            }
            else if (!set.contains(dto.getId().longValue()) &&
                                        !token.isTokenDisabled()) {
                token.disable();
                TokenFactory.save(token);
                numDisabled++;
            }
        }

        reportStatusMessage(context.getRequest(), numEnabled, numDisabled);
        return mapping.findForward("success");
    }

    private void reportStatusMessage(HttpServletRequest req,
            long numEnabled, long numDisabled) {
        ActionMessages msg = new ActionMessages();
        if (numEnabled > 0 && numDisabled > 0) {
            Object[] args = new Object[] {numEnabled, numDisabled};
            String key = "activation-keys.status.message.1";
            msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(key, args));
        }
        else if (numEnabled > 0) {
            Object[] args = new Object[] {numEnabled};
            String key = "activation-keys.status.message.2";
            msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(key, args));
        }
        else if (numDisabled > 0) {
            Object[] args = new Object[] {numDisabled};
            String key = "activation-keys.status.message.3";
            msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(key, args));
        }
        else {
            String key = "activation-keys.status.message.4";
            msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(key));
        }

        saveMessages(req, msg);
    }
}
