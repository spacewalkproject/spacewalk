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
import com.redhat.rhn.frontend.taglibs.list.ListTagUtil;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import javax.servlet.jsp.JspException;

/**
 *
 * Decorator used to add an extra button to the right of 'select all'
 * @version $Revision$
 */
public class ExtraButtonDecorator extends BaseListDecorator {

    public static final String EXTRA_BUTTON = "extrabutton";



    /** {@inheritDoc} */
    public void afterList() throws JspException {

        // Collect the values needed to hook into the rest of the list tag framework
        String buttonName = ListTagUtil.makeExtraButtonName(listName);

        String msg = (String) pageContext.getRequest().getAttribute(
                ListTagUtil.makeExtraButtonName(listName));
        if (StringUtils.isEmpty(msg)) {
            Logger.getLogger(this.getClass()).error("Please add the Extra Button" +
                " attribute to the request");
            msg = "Missing extra button attribute";
        }
        LocalizationService ls = LocalizationService.getInstance();
        String value = ls.getMessage(msg);


        StringBuffer buf = new StringBuffer();
        //   Add to SSM button
        HtmlTag tag = new HtmlTag("input");
        tag.setAttribute("type", "submit");
        tag.setAttribute("name", buttonName);
        tag.setAttribute("value", value);
        buf.append(tag.render()).append("&nbsp;");

        ListTagUtil.write(pageContext, buf.toString());

    }
}
