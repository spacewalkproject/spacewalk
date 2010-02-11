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
package com.redhat.rhn.frontend.action.kickstart.cobbler;

import com.redhat.rhn.common.util.DynamicComparator;
import com.redhat.rhn.domain.kickstart.cobbler.CobblerSnippet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerSnippetLister;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Collections;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * CobblerSnippetListSetupAction : class to list cobbler snippets
 * @version $Rev: 1 $
 */
public class CobblerSnippetListSetupAction extends RhnAction {
    private static final String DEFAULT = "default";
    private static final String CUSTOM = "custom";
    private static final String ALL = "all";
    
    private static final DynamicComparator NAME_COMPARATOR = 
                new DynamicComparator("name", true); 
    /**
     * ${@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form, 
            HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        request.setAttribute(mapping.getParameter(), Boolean.TRUE);
        RequestContext context = new RequestContext(request);
        User user = context.getLoggedInUser();
        List<CobblerSnippet> result;
        if (ALL.equals(mapping.getParameter())) {
            result = CobblerSnippetLister.getInstance().list(user); 
        }
        else if (DEFAULT.equals(mapping.getParameter())) {
            result = CobblerSnippetLister.getInstance().listDefault(user);
        }
        else if (CUSTOM.equals(mapping.getParameter())) {
            result = CobblerSnippetLister.getInstance().listCustom(user);
        }
        else {
            throw new BadParameterException("Invalid mapping parameter passed!! [" +
                                                    mapping.getParameter() + "]");
        }
        Collections.sort(result, NAME_COMPARATOR);
        request.setAttribute("pageList", result);
        request.setAttribute("parentUrl", request.getRequestURI());
        return mapping.findForward("default");
    }

}
