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
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.action.ActionFormatter;

/**
 * ErrataActionFormatter - Class that overrides getNotes()
 * to display Errata specific information.
 *
 * @version $Rev$
 */
public class ScriptActionFormatter extends ActionFormatter {

    /**
     * Create a new ErrataActionFormatter
     * @param actionIn the ErrataAction we want to use to format
     */
    public ScriptActionFormatter(ScriptAction actionIn) {
        super(actionIn);
    }

    /**
     * Output the Errata info into the body.
     * @return String of the Errata HTML
     */
    protected String getNotesBody() {
        StringBuffer retval = new StringBuffer();
        ScriptAction sa = (ScriptAction) getAction();
        retval.append(LocalizationService.getInstance().getMessage("run as"));
        retval.append("<strong>");
        retval.append(sa.getScriptActionDetails().getUsername());
        retval.append(":");
        retval.append(sa.getScriptActionDetails().getGroupname());
        retval.append("</strong><br/><br/>");
        retval.append("<div style=\"padding-left: 1em\"><code>");
        retval.append(StringUtil.htmlifyText(
                      sa.getScriptActionDetails().getScriptContents()));
        retval.append("</code></div><br/>");
        return retval.toString();

    }
}
