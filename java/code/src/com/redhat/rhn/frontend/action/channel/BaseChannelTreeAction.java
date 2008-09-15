/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.channel;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.filter.TreeFilter;
import com.redhat.rhn.frontend.listview.ListControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnUnpagedListAction;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * BaseChannelTreeSetupAction
 * @version $Rev$
 */
public abstract class BaseChannelTreeAction extends RhnUnpagedListAction {
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        
            RequestContext requestContext = new RequestContext(request);

            User user = requestContext.getLoggedInUser();
            ListControl lc = new ListControl();

            filterList(lc, request, user);
            lc.setFilter(true);
            lc.setFilterColumn("name");
            lc.setCustomFilter(new TreeFilter());
            DataResult dr = getDataResult(user, lc);
            RhnSet set = RhnSetDecl.CHANNELS_FOR_ERRATA.get(user);

            request.setAttribute("set", set);
            request.setAttribute("pageList", dr);
            return mapping.findForward("default");
        }
    
    protected abstract DataResult getDataResult(User user, ListControl lc);
}
