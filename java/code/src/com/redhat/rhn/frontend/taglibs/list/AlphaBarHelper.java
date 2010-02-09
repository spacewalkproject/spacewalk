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

import com.redhat.rhn.common.localization.LocalizationService;

import org.apache.commons.lang.StringUtils;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.ServletRequest;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.PageContext;

/**
 * 
 * AlphaBarHelper
 * @version $Rev$
 */
public class AlphaBarHelper {

    private static final AlphaBarHelper INSTANCE = new AlphaBarHelper();

    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = -4344327713489384983L;
    
    /**
     * provides the alpha bar key 
     * @param listName the list name
     * @return the url key for the alpha bar
     */
    public static String makeAlphaKey(String listName) {
        return "list_" + listName + "_alpha_key";
    }
    
    /**
     * Returns true if the alpha bar item was selected from the  request 
     * @param listName the name of this list, ncessary for unique identification
     * @param req the servlet request.
     * @return true if the alpha bar item was selected from the  request
     */
    public boolean isSelected(String listName, ServletRequest req) {
        return !StringUtils.isBlank(req.getParameter(makeAlphaKey(listName)));
    }
    
    /**
     * Returns the alpha value..
     * @param listName the name of this list, ncessary for unique identification
     * @param req the servlet request.
     * @return the alpha value
     */
    public String getAlphaValue(String listName, ServletRequest req) {
        return req.getParameter(makeAlphaKey(listName));
    }
    
    /**
     * get the singleton instance
     * @return the instance
     */
    public static AlphaBarHelper getInstance() {
        return INSTANCE;
    }

    /**
     * Write the alpha bar to the current pageContext
     * @param pageContext the pageContext to write to
     * @param activeChars a Set of characters that are active in the alpha bar
     * @param listName the name of the list to write the alpha bar for.
     * @throws JspException jspException from the super class
     */
    public void writeAlphaBar(PageContext pageContext,
            Set<Character> activeChars, String listName) throws JspException {

        ListTagUtil.write(pageContext, "<br />");
        ListTagUtil.write(pageContext, 
                         "<table width=\"100%\" cellspacing=\"0\"" +
                                " cellpadding=\"1\">");
        ListTagUtil.write(pageContext, "<tr valign=\"top\">");
        ListTagUtil.write(pageContext, "<td class=\"list-alphabar\">" +
                                        "<div align=\"center\"><strong>");

        List<String> alphabet = LocalizationService.getInstance().getAlphabet();
        List<String> numbers = LocalizationService.getInstance().getDigits();

        for (String numberString : numbers) {
            char number = numberString.charAt(0);
            if (activeChars.contains(number)) {
                ListTagUtil.write(pageContext, renderEnabledAlpha(number,
                                                listName, pageContext.getRequest()));
            }
            else {
                ListTagUtil.write(pageContext, renderDisabledAlph(number));
            }
        }

        for (String letterString : alphabet) {
            char letter = letterString.charAt(0);
            if (activeChars.contains(letter)) {
                ListTagUtil.write(pageContext, renderEnabledAlpha(letter, 
                                            listName, pageContext.getRequest()));
            }
            else {
                ListTagUtil.write(pageContext, renderDisabledAlph(letter));
            }
        }

        ListTagUtil.write(pageContext, "</strong></div>");
        ListTagUtil.write(pageContext, "<br />");
        ListTagUtil.write(pageContext, "</td>");
        ListTagUtil.write(pageContext, "  </tr>");
        ListTagUtil.write(pageContext, "</table>");
    }

    private String renderEnabledAlpha(char alpha,
                                        String listName,
                                        ServletRequest request) {
        Map <String, String> params = new HashMap<String, String>();
        params.put(makeAlphaKey(listName), String.valueOf(alpha));
        
        StringBuilder enabled = new StringBuilder("<a href=\"");
        enabled.append(ListTagUtil.makeParamsLink(request, listName, params, 
                Collections.EMPTY_LIST));
        enabled.append("\"");
        enabled.append(" class=\"list-alphabar-enabled\">" + alpha + "</a>");
        return enabled.toString();
    }

    private String renderDisabledAlph(char alpha) {
        return "<span class=\"list-alphabar-disabled\">" + alpha + "</span>";
    }

}
