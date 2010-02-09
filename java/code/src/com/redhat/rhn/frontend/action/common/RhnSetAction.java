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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RhnListDispatchAction;
import com.redhat.rhn.frontend.struts.RhnSetHelper;
import com.redhat.rhn.frontend.taglibs.ListDisplayTag;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * RhnSetAction
 * 
 * <br/><br/>
 * 
 * <strong>NOTE:</strong> RhnSetAction and RhnAction contain two duplicate methods -
 * <code>getStrutsDelegate()</code> and <code>createSuccessMessage()</code>. If another
 * method is added to these classes that is common to both we need to refactor the common
 * methods into a new class maybe called <code>RhnActionDelegate</code>.
 * 
 * <br/><br/>
 * 
 * We cannot introduce a common base class because RhnSetAction and RhnAction fall into
 * different inheritance hierarchies. 
 *  
 * @version $Rev$
 * @see com.redhat.rhn.frontend.struts.RhnAction
 */
public abstract class RhnSetAction extends RhnListDispatchAction {
    
    /**
     * Updates RhnSet with checked set elements
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward updatelist(ActionMapping mapping,
                                    ActionForm formIn,
                                    HttpServletRequest request,
                                    HttpServletResponse response) {
        Map params = makeParamMap(formIn, request);
        RhnSetHelper helper = new RhnSetHelper(mapping, getSetDecl(), request);
        helper.setForward(getForwardName(request));
        return helper.updatelist(params);
    }

    /**
     * Updates the set with the items on the current page
     * @param request The request containing items_on_page and items_selected
     * @return the newly updated set
     */
    protected RhnSet updateSet(HttpServletRequest request) {
        RhnSetHelper helper = new RhnSetHelper(getSetDecl(), request);
        helper.setForward(getForwardName(request));
        return helper.updateSet();
    }

    /**
     * Puts all systems visible to the user into the system_list set.
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward selectall(ActionMapping mapping,
                                   ActionForm formIn,
                                   HttpServletRequest request,
                                   HttpServletResponse response) {
        Map params = makeParamMap(formIn, request);
        RhnSetHelper helper = new RhnSetHelper(mapping, getSetDecl(), request);
        helper.setForward(getForwardName(request));
        DataResult dr = getDataResult(helper.getUser(), formIn, request);
        return helper.selectall(dr, params);
    }

    /**
     * Clears system_list set for the user.
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward unselectall(ActionMapping mapping,
                                     ActionForm formIn,
                                     HttpServletRequest request,
                                     HttpServletResponse response) {
        Map params = makeParamMap(formIn, request);
        RhnSetHelper helper = new RhnSetHelper(mapping, getSetDecl(), request);
        helper.setForward(getForwardName(request));
        return helper.unselectall(params);
    }

    /**
     * Default action to execute if dispatch parameter is missing
     * or isn't in map
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward unspecified(ActionMapping mapping,
                                     ActionForm formIn,
                                     HttpServletRequest request,
                                     HttpServletResponse response) {
        ActionForward forward = super.unspecified(mapping, formIn, request, response);
        updateSet(request);
        return forward;
    }

    /**
     * {@inheritDoc}
     */
    protected Map getKeyMethodMap() {
        Map map = super.getKeyMethodMap();
        map.put(ListDisplayTag.UPDATE_LIST_KEY, "updatelist");
        map.put(ListDisplayTag.SELECT_ALL_KEY, "selectall");
        map.put(ListDisplayTag.UNSELECT_ALL_KEY, "unselectall");
        return map;
    }

    /**
     * The declaration of the set we are working with, must be one of the
     * constants from {@link RhnSetDecl}
     * @return the declaration of the set we are working with
     */
    protected abstract RhnSetDecl getSetDecl();

    protected final String getSetName() { throw new UnsupportedOperationException(); }

    protected abstract DataResult getDataResult(User user,
            ActionForm formIn, HttpServletRequest request);

}
