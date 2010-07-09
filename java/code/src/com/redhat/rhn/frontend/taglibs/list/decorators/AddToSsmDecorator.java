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
package com.redhat.rhn.frontend.taglibs.list.decorators;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.frontend.html.HtmlTag;
import com.redhat.rhn.frontend.taglibs.ListDisplayTag;
import com.redhat.rhn.frontend.taglibs.list.ListTagUtil;

import javax.servlet.jsp.JspException;

/**
 * Decorator to tie into ListTag 3.0 to provide an easy means to add te selected servers
 * in a table to the SSM.
 * <p/>
 * This decorator must be used in conjunction with the {@link SelectableDecorator}.
 *
 * @version $Revision$
 */
public class AddToSsmDecorator extends BaseListDecorator {

    /**
     * Name of the checkbox allowing the user to clear all servers in the SSM before adding
     * the selected ones.
     */
    public static final String PARAM_CLEAR_SSM = "clear-ssm-first";

    /** {@inheritDoc} */
    public void afterList() throws JspException {
        if (!currentList.isEmpty()) {

            // Collect the values needed to hook into the rest of the list tag framework
            String buttonName = ListTagUtil.makeSelectActionName(listName);

            LocalizationService ls = LocalizationService.getInstance();
            String value = ls.getMessage(ListDisplayTag.ADD_TO_SSM_KEY);

            String clearText = ls.getMessage("Clear SSM");

            // Generate the HTML to output
            StringBuffer buf = new StringBuffer();
            buf.append("<span class=\"list-selection-buttons\">");

            //   Add to SSM button
            HtmlTag tag = new HtmlTag("input");
            tag.setAttribute("type", "submit");
            tag.setAttribute("name", buttonName);
            tag.setAttribute("value", value);
            buf.append(tag.render()).append("&nbsp;");

            //   Checkbox for whether or not to clear the existing SSM servers
            tag = new HtmlTag("input");
            tag.setAttribute("type", "checkbox");
            tag.setAttribute("name", PARAM_CLEAR_SSM);
            buf.append(tag.render()).append(clearText).append("&nbsp;");

            buf.append("</span>");
            ListTagUtil.write(pageContext, buf.toString());
        }
    }
}
