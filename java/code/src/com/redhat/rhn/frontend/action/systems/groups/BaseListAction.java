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

package com.redhat.rhn.frontend.action.systems.groups;

import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.systems.sdc.SdcHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;

import javax.servlet.http.HttpServletRequest;


/**
 * @author paji
 * BaseListAction
 * @version $Rev$
 */
public abstract class BaseListAction extends RhnAction {
    private static final String LIST_NAME = "list";
    private static final String DATA_SET = "all";
    /**
     *  the dataset name
     * @return dataset name
     */
    public String getDataSetName() {
        return DATA_SET;
    }

    /**
     * Returns list name
     * @return the list name
     */
    public String getListName() {
        return LIST_NAME;
    }

    /**
     * Returns the parent URL
     * @param context the request context
     * @return the parent url
     */
    public String getParentUrl(RequestContext context) {
        String uri = context.getRequest().getRequestURI();
        return uri + "?" + RequestContext.SID + "=" +
                context.getRequiredParam(RequestContext.SID);
    }

    /**
     * Returns the declaration
     * @param context the request context
     * @return the declaration
     */
    public String getDecl(RequestContext context) {
        return getClass().getName() +
            context.getRequiredParam(RequestContext.SID);
    }

    /**
     * Adds server info
     * @param request the servlet request.
     */
    public static void setup(HttpServletRequest request) {
        RequestContext context = new RequestContext(request);
        Server server = context.lookupAndBindServer();
        User user = context.getLoggedInUser();
        SdcHelper.ssmCheck(request, server.getId(), user);

    }
}
