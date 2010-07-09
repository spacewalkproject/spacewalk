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
import com.redhat.rhn.frontend.action.systems.SystemListHelper;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.system.SystemManager;

import java.util.Iterator;

import javax.servlet.http.HttpServletRequest;

/**
 * Renders YourRhn fragment for recent systems
 *
 * @version $Rev$
 */
public class RecentSystemsRenderer extends BaseFragmentRenderer {

    public static final String RECENTLY_REGISTERED_EMPTY = "recentlyRegisteredEmpty";
    public static final String RECENTLY_REGISTERED_SYSTEMS_LIST =
       "recentlyRegisteredSystemsList";
    public static final String SHOW_RECENTLY_REGISTERED_SYSTEMS =
       "showRecentlyRegisteredSystems";
    public static final String PAGINATION_MESSAGE = "paginationMessage";

    /**
     * {@inheritDoc}
     */
    protected void render(User user, PageControl pc, HttpServletRequest request) {
        DataResult rdr = SystemManager.registeredList(user, pc, 30);
        String registeredSystemsCSSTable = null;

        Iterator i = rdr.iterator();
        while (i.hasNext()) {
            SystemOverview next = (SystemOverview) i.next();
            SystemListHelper.setSystemStatusDisplay(user, next);
        }

        request.setAttribute(RECENTLY_REGISTERED_EMPTY, registeredSystemsCSSTable);
        request.setAttribute(RECENTLY_REGISTERED_SYSTEMS_LIST, rdr);
        request.setAttribute(SHOW_RECENTLY_REGISTERED_SYSTEMS, Boolean.TRUE);
        request.setAttribute(PAGINATION_MESSAGE,
                    makePaginationMessage(rdr.getEnd(), rdr.getTotalSize(),
                            "yourrhn.jsp.recentlyregistered.description"));
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
    }

    protected String getPageUrl() {
        return "/WEB-INF/pages/common/fragments/yourrhn/recentlyRegistered.jsp";
    }

}
