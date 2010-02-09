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

import com.redhat.rhn.manager.acl.AclManager;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.TagSupport;

/**
 * RequireTag
 * Evaluates the acl and if true exposes its body.<p>
 * <pre>
 * &lt;rhn:require acl="acl_to_evaluate(params_to_acl)"&gt;
 *  &lt;h2&gt;JSP or HTML tags to be evaluated if above acl is valid&lt;/h2&gt;
 *     Otherwise, everything between the tag will be ignored.
 * &lt;/rhn:require&gt;
 * </pre>
 * @version $Rev$
 */
public class RequireTag extends TagSupport {

    /** Acl to evaluate */
    private String acl;

    private String mixins;

    /**
     * Constructor for require tag.
     */
    public RequireTag() {
        super();
        acl = null;
        mixins = null;
    }

    /**
     * Sets the acl with the value specified in the JSP tag.
     * @param aclIn the acl with the value specified in the JSP tag.
     */
    public void setAcl(String aclIn) {
        acl = aclIn;
    }

    /**
     * Returns the value of the acl attribute passed into the tag.
     * <pre>
     * <rhn:require acl="value">
     *     <h2>Hello World</h2>
     * </rhn:require>
     * </pre>
     * @return The value of the acl attribute.
     */
    public String getAcl() {
        return acl;
    }

    /**
     * Sets the Acl classnames to be mixed in.  The mixins
     * are applied in addition to the other acls.
     * @param mix A comma separated list of Acl classnames.
     * @see #getAcl()
     */
    public void setMixins(String mix) {
        mixins = mix;
        //mixins = StringUtils.split(mix, ",");
    }

    /**
     * Returns the comma separated String of Acl classnames to be mixed in.  The mixins
     * are applied in addition to the other acls:
     * @see #getAcl()
     * @return an CSL of Acl classnames to be mixed in.
     */
    public String getMixins() {
        return mixins;
    }

    /** {@inheritDoc} 
     * @throws JspException
     */
    public int doStartTag() throws JspException {
        try {
            if (acl == null || "".equals(acl)) {
                throw new Exception();
            }
            
            if (AclManager.hasAcl(acl, (HttpServletRequest)pageContext.getRequest(), 
                                  mixins)) {
                // acl methods must be in the following form
                // aclXxxYyy(Object context, String[] params) and invoked
                // xxx_yyy(param);
                return (EVAL_BODY_INCLUDE);
            }

            return (SKIP_BODY);
        }
        catch (Exception e) {
            throw new JspException("Error writing to JSP file:", e);
        }
    }

    /**
     * {@inheritDoc}
     */
    public void release() {
        acl = null;
        mixins = null;
        super.release();
    }
}
