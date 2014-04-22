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
package com.redhat.rhn.domain.action.config;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.frontend.html.HtmlTag;

/**
 * ConfigVerifyAction - Class representing TYPE_CONFIGFILES_VERIFY
 * @version $Rev$
 */
public class ConfigVerifyAction extends ConfigAction {

    /**
     * {@inheritDoc}
     */
    @Override
    public String getHistoryDetails(Server server) {
        LocalizationService ls = LocalizationService.getInstance();
        StringBuilder retval = new StringBuilder();
        retval.append("</br>");
        retval.append(ls.getMessage("system.event.configFiles"));
        retval.append("</br>");
        for (ConfigRevisionAction rev : this.getConfigRevisionActions()) {
            HtmlTag a = new HtmlTag("a");
            a.setAttribute("href",
                    "/rhn/configuration/file/FileDetails.do?sid=" +
                    server.getId() + "&crid=" +
                    rev.getConfigRevision().getConfigFile().getId());
            a.addBody(rev.getConfigRevision()
                    .getConfigFile().getConfigFileName().getPath());
            retval.append(a.render());
            retval.append(" (rev. " + rev.getConfigRevision().getRevision() + ")");

            if (rev.getConfigRevisionActionResult() != null) {
                a.setAttribute("href",
                        "/rhn/systems/details/configuration/ViewDiffResult.do?sid=" +
                        server.getId() + "&acrid=" +
                        rev.getConfigRevisionActionResult()
                        .getConfigRevisionAction().getId());
                a.setBody(ls.getMessage("system.event.configFiesDiffExist"));
                retval.append(" ");
                retval.append(a.render());
            }
            if (rev.getFailureId() != null) {
                retval.append(" ");
                retval.append(ls.getMessage("system.event.configFiesMissing"));
            }

            retval.append("</br>");
        }
        return retval.toString();
    }

}
