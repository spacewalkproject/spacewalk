/**
 * Copyright (c) 2016 Red Hat, Inc.
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

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang.StringUtils;

import com.redhat.rhn.frontend.html.HiddenInputTag;
import com.redhat.rhn.frontend.html.HtmlTag;

/**
 * RhnHiddenTag: renders a hidden-input entity, insures value is htmlEscaped
 * <p>
 * {@literal
 * <input name="prev_filter_value" type="hidden" value="908238940"/>
 * }
 */

public class RhnHiddenTag extends TagSupport {

    private static final long serialVersionUID = -8385317358288103720L;

    private String id;
    private String name;
    private String value;

    /**
     * Public constructor for RhnHiddenTag
     */
    public RhnHiddenTag() {
        super();
    }

    /**
     * @return the name
     */
    public String getName() {
        return name;
    }

    /**
     * @param inId the id to set
     */
    public void setId(String inId) {
        this.id = inId;
    }

    /**
     * @return the id
     */
    public String getId() {
        return id;
    }

    /**
     * @param inName the name to set
     */
    public void setName(String inName) {
        this.name = inName;
    }

    /**
     * @return the value
     */
    public String getValue() {
        return value;
    }

    /**
     * @param inValue the value to set
     */
    public void setValue(String inValue) {
        this.value = inValue;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public int doStartTag() throws JspException {
        JspWriter out = null;
        try {
            StringBuffer buf = new StringBuffer();
            out = pageContext.getOut();

            HtmlTag baseTag = new HiddenInputTag();
            if (!StringUtils.isBlank(getId())) {
                baseTag.setAttribute("id", getId());
            }
            baseTag.setAttribute("name", getName());
            baseTag.setAttribute("value", StringEscapeUtils.escapeHtml(getValue()));
            buf.append(baseTag.render());
            out.print(buf.toString());
            return SKIP_BODY;
        }
        catch (Exception e) {
            throw new JspException("Error writing to JSP file:", e);
        }
    }

}
