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
package com.redhat.rhn.frontend.struts;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.Identifiable;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.BaseDto;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

/**
 * RhnSetHelper
 * @version $Rev$
 */
public class RhnSetHelper {

    private RhnSetDecl setDecl;
    private HttpServletRequest request;
    private ActionMapping mapping;
    private String forward;
    private RequestContext requestContext;
    private StrutsDelegate strutsDelegate;


    /**
     * Constructor
     *
     * @param mappingIn associated with the helper
     * @param setIn we are operating on
     * @param requestIn to associate
     */
    public RhnSetHelper(ActionMapping mappingIn, RhnSetDecl setIn,
            HttpServletRequest requestIn) {
        this.setDecl = setIn;
        this.request = requestIn;
        this.mapping = mappingIn;
        this.forward = RhnHelper.DEFAULT_FORWARD;
        requestContext = new RequestContext(requestIn);
        strutsDelegate = StrutsDelegate.getInstance();
    }

    /**
     * Constructor for just a request
     * @param setIn RhnSetDecl to associate with the helper
     * @param requestIn to associate with helper
     *
     */
    public RhnSetHelper(RhnSetDecl setIn, HttpServletRequest requestIn) {
        this(null, setIn, requestIn);
    }

    /**
     * Use this constructor if u just
     * need to deal with the set.
     * @param setIn the set we are operating on
     */
    public RhnSetHelper(RhnSetDecl setIn) {
        this.setDecl = setIn;
    }

    /**
     * Updates RhnSet with checked set elements
     * @param paramsIn Map of request parameters you want to forward
     * along with the ActionForward
     * @return The ActionForward to go to next.
     */
    public ActionForward updatelist(Map paramsIn) {
        updateSet();
        paramsIn.put("setupdated", "true");
        paramsIn.put(RhnAction.SUBMITTED, "true");
        return strutsDelegate.forwardParams(mapping.findForward(forward), paramsIn);
    }

    /**
     * Updates the set with the items on the current page
     * @return the newly updated set
     */
    public RhnSet updateSet() {
        User user = requestContext.getLoggedInUser();

        RhnSet set = this.setDecl.get(user);
        String[] selected = request.getParameterValues("items_selected");
        String[] itemsonpage = request.getParameterValues("items_on_page");

        //remove all the items on page
        if (itemsonpage != null) {
            set.removeElements(itemsonpage);
        } //if

        //add all the items selected
        if (selected != null) {
            set.addElements(selected);
        } //if

        // Save the new RhnSet
        RhnSetManager.store(set);
        return set;
    }

    /**
     * Puts all systems visible to the user into the set.
     * @param dr DataResult to use to select everything with.
     * @param paramsIn Map of request parameters you want to forward
     * along with the ActionForward
     * @return The ActionForward to go to next.
     */
    public ActionForward selectall(DataResult dr, Map paramsIn) {

        selectAllData(dr, requestContext.getLoggedInUser());

        paramsIn.put("setupdated", "true");
        paramsIn.put(RhnAction.SUBMITTED, "true");
        return strutsDelegate.forwardParams(mapping.findForward(forward), paramsIn);
    }

    /**
     * Puts all selectable data in a given data result into an rhn set.
     * @param result DataResult to use to select everything with.
     * @param user the user needed to access the set.
     */
    public void selectAllData(List result, User user) {
        // Get an "unelaborated" DataResult containing all of the
        // user's visible systems
        // DataResult dr = getDataResult(user, request);

        this.setDecl.clear(user);
        RhnSet rs = this.setDecl.create(user);

        /*
         * Loop through all items in the DataResult and make a new
         * RhnSet containing all of the items.
         */
        Iterator itr = result.iterator();
        while (itr.hasNext()) {
            Object dataObject = itr.next();
            if (dataObject instanceof BaseDto) {
                BaseDto next = (BaseDto) dataObject;
                if (next.isSelectable()) {
                    next.addToSet(rs);
                }
            }
            else if (dataObject instanceof Identifiable) {
                Identifiable row = (Identifiable) dataObject;
                rs.addElement(row.getId());
            }
            else {
                throw new IllegalArgumentException("You are trying to use Select All" +
                        "when the objects in your DataResult are not an BaseDto " +
                        "or Identifiable type objects");
            }
        }
        RhnSetManager.store(rs);
    }

    /**
     * Clears set for the user.
     * @param paramsIn Map of request parameters you want to forward
     * along with the ActionForward
     * @return The ActionForward to go to next.
     */
    public ActionForward unselectall(Map paramsIn) {

        User user = requestContext.getLoggedInUser();

        this.setDecl.clear(user);
        paramsIn.put("setupdated", "true");
        return strutsDelegate.forwardParams(mapping.findForward(forward), paramsIn);
    }

    /**
     * Get the currentUser
     * @return current User
     */
    public User getUser() {
        return requestContext.getLoggedInUser();
    }


    /**
     * @param forwardIn The forward to set.
     */
    public void setForward(String forwardIn) {
        forward = forwardIn;
    }

}
