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
import com.redhat.rhn.manager.system.SystemManager;

import javax.servlet.http.HttpServletRequest;

/**
 * Renders YourRhn fragment for system groups
 *
 * @version $Rev$
 */
public class SystemGroupsRenderer extends  BaseFragmentRenderer {

    private static final String SYSTEM_GROUP_EMPTY = "systemGroupEmpty";
    private static final String SYSTEM_GROUP_LIST = "systemGroupList";

    /**
     * {@inheritDoc}
     */
    protected void render(User user, PageControl pc, HttpServletRequest request) {
        DataResult sgdr = SystemManager.groupList(user, pc);
        String systemGroupsCSSTable = null;

        if (sgdr.isEmpty()) {
            systemGroupsCSSTable = RendererHelper.makeEmptyTable(false,
                    "yourrhn.jsp.systemgroups.header",
                    "yourrhn.jsp.nogroups");
        }

        request.setAttribute(SYSTEM_GROUP_EMPTY, systemGroupsCSSTable);
        request.setAttribute(SYSTEM_GROUP_LIST, sgdr);
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
    }

    /**
     * {@inheritDoc}
     */
    protected String getPageUrl() {
        return "/WEB-INF/pages/common/fragments/yourrhn/systemGroups.jsp";
    }

}
