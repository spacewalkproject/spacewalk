/**
 * Copyright (c) 2014 SUSE LLC
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
/**
 * Copyright (c) 2014 Red Hat, Inc.
 */
package com.redhat.rhn.frontend.action.renderers;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.directwebremoting.WebContext;
import org.directwebremoting.WebContextFactory;

import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.action.ActionChainFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;

/**
 * Renders a fragment with action chain entries.
 * @author Silvio Moioli {@literal <smoioli@suse.de>}
 */
public class ActionChainEntryRenderer {

    /**
     * Renders Action Chain entries from an Action Chain having a certain sort
     * order number.
     * @param actionChainId Action Chain identifier
     * @param sortOrder sort order number
     * @return a response string
     * @throws ServletException if something goes wrong
     * @throws IOException if something goes wrong
     */
    public String renderAsync(Long actionChainId, Integer sortOrder)
        throws ServletException, IOException {
        WebContext webContext = WebContextFactory.get();
        HttpServletRequest request = webContext.getHttpServletRequest();
        User u = new RequestContext(request).getCurrentUser();

        ActionChain actionChain = ActionChainFactory.getActionChain(u, actionChainId);
        request.setAttribute("sortOrder", sortOrder);
        request.setAttribute("entries",
            ActionChainFactory.getActionChainEntries(actionChain, sortOrder));

        HttpServletResponse response = webContext.getHttpServletResponse();
        return RendererHelper.renderRequest(
            "/WEB-INF/pages/common/fragments/schedule/actionchainentries.jsp", request,
            response);
    }
}
