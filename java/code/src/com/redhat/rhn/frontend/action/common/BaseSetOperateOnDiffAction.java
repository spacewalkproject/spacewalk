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
package com.redhat.rhn.frontend.action.common;

import com.redhat.rhn.domain.Identifiable;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * BaseSetOperateOnDiffAction - extension of RhnSetAction
 * that provides a framework for performing specified business
 * operations on the currently selected items in the list.
 *
 * @version $Rev$
 */
public abstract class BaseSetOperateOnDiffAction extends RhnSetAction {

    private static Logger log = Logger.getLogger(BaseSetOperateOnDiffAction.class);

    /**
     * Execute some operation on the items that have removed or added
     * from the set.  Forwards to the "default"
     *
     * NOTE: Inheriting classes must either define two
     * StringResources, or override the generateUserMessage method.
     * The StringResources must be of the form:
     *
     * getSetName() + ".removed"
     * getSetName() + ".added"
     *
     * To provide messages to the UI that would say:
     * "2 Activation Key(s) added."
     * "1 Activation Key(s) removed."
     *
     * If a different message format is required, just override generateUserMessage
     *
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward operateOnDiff(ActionMapping mapping,
                                       ActionForm formIn,
                                       HttpServletRequest request,
                                       HttpServletResponse response) {

        log.debug("operateOnDiff called");

        User user = new RequestContext(request).getLoggedInUser();
        // RhnSet originalSet = getSetDecl().get(user);

        RhnSet currentset = updateSet(request);
        RhnSetManager.store(currentset);

        Map params = makeParamMap(formIn, request);
        HashMap diffmap = new HashMap();

        Iterator originalItems = getCurrentItemsIterator(new RequestContext(request));

        if (log.isDebugEnabled()) {
            log.debug("current set  : " + currentset.getElements());
        }

        while (originalItems.hasNext()) {
            Identifiable ido = (Identifiable) originalItems.next();

            if (log.isDebugEnabled()) {
                log.debug("original item  : " + ido.getId());
            }
            diffmap.put(new RhnSetElement(user.getId(),
                    getSetDecl().getLabel(), ido.getId(), null),
                        "original");
        }


        Iterator currentIter = currentset.getElements().iterator();
        ArrayList added = new ArrayList();
        ArrayList removed = new ArrayList();

        while (currentIter.hasNext()) {
            RhnSetElement elem = (RhnSetElement) currentIter.next();
            if (!diffmap.containsKey(elem)) {
                added.add(elem);
            }
            else {
                diffmap.put(elem, "both");
            }
        }

        Iterator mapIter = diffmap.keySet().iterator();

        while (mapIter.hasNext()) {
            RhnSetElement elem = (RhnSetElement) mapIter.next();
            if (diffmap.get(elem) == "original") {
                removed.add(elem);
            }
        }

        if (log.isDebugEnabled()) {
            log.debug("removed : " + removed);
            log.debug("added : " + added);
        }

        operateOnRemovedElements(removed, request);
        operateOnAddedElements(added, request);

        generateUserMessage(added, removed, request);

        return getStrutsDelegate().forwardParams(mapping.findForward("default"), params);
    }

    protected void generateUserMessage(List added, List removed,
                                       HttpServletRequest request) {
        ActionMessages msg = new ActionMessages();

        if (!removed.isEmpty()) {
            String msgKey = getSetDecl().getLabel() + ".removed";

            Object[] args = new Object[1];
            args[0] = new Integer(removed.size()).toString();
            msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(msgKey, args));
        }

        if (!added.isEmpty()) {
            String msgKey = getSetDecl().getLabel() + ".added";

            Object[] args = new Object[1];
            args[0] = new Integer(added.size()).toString();
            msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(msgKey, args));
        }

        if (msg.size(ActionMessages.GLOBAL_MESSAGE) > 0) {
            getStrutsDelegate().saveMessages(request, msg);
        }
    }

    /**
     * Operate on the removed elements, whatever that entails for a
     * given subclass.  This method is called immediately before
     * operateOnAddedElements.
     * @param elements The elements which were removed
     * @param request The request
     */
    protected abstract void operateOnRemovedElements(List elements,
                                                     HttpServletRequest request);

    /**
     * Operate on the added elements, whatever that entails for a
     * given subclass.  This method is called immediately after
     * operateOnRemovedElements.
     * @param elements The elements which were added
     * @param request The request
     */
    protected abstract void operateOnAddedElements(List elements,
                                                   HttpServletRequest request);

    /**
     * Get the RhnSet 'Decl' for the action
     * @return The set decleration
     */
    public abstract RhnSetDecl getSetDecl();

    /**
     * Get the Iterator for a Collection of Objects
     * that implement the Identifiable interface.  This is required
     * so this base class can calculate the original set of items
     * that are associated with the main object we are operating on.
     *
     * This iterator is then 'diffed' against the items in the RhnSet
     * to determine what should be added vs removed.
     *
     * @param ctx to fetch info from
     * @return Iterator containing Identifiable objects.
     */
    protected abstract Iterator getCurrentItemsIterator(RequestContext ctx);

}
