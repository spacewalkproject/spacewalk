/**
 * Copyright (c) 2009--2017 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.systems;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.SystemCurrency;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.dto.VirtualSystemOverview;
import com.redhat.rhn.frontend.html.HtmlTag;
import com.redhat.rhn.frontend.taglibs.IconTag;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * SystemListHelper - helper class with some list display functions
 * @version $Rev$
 */
public class SystemListHelper {

    private SystemListHelper() {
    }

    /**
     * Sets up the HTML tags (image and link) by computing the status from the
     * SystemOverview DTO. This method chains to {@link #setSystemStatusDisplay(User,
     * SystemOverview, boolean)} and defaults to display links.
     *
     * @param user used in entitlement calculation
     * @param next row used to populate the HTML tags
     */
    public static void setSystemStatusDisplay(User user, SystemOverview next) {
        setSystemStatusDisplay(user, next, true);
    }

    /**
     * Sets up the HTML tags (image and potentially link) by computing the status from the
     * SystemOverview DTO.
     *
     * @param user      used to calc some entitlement info
     * @param next      row used to populate html tags
     * @param makeLinks indicates if the icons should be rendered as links to other pages
     */
    public static void setSystemStatusDisplay(User user, SystemOverview next,
                                              boolean makeLinks) {
        HtmlTag url = new HtmlTag("a");
        IconTag i = new IconTag();

        if (next instanceof VirtualSystemOverview) {
            VirtualSystemOverview vso = (VirtualSystemOverview)next;
            if (vso.getSystemId() != null) {
                vso.setId(vso.getSystemId());
            }
        }

        if (next.getEntitlement() == null ||
            next.getEntitlement().isEmpty()) {
            i.setType("system-unknown");
            i.setTitle("systemlist.jsp.unentitled");
            if (user.hasRole(RoleFactory.ORG_ADMIN)) {
                url.setAttribute("href", "/rhn/systems/details/Edit.do?sid=" +
                    next.getId());
            }
        }
        else if (checkinOverdue(next)) {
            //status = "awol"
            i.setType("system-unknown");
            i.setTitle("systemlist.jsp.notcheckingin");
        }
        else if (SystemManager.isKickstarting(user, next.getId())) {
            //status = "kickstarting";
            url.setAttribute("href",
                    "/rhn/systems/details/kickstart/SessionStatus.do?sid=" +
                    next.getId());
            i.setType("system-kickstarting");
            i.setTitle("systemlist.jsp.kickstart");
        }
        else if (next.getEnhancementErrata() + next.getBugErrata() +
                     next.getSecurityErrata() > 0 &&
                     !SystemManager.hasUnscheduledErrata(user, next.getId())) {
            //status = "updates scheduled";
            url.setAttribute("href",
                    "/rhn/systems/details/history/Pending.do?sid=" +
                    next.getId());
            i.setType("action-pending");
            i.setTitle("systemlist.jsp.updatesscheduled");
        }
        else if (SystemManager.countActions(next.getId()) > 0) {
            //status = "actions scheduled";
            url.setAttribute("href",
                    "/rhn/systems/details/history/Pending.do?sid=" +
                    next.getId());
            i.setType("action-pending");
            i.setTitle("systemlist.jsp.actionsscheduled");
        }
        else if ((next.getEnhancementErrata() == null ||
                  next.getEnhancementErrata() == 0) &&
                 next.getBugErrata() == 0 &&
                 next.getSecurityErrata() == 0 &&
                 next.getOutdatedPackages() == 0 &&
                 SystemManager.countPackageActions(next.getId()) == 0) {

            //status = "up2date";
            i.setType("system-ok");
            i.setTitle("systemlist.jsp.up2date");
        }
        else if (next.getSecurityErrata() > 0) {
            //status = "critical";
            url.setAttribute("href",
                    "/rhn/systems/details/ErrataList.do?sid=" +
                    next.getId() + "&type=" +
                    LocalizationService.getInstance().getMessage(ErrataSetupAction.SECUR));
            i.setType("system-crit");
            i.setTitle("systemlist.jsp.critical");
        }
        else if (next.getOutdatedPackages() > 0) {
            //status = "updates";
            url.setAttribute("href",
                    "/rhn/systems/details/packages/UpgradableList.do?sid=" +
                    next.getId());
            i.setType("system-warn");
            i.setTitle("systemlist.jsp.updates");
        }

        String statusDisplay;

        if (makeLinks) {
            url.addBody(i.render());
            statusDisplay = url.render();
        }
        else {
            statusDisplay = i.render();
        }

        if (next.getLocked().intValue() == 1) {
            IconTag lockedIcon = new IconTag("system-locked", "systemlist.jsp.locked");
            statusDisplay = statusDisplay + lockedIcon.render();
        }

        next.setStatusDisplay(statusDisplay);

    }

    /**
     * Sets up the HTML tags (image and potentially link) by computing the status from the
     * SystemCurrency DTO.
     *
     * @param user      used to calc some entitlement info
     * @param next      row used to populate html tags
     * @param makeLinks indicates if the icons should be rendered as links to other pages
     */
    public static void setSystemStatusDisplay(User user, SystemCurrency next,
                                              boolean makeLinks) {

        HtmlTag url = new HtmlTag("a");
        HtmlTag img = new HtmlTag("img");

        url.addBody(img);
        String statusDisplay;

        if (makeLinks) {
            statusDisplay = url.render();
        }
        else {
            statusDisplay = img.render();
        }
        next.setStatusDisplay(statusDisplay);

    }

    private static boolean checkinOverdue(SystemOverview systemData) {
        Long threshold = new Long(Config.get().getInt(
                ConfigDefaults.SYSTEM_CHECKIN_THRESHOLD));

        return systemData.getLastCheckinDaysAgo() != null &&
                systemData.getLastCheckinDaysAgo().compareTo(threshold) > 0;
    }

}
