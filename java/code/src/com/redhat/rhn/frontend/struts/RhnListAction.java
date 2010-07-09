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

import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.listview.PageControl;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

/**
 * RhnAction base class for all RHN Struts Actions.
 * Used to override Struts functionality as well as
 * add common features to the RHN Struts Actions.
 * @version $Rev$
 */
public class RhnListAction extends RhnAction {

    /**
     * Limit the amount of data displayed on the page
     * @param pc The object which defines what to display
     * @param request The current request
     * @param viewer The logged in user
     */
    public void clampListBounds(PageControl pc, HttpServletRequest request,
                                   User viewer) {
        RequestContext rctx = new RequestContext(request);
        /*
         * Make sure we have a user. If not, something bad happened and we should
         * just bail out with an exception. Since this is probably the result of
         * a bad uid param, throw a BadParameterException.
         */
        if (viewer == null) {
            throw new BadParameterException("Null viewer");
        }

        // if the lower/upper params don't exist, set to 1/user defined
        // respectively
        String lowBound = rctx.processPagination();

        int lower = StringUtil.smartStringToInt(lowBound, 1);
        if (lower <= 1) {
            lower = 1;
        }

        pc.setStart(lower);
        pc.setPageSize(viewer.getPageSize());
        pc.setFilterData(request.getParameter(RequestContext.FILTER_STRING));
    }

    protected List trackSet(RhnSet set, HttpServletRequest request) {

        List newlist = new ArrayList();
        String hiddenvars = request.getParameter("newset");
        String returnvisit = request.getParameter("returnvisit");

        if (returnvisit != null || hiddenvars != null) {
            /**
             * We have been keeping track of newset and should
             * stick with what we've got so far.
             */
            if (hiddenvars != null) {
                hiddenvars = hiddenvars.substring(1, hiddenvars.length() - 1);
                String[] vars = hiddenvars.split(",");
                for (int j = 0; j < vars.length; j++) {
                    newlist.add(vars[j].trim());
                }
            }
        }
        else {
            /**
             * This is the first time we've displayed the set and
             * need to init newset to the set given to us in the tag
             */
            Set setlist = set.getElements();
            Iterator itr = setlist.iterator();
            while (itr.hasNext()) {
                RhnSetElement r = (RhnSetElement) itr.next();
                //check for id combo values
                if (r.getElementTwo() == null) {
                    newlist.add(r.getElement().toString());
                }
                else {
                    newlist.add(r.getElement().toString() + "|" +
                            r.getElementTwo().toString());
                }
            }
        }

        return newlist;
    }
}
