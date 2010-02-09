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

import org.apache.struts.Globals;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;

/**
 * Tag to display messages to the end user.  Tag syntax follows:
 * <pre>
 * &lt;rhn:messages&gt;
 *     &lt;c:out escapeXml="false" value="${message}" /&gt;
 * &lt;/rhn:messages&gt;
 * </pre>
 * @version $Rev$
 */
public class MessagesTag extends TagSupport {
    private HtmlTag baseTag;
    
    /** {@inheritDoc} 
     * @throws JspException
     */
    public int doStartTag() throws JspException {
        JspWriter out = null;
        try {
            out = pageContext.getOut();
            
            // For now, hard-code the site-info class.  If we want to abstract
            // this later, we can.
            baseTag = new HtmlTag("div");
            baseTag.setAttribute("class", "site-info");
            
            out.print(baseTag.renderOpenTag());
            return (EVAL_BODY_INCLUDE);
        }
        catch (Exception e) {
            throw new JspException("Error writing to JSP file:", e);
        }
    }
    
    /**
     * {@inheritDoc}
     */
    public int doEndTag() throws JspException {
        JspWriter out = null;
        try {
            out = pageContext.getOut();
            out.print(baseTag.renderCloseTag());
            removeMessagesFromSession(out);
            return (EVAL_PAGE);
        }
        catch (Exception e) {
            throw new JspException("Error writing to JSP file:", e);
        }
    }
    
    private void removeMessagesFromSession(JspWriter out) {
        HttpServletRequest request = (HttpServletRequest)pageContext.getRequest();
        HttpSession session = request.getSession();
        session.removeAttribute(Globals.MESSAGE_KEY);
    }

    /**
     * {@inheritDoc}
     */
    public void release() {
        baseTag = null;
        super.release();
    }
}
