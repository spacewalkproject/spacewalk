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

package com.redhat.rhn.frontend.action.renderers;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import java.util.Collections;

import javax.servlet.http.HttpServletRequest;

/**
 * Renders YourRhn fragment for critical systems
 * 
 * @version $Rev$
 */
public class CriticalSystemsRenderer extends BaseFragmentRenderer {

    private static final String MOST_CRITICAL_LIST = "mostCriticalList";
    private static final String SHOW_CRITICAL_SYSTEMS = "showCriticalSystems";
    private static final String LIST_NAME = "criticalSystems";
    public static final String PAGINATION_MESSAGE = "paginationMessage";

    /**
     * {@inheritDoc}
     */
    protected void render(User user, PageControl pc, HttpServletRequest request) {
        DataResult mcdr = SystemManager.mostCriticalSystems(user, pc);
        
        if (!mcdr.isEmpty()) {
            mcdr = RendererHelper.sortOverviews(mcdr);
        }
        
        mcdr.setElaborationParams(Collections.EMPTY_MAP);
        ListTagHelper.bindSetDeclTo(LIST_NAME, getSetDecl(), request);
        TagHelper.bindElaboratorTo(LIST_NAME, mcdr.getElaborator(), request);
        
        request.setAttribute(MOST_CRITICAL_LIST, mcdr);
        request.setAttribute(SHOW_CRITICAL_SYSTEMS, Boolean.TRUE);
        request.setAttribute(PAGINATION_MESSAGE,
                makePaginationMessage(mcdr.getEnd(), mcdr.getTotalSize(),
                        "yourrhn.jsp.criticalsystems.description"));
        request.setAttribute("parentUrl", request.getRequestURI());
    }
    
    /**
     * Get the RhnSet 'Decl' for the action
     * @return The set decleration
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.SYSTEMS;
    }
    
    /**
     * {@inheritDoc}
     */
    protected String getPageUrl() {
        return "/WEB-INF/pages/common/fragments/yourrhn/mostCriticalSystems.jsp";
    }
}
