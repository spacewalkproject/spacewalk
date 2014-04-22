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
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFormatter;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.frontend.html.HtmlTag;

import java.util.HashSet;
import java.util.Set;

/**
 * ConfigAction - Class representation of the table rhnAction.
 * @version $Rev$
 */
public class ConfigAction extends Action {

    private Set <ConfigRevisionAction> configRevisionActions;

    /**
     * @return Returns the configRevisionActions.
     */
    public Set<ConfigRevisionAction> getConfigRevisionActions() {
        return configRevisionActions;
    }
    /**
     * @param configRevisionActionsIn The configRevisionActions to set.
     */
    public void setConfigRevisionActions(Set<ConfigRevisionAction>
                                            configRevisionActionsIn) {
        this.configRevisionActions = configRevisionActionsIn;
    }

    /**
     * Add a ConfigRevisionAction to the collection.
     * @param crIn the ConfigRevisionAction to add
     */
    public void addConfigRevisionAction(ConfigRevisionAction crIn) {
        if (configRevisionActions == null) {
            configRevisionActions = new HashSet();
        }
        crIn.setParentAction(this);
        configRevisionActions.add(crIn);
    }

    /**
     * Get the Formatter for this class but in this case we use
     * ConfigActionFormatter.
     *
     * {@inheritDoc}
     */
    public ActionFormatter getFormatter() {
        if (formatter == null) {
            formatter = new ConfigActionFormatter(this);
        }
        return formatter;
    }

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
                    server.getId().toString() + "&crid=" + rev.getId());
            a.addBody(rev.getConfigRevision()
                    .getConfigFile().getConfigFileName().getPath());
            retval.append(a.render());
            retval.append(" (rev. " + rev.getConfigRevision().getRevision() + ")");
            retval.append("</br>");
        }
        return retval.toString();
    }

}
