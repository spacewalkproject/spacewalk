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
package com.redhat.rhn.frontend.taglibs;

import com.redhat.rhn.frontend.html.HtmlTag;
import com.redhat.rhn.frontend.struts.RhnAction;

import java.io.IOException;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;


/**
 * SubmittedTag
 * Renders <input type="hidden" name="submitted" value="true"/>
 * @version $Rev$
 */
public class SubmittedTag extends TagSupport {

    public static final String HIDDEN = "hidden";
    public static final String TRUE = Boolean.TRUE.toString();
    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = 940843910953261060L;
    /**
     * {@inheritDoc}
     */
    public int doEndTag() throws JspException {
        HtmlTag input = new HtmlTag("input");
        input.setAttribute("type", HIDDEN);
        input.setAttribute("name", RhnAction.SUBMITTED);
        input.setAttribute("value", TRUE);
        JspWriter writer = pageContext.getOut();
        try {
            writer.write(input.render());
        }
        catch (IOException e) {
            throw new JspException(e);
        }
        return SKIP_BODY;
    }

}
