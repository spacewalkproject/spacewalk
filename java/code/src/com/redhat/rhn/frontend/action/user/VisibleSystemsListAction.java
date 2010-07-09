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
package com.redhat.rhn.frontend.action.user;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.dto.BaseDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Iterator;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * VisibleSystemsListAction
 * This is the main action class for ssm. LookupDispatchAction class
 * looks for "dispatch" in the request.
 * @version $Rev: 1790 $
 */
public class VisibleSystemsListAction extends RhnSetAction {

    /**
     * Normally the select all should clear the set and replace it with
     * the current dataresult.  However, we are touching the SSM here, and
     * therefore it would be nice to simply add to the set everything in the
     * dataresult.
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

        User user = new RequestContext(request).getLoggedInUser();

        //Get a DataResult containing all of the user's systems
        DataResult dr = getDataResult(user, formIn, request);

        //Get the old set
        RhnSet rs = getSetDecl().get(user);

        /*
         * Loop through all items in the DataResult and
         * add each item to the set.
         */
        Iterator itr = dr.iterator();
        while (itr.hasNext()) {
            BaseDto dto = (BaseDto) itr.next();
            if (dto.isSelectable()) {
                dto.addToSet(rs);
            }
        }

        RhnSetManager.store(rs);
        Map params = makeParamMap(formIn, request);
        return getStrutsDelegate().forwardParams(mapping.findForward("default"), params);
    }

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User user,
                                       ActionForm formIn,
                                       HttpServletRequest request) {
        //user is logged in user, but we care about target user
        Long uid = new RequestContext(request).getRequiredParam("uid");
        User targetUser = UserManager.lookupUser(user, uid);
        DataResult dr = UserManager.visibleSystems(targetUser);
        return dr;
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        // no op
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm formIn,
                                   HttpServletRequest request,
                                   Map params) {
        params.put("uid", new RequestContext(request).getParamAsLong("uid"));
    }

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.SYSTEMS;
    }
}
