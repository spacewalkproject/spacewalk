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
import com.redhat.rhn.frontend.struts.RequestContext;

import java.io.IOException;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;


/**
 * NoScriptTag
 * @version $Rev$
 */
public class NoScriptTag extends TagSupport {

    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = -7881472783319381518L;
    
    public static final String HIDDEN = "hidden";
    /**
     * {@inheritDoc}
     */
    public int doEndTag() throws JspException {
        HtmlTag input = new HtmlTag("input");
        input.setAttribute("type", HIDDEN);
        input.setAttribute("name", RequestContext.NO_SCRIPT);
        input.setAttribute("value", Boolean.TRUE.toString());
        
        HtmlTag noScript = new HtmlTag("noscript");        
        noScript.addBody(input.render());
        
        JspWriter writer = pageContext.getOut();
        try {
            writer.write(noScript.render());
        }
        catch (IOException e) {
            throw new JspException(e);
        }        
        return SKIP_BODY;
    }
}
