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
package com.redhat.rhn.frontend.configuration.tags;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.frontend.html.HtmlTag;

import java.io.IOException;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.PageContext;


/**
 * ConfigTagHelper
 * @version $Rev$
 */
public class ConfigTagHelper {

    public static final String CONFIG_ERROR_IMG = "/img/rhn-listicon-cfg_error.gif";
    public static final String CONFIG_ERROR_ALT_TEXT = "??Unknown Icon - Error??";

    private ConfigTagHelper() {

    }
    /**
     * Helper Method to write a string to the jsp stream..
     * @param str string to write
     * @param pageContext the page context object
     * @throws JspException in the case of an io exception
     */
     static  void write(String str, PageContext pageContext) throws JspException {
        JspWriter writer = pageContext.getOut();
        try {
            writer.write(str);
        }
        catch (IOException e) {
            throw new JspException(e);
        }
    }

    /**
     * Helper Method to write a img icon the jsp stream..
     * @param imgPath the path to the JSP
     * @param altKey the altkey to be used
     * @param pageContext the context object
     * @throws JspException in the case of an io exception
     */
    static void writeIcon(String imgPath, String altKey,
                                   PageContext pageContext) throws JspException {
        LocalizationService service = LocalizationService.getInstance();
        HtmlTag img = new HtmlTag("img");
        img.setAttribute("alt", service.getMessage(altKey));
        img.setAttribute("src", imgPath);
        write(img.render(), pageContext);
    }

    /**
     * Helper Method to write a "ERROR" img icon the jsp stream..
     * @param pageContext the context object
     * @throws JspException in the case of an io exception
     */
    static void writeErrorIcon(PageContext pageContext) throws JspException {
        HtmlTag img = new HtmlTag("img");
        img.setAttribute("alt", CONFIG_ERROR_ALT_TEXT);
        img.setAttribute("src", CONFIG_ERROR_IMG);
        write(img.render(), pageContext);
    }

}
