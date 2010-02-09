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
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.manager.system.SystemManager;

import java.util.Iterator;

import javax.servlet.http.HttpServletRequest;

/**
 * Renders YourRhn fragment for inactive systems
 * 
 * @version $Rev$
 */
public class InactiveSystemsRenderer extends BaseFragmentRenderer {

    private static final String INACTIVE_SYSTEM_LIST = "inactiveSystemList";
    private static final String INACTIVE_SYSTEMS_EMPTY = "inactiveSystemsEmpty";
    private static final String INACTIVE_SYSTEMS_CLASS = "inactiveSystemsClass";

    /**
     * {@inheritDoc}
     */    
    protected void render(User user, PageControl pc, HttpServletRequest request) {
        LocalizationService ls = LocalizationService.getInstance();
        DataResult isdr = SystemManager.inactiveListSortbyCheckinTime(user, pc);
        String inactiveSystemCSSTable = null;
        if (!isdr.isEmpty()) {
            for (Iterator i = isdr.iterator(); i.hasNext();) {
                SystemOverview so = (SystemOverview) i.next();
                StringBuffer buffer = new StringBuffer();
                Long lastCheckin = so.getLastCheckinDaysAgo();
                if (lastCheckin.compareTo(new Long(1)) < 0) {
                    buffer.append(lastCheckin * 24);
                    buffer.append(' ');

                    buffer.append(ls.getMessage("filter-form.jspf.hours"));
                }
                else if (lastCheckin.compareTo(new Long(7)) < 0) {
                    buffer.append(so.getLastCheckinDaysAgo().longValue());
                    buffer.append(' ');
                    buffer.append(ls.getMessage("filter-form.jspf.days"));
                }
                else if (lastCheckin.compareTo(new Long(7)) >= 0) {
                    buffer.append(lastCheckin.longValue() / 7);
                    buffer.append(' ');
                    buffer.append(ls.getMessage("filter-form.jspf.weeks"));
                }

                so.setLastCheckinString(buffer.toString());
            }
            request.setAttribute(INACTIVE_SYSTEM_LIST, isdr);            
        }
        else {
            inactiveSystemCSSTable = RendererHelper.makeEmptyTable(true, 
                                                       "inactivelist.jsp.header",
                                                       "yourrhn.jsp.noinactivesystems");
            request.setAttribute(INACTIVE_SYSTEMS_EMPTY, inactiveSystemCSSTable);
        }
        RendererHelper.setTableStyle(request, INACTIVE_SYSTEMS_CLASS);

    }
    
    /**
     * {@inheritDoc}
     */    
    protected String getPageUrl() {
        return "/WEB-INF/pages/common/fragments/yourrhn/inactiveSystems.jsp";
    }

}
