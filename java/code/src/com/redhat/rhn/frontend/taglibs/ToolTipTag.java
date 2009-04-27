/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.frontend.html.HtmlTag;

import org.apache.commons.lang.StringUtils;

import java.io.IOException;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;


/**
 * ToolTip
 * Renders <span class="small-text"><strong>Tip:</strong>Take Vacations.</span> 
 * @version $Rev$
 */
public class ToolTipTag extends TagSupport {

    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = 7202597580376186072L;

    private String key;
    private String text;
    
    /**
     * Sets the key
     * @param k the i18n key to set
     */
    public void setKey(String k) {
        key = k;
    }
    
    /**
     * Sets the text to render...
     * @param txt the text..
     */
    public void setText(String txt) {
        text = txt;
    }
    
    /**
     * {@inheritDoc}
     */
    @Override
    public int doStartTag() throws JspException {
        LocalizationService ls = LocalizationService.getInstance();
        HtmlTag strong = new HtmlTag("strong");
        strong.addBody(ls.getMessage(geTypeKey()) + ": ");

        JspWriter writer = pageContext.getOut();
        try {
            writer.write("<span class=\"small-text\">");
            writer.write(strong.render());
            if (!StringUtils.isBlank(key)) {
                writer.write(ls.getMessage(key));
            }
            return EVAL_BODY_INCLUDE;
        }
        catch (IOException e) {
            throw new JspException(e);
        }        
        
    }
    
    protected String geTypeKey() {
        return "Tip"; 
    }
    
    /**
     * {@inheritDoc}
     */
    public int doEndTag() throws JspException {
        JspWriter writer = pageContext.getOut();
        try {
            writer.write("</span>");
        }
        catch (IOException e) {
            throw new JspException(e);
        }        
        return SKIP_BODY;
    }
}
