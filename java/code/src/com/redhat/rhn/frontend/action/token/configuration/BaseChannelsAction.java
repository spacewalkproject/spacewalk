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

package com.redhat.rhn.frontend.action.token.configuration;

import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;

import javax.servlet.http.HttpServletRequest;


/**
 * @author paji
 * BaseConfigChannelsAction
 * @version $Rev$
 */
public abstract class BaseChannelsAction extends RhnAction {
    private static final String LIST_NAME = "channelsList";
    private static final String DATA_SET = "all";
    private static final String DESCRIPTION = "description";
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
    
    protected void setup(HttpServletRequest request) {
        RequestContext context = new RequestContext(request);
        ActivationKey ak = context.lookupAndBindActivationKey();
        request.setAttribute(DESCRIPTION, ak.getNote());
    }
    /**
     * Returns the parent URL
     * @param context the request context
     * @return the parent url
     */
    public String getParentUrl(RequestContext context) {
        String uri = context.getRequest().getRequestURI();
        return uri + "?" + RequestContext.TOKEN_ID + "=" +
                context.getRequiredParam(RequestContext.TOKEN_ID);
    }
    
    /**
     * Returns the declaration 
     * @param context the request context
     * @return the declaration
     */
    public String getDecl(RequestContext context) {
        return getClass().getName() + 
            context.getRequiredParam(RequestContext.TOKEN_ID);
    }
    
}
