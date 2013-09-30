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
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import java.io.IOException;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;

/**
 * The ColumnTag represents a column of data in a ListView.  It will setup the
 * title of the column using the header attribute, and display the body after
 * it has setup the header.  The column has five main attributes: header,
 * align, cssClass, url, width.  Header is <strong>REQUIRED</strong>.  All
 * others are optional.
 * @version $Rev: 1793 $
 */
public class SystemSetDisplayTag extends TagSupport {

    private User user;
    /**
     * {@inheritDoc}
     */
    public int doEndTag() throws JspException {

        try {
            JspWriter out = pageContext.getOut();
            RhnSet rs = user != null ? RhnSetDecl.SYSTEMS.lookup(user) : null;
            int size = rs == null ? 0 : rs.size();
            StringBuilder result = new StringBuilder();
            result.append("<span id=\"spacewalk-ssm-counter\" class=\"badge\">");
            result.append(Integer.toString(size));
            result.append("</span>");
            String msgKey = size == 1 ? "header.jsp.singleSystemSelected" :
                    "header.jsp.systemsSelected";
            result.append(LocalizationService.getInstance().getMessage(msgKey));
            out.println(result);
            return EVAL_PAGE;
        }
        catch (IOException ioe) {
            throw new JspException("IO error writing to JSP file:", ioe);
        }
    }


    /**
     * @return Returns the user.
     */
    public User getUser() {
        return user;
    }

    /**
     * @param u The user to set.
     */
    public void setUser(User u) {
        this.user = u;
    }


    /**
     * {@inheritDoc}
     */
    public void release() {
        user = null;
        super.release();
    }

}
