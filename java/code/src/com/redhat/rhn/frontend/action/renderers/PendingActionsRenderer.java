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
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ScheduledAction;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.manager.action.ActionManager;

import java.util.Iterator;

import javax.servlet.http.HttpServletRequest;

/**
 * Renders YourRhn fragment for pending actions
 *
 * @version $Rev$
 */
public class PendingActionsRenderer extends BaseFragmentRenderer {

    private static final String SCHEDULED_ACTION_EMPTY = "scheduledActionEmpty";
    private static final String SCHEDULED_ACTION_LIST = "scheduledActionList";
    private static final String SCHEDULED_SHOW_LIST = "showPendingActions";
    /**
     * {@inheritDoc}
     */
    protected void render(User user, PageControl pc, HttpServletRequest request) {
        LocalizationService ls = LocalizationService.getInstance();
        String pendingActionsCSSTable = null;
        DataResult padr = ActionManager.recentlyScheduledActions(user, pc, 30);
        for (Iterator i = padr.iterator(); i.hasNext();) {
            StringBuffer buffer = new StringBuffer();
            ScheduledAction sa = (ScheduledAction) i.next();

            Action action = ActionManager.lookupAction(user, sa.getId());

            User schedulerUser = action.getSchedulerUser();
            if (schedulerUser == null) {
                sa.setUserName("");
            }
            else {
                sa.setUserName(schedulerUser.getLogin());
            }

            long hoursSinceCreation = System.currentTimeMillis() -
                     action.getCreated().getTime();
            hoursSinceCreation /= 3600000;
            if (hoursSinceCreation > 24) {
                buffer.append(hoursSinceCreation / 24);
                buffer.append(' ');
                buffer.append(ls.getMessage("filter-form.jspf.days"));
            }
            else {
                buffer.append(hoursSinceCreation);
                buffer.append(' ');
                buffer.append(ls.getMessage("filter-form.jspf.hours"));
            }
            sa.setAgeString(buffer.toString());

        }

        if (padr.isEmpty()) {
            pendingActionsCSSTable = RendererHelper.makeEmptyTable(false,
                        "yourrhn.jsp.scheduledactions",
                        "yourrhn.jsp.noactions");

        }

        request.setAttribute(SCHEDULED_ACTION_EMPTY, pendingActionsCSSTable);
        request.setAttribute(SCHEDULED_ACTION_LIST, padr);
        request.setAttribute(SCHEDULED_SHOW_LIST, Boolean.TRUE);
    }

    /**
     * {@inheritDoc}
     */
    protected String getPageUrl() {
        return "/WEB-INF/pages/common/fragments/yourrhn/scheduledActions.jsp";
    }
}
