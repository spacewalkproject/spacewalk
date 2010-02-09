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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.frontend.html.HtmlTag;

import org.apache.commons.lang.StringUtils;

import java.io.IOException;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;


/**
 * RequiredField
 * @version $Rev$
 */
public class RequiredFieldTag extends TagSupport {

    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = 8799773902565544104L;

    public static final String REQUIRED_FIELD_CSS =  "required-form-field";
    private String key;
    
    /**
     * Sets the key
     * @param k the i18n key to set
     */
    public void setKey(String k) {
        key = k;
    }
    
    /**
     * {@inheritDoc}
     */
    @Override
    public int doStartTag() throws JspException {
        // <bean:message key="cobbler.snippet.name"/>
        // <span class="required-form-field">*</span>
        LocalizationService ls = LocalizationService.getInstance();
        JspWriter writer = pageContext.getOut();
        try {
            if (!StringUtils.isBlank(key)) {
                String msg = ls.getMessage(key);
                if (msg.endsWith(":")) {
                    msg = msg.substring(0, msg.length() - 1);
                }
                writer.write(msg);
            }            
            return EVAL_BODY_INCLUDE;
        }
        catch (IOException e) {
            throw new JspException(e);
        }        
        
    }
  
    
    /**
     * {@inheritDoc}
     */
    public int doEndTag() throws JspException {
        JspWriter writer = pageContext.getOut();
        //<span class="required-form-field">*</span>
        HtmlTag span = new HtmlTag("span");
        span.setAttribute("class", REQUIRED_FIELD_CSS);
        span.addBody("*");
        try {
            writer.write(span.render());
            if (!StringUtils.isBlank(key)) {
                LocalizationService ls = LocalizationService.getInstance();
                String msg = ls.getMessage(key);
                if (msg.endsWith(":")) {
                    writer.write(":");
                }
            }
            
        }
        catch (IOException e) {
            throw new JspException(e);
        }        
        return SKIP_BODY;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void release() {
        key = null;                
        super.release();
    }    
}
