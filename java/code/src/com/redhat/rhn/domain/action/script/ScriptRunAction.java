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
package com.redhat.rhn.domain.action.script;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.server.Server;

import org.apache.commons.lang.StringEscapeUtils;


/**
 * ScriptRunAction
 * @version $Rev$
 */
public class ScriptRunAction extends ScriptAction {

    /**
     * {@inheritDoc}
     */
    @Override
    public String getHistoryDetails(Server server) {
        LocalizationService ls = LocalizationService.getInstance();
        StringBuilder retval = new StringBuilder();
        retval.append("</br>");
        retval.append(ls.getMessage("system.event.runAs",
                StringEscapeUtils.escapeHtml(getScriptActionDetails().getUsername()),
                StringEscapeUtils.escapeHtml(getScriptActionDetails().getGroupname()))
        );
        retval.append("</br>");
        retval.append(ls.getMessage("system.event.timeout",
                getScriptActionDetails().getTimeout()));
        retval.append("</br>");
        retval.append(ls.getMessage("system.event.scriptContents"));
        retval.append("</br><pre>");
        retval.append(StringEscapeUtils.escapeHtml(getScriptActionDetails()
                .getScriptContents()));
        retval.append("</pre></br>");
        for (ScriptResult sr : getScriptActionDetails().getResults()) {
            retval.append(ls.getMessage("system.event.scriptStart", sr.getStartDate()));
            retval.append("</br>");
            retval.append(ls.getMessage("system.event.scriptEnd", sr.getStopDate()));
            retval.append("</br>");
            retval.append(ls.getMessage("system.event.scriptReturnCode",
                    sr.getReturnCode().toString()));
            retval.append("</br>");
            retval.append(ls.getMessage("system.event.scriptRawOutput"));
            retval.append("<a href=\"/network/systems/details/history/raw_script_output" +
                    ".txt?hid=" + this.getId() + "&sid=" + server.getId() + "\">");
            retval.append(ls.getMessage("system.event.downloadRawOutput"));
            retval.append("</a>");
            retval.append("</br>");
            retval.append(ls.getMessage("system.event.scriptFilteredOutput"));
            retval.append("</br>");
            retval.append("<pre>");
            retval.append(StringEscapeUtils.escapeHtml(sr.getOutputContents()));
            retval.append("</pre>");
        }
        return retval.toString();
    }

}
