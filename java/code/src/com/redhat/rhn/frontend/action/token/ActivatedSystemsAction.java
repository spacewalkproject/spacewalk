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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * @author partha
 * ActivatedSystemsAction
 * @version $Rev$
 */
public class ActivatedSystemsAction extends BaseListAction {
    private static final String ACCESS_MAP = "accessMap";
    private static final String DATE_MAP = "dateMap";
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        setup(request);
        ListHelper helper = new ListHelper(this, 
                                        request, getParamsMap(request));
        helper.setDataSetName(getDataSetName());
        helper.setListName(getListName());
        helper.execute();
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }    
    
    /** {@inheritDoc} */
    public List getResult(RequestContext context) {
        ActivationKey key = context.lookupAndBindActivationKey();
        List<Server> servers =  new LinkedList<Server>(
                            key.getToken().getActivatedServers());
        setupMap(context, servers);
        return servers;
    }
    /**
     * Setups the user permissions access map 
     * after checking if the user can access
     * the systems.
     * @param context the request context
     * @param servers list of servers
     */
    private void setupMap(RequestContext context, List <Server> servers) {
        Map<Long, Long> accessMap = new HashMap<Long, Long>();
        Map<Long, String> dateMap = new HashMap<Long, String>();
        LocalizationService ls = LocalizationService.getInstance();
        User user = context.getLoggedInUser();
        for (Server server : servers) {
            if (SystemManager.isAvailableToUser(user, server.getId())) {
                accessMap.put(server.getId(), server.getId());
            }
            dateMap.put(server.getId(), ls.formatDate(server.getLastCheckin()));
        }
        context.getRequest().setAttribute(DATE_MAP, dateMap);
        context.getRequest().setAttribute(ACCESS_MAP, accessMap);
    }
}
