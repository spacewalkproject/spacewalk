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
package com.redhat.rhn.frontend.action.configuration.ssm;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * For ssm config channel subscriptions.
 * @version $Rev$
 */
public class SubscribeSetup extends RhnListAction {
    
    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        
        User user = requestContext.getLoggedInUser();
        PageControl pc = new PageControl();
        clampListBounds(pc, request, user);
        pc.setFilter(true);
        pc.setFilterColumn("name");
        
        DataResult dr = getDataResult(user, pc);
        request.setAttribute(RequestContext.PAGE_LIST, dr);
        
        if (!isSubmitted((DynaActionForm) formIn)) {
            getSetDecl().clear(user);
        }
        
        RhnSet set = getSetDecl().get(user);
        request.setAttribute("set", set);
        request.setAttribute("newset", trackSet(set, request));
        
        Map params = request.getParameterMap();
        return getStrutsDelegate().forwardParams(
                mapping.findForward(RhnHelper.DEFAULT_FORWARD), params);
    }
    
    private RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_CHANNELS_RANKING;
    }

    private DataResult getDataResult(User user, PageControl pc) {
        ConfigurationManager cm = ConfigurationManager.getInstance();
        return cm.ssmChannelListForSubscribe(user, pc);
    }
}
