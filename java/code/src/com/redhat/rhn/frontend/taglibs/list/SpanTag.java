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

package com.redhat.rhn.frontend.taglibs.list;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.TagSupport;

/**
 * Renders headers or footers for a list
 * The class name derives from the fact that headers and footers
 * _span_ columsn when they are displayed
 *
 * @version $Rev $
 */
public class SpanTag extends TagSupport {

    private static final long serialVersionUID = -4119626049333137991L;

    private String style;
    private String url;
    private String align;
    private String role = "header";

    /**
     * Sets the role of the span, either "header" or "footer"
     * @param roleIn role of the span
     * @throws JspException if something else is used
     */
    public void setRole(String roleIn) throws JspException {
        if (!roleIn.equals("header") && !role.equals("footer")) {
            throw new JspException("span role must be either \"header\" or \"footer\"");
        }
        role = roleIn;
    }

    /**
     * Sets the CSS style class
     * @param styleIn CSS class
     */
    public void setStyleclass(String styleIn) {
        style = styleIn;
    }

    /**
     * Sets the URL to use to fetch the content
     * @param urlIn url pointing to header/footer content
     */
    public void setUrl(String urlIn) {
        url = urlIn;
    }

    /**
     * Sets the alignment
     * @param alignIn  either "left", "right", or "center"
     */
    public void setAlign(String alignIn) {
        align = alignIn;
    }

    /**
     * ${@inheritDoc}
     */
    public void release() {
        style = null;
        url = null;
        align = null;
        role = "header";
        super.release();
    }

    /**
     * ${@inheritDoc}
     */
    public int doEndTag() throws JspException {
        ListCommand cmd = ListTagUtil.getCurrentCommand(this, pageContext);
        ListTag parent = (ListTag) TagSupport.findAncestorWithClass(this, ListTag.class);
        if (cmd.equals(ListCommand.TBL_HEADER) && role.equals("header")) {
            renderHeader(parent);
        }
        else if (cmd.equals(ListCommand.TBL_FOOTER) && role.equals("footer")) {
            renderFooter(parent);
        }
        return TagSupport.EVAL_PAGE;
    }

    private void renderHeader(ListTag parent) throws JspException {
        StringBuffer buf = new StringBuffer();
        renderCommonAttributes(buf, parent);
        ListTagUtil.write(pageContext, buf.toString());
        ListTagUtil.includeContent(pageContext, url);
        ListTagUtil.write(pageContext, "</td></tr>");
    }

    private void renderFooter(ListTag parent) throws JspException {
        StringBuffer buf = new StringBuffer();
        buf.append("<tr>");
        renderCommonAttributes(buf, parent);
        ListTagUtil.write(pageContext, buf.toString());
        ListTagUtil.includeContent(pageContext, url);
        ListTagUtil.write(pageContext, "</td></tr>");
    }

    private void renderCommonAttributes(StringBuffer buf, ListTag parent) {
        buf.append("<tr><td ");
        buf.append("colspan=\"").append(parent.getColumnCount()).append("\"");
        if (style != null) {
            buf.append(" class=\"").append(style).append("\"");
        }
        if (align != null) {
            buf.append(" align=\"").append(align).append("\"");
        }
        buf.append(">");
    }
}
