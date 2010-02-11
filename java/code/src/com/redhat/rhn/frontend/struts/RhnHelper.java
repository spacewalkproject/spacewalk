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

package com.redhat.rhn.frontend.struts;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;


/**
 * RhnHelper contains helpful methods usable by our presentation layers.
 * 
 * @version $Rev$
 */
public class RhnHelper {

    /** The key used on RHN Requests to store the User */
    public static final String TARGET_USER = "targetuser";

    /** The key used on RHN Requests to store the Marketing Address */
    public static final String TARGET_ADDRESS_MARKETING = "addressMarketing";

    /** The key used on RHN Requests to store the Billing Address */
    public static final String TARGET_ADDRESS_BILLING = "addressBilling";

    /** The key used on RHN Requests to store the Shipping Address */
    public static final String TARGET_ADDRESS_SHIPPING = "addressShipping";
    
    /** The key for the default struts forward */
    public static final String DEFAULT_FORWARD = "default";
    
    /** The key for the default empty selection error */
    public static final String DEFAULT_EMPTY_SELECTION_KEY = "emptyselectionerror";
    
    /** utility class */
    private RhnHelper() {
    }
    
    /**
     * If the path doesn't require authentication, return false. Otherwise
     * return true. Checks that the passed in path doesn't startwith the params
     * found in nosecurityPaths
     * @param nosecurityPaths array of String paths, "/foo",
     * "/bar/baz/test.jsp", "/somepath/foo.do"
     * @param path to check
     * @return boolean if it needs to be authorized or not
     */
    public static boolean pathNeedsSecurity(String[] nosecurityPaths,
            String path) {
        for (int i = 0; i < nosecurityPaths.length; i++) {
            String curr = nosecurityPaths[i];
            if (path.startsWith(curr)) {
                return false;
            }
        }
        return true;
    }
    
    /**
     * Method to add the default empty selection error message
     * to  the request
     * @param request the servlet request
     */
    public static void handleEmptySelection(HttpServletRequest request) {
        handleEmptySelection(request, 
                            DEFAULT_EMPTY_SELECTION_KEY);
    }
    
    /**
     * Use this for every textarea that we use in our UI.  Otherwise you will get ^M 
     * in your file showing up.
     * @param form to fetch from
     * @param name of value in form
     * @return String without CR in them.  
     */
    public static String getTextAreaValue(DynaActionForm form, String name) {
        String value = form.getString(name);
        return StringUtils.replaceChars(value, "\r", "");
    }


    /**
     * Method to add the empty selection error message
     * to  the request
     * @param request the servlet request
     * @param messageKey the key associated to 
     *                      the empty selection error                     
     */
    public static void handleEmptySelection(HttpServletRequest request,
                          String messageKey) {
            ActionMessages msg = new ActionMessages();
            msg.add(ActionMessages.GLOBAL_MESSAGE, 
                            new ActionMessage(messageKey));

            StrutsDelegate delegate = StrutsDelegate.getInstance();
            delegate.saveMessages(request, msg);
    }
    
    /** 
     * If you need to a request parameter that may contain +++ 
     * or other special characters that fails to fetch properly using
     * request.getParameter() you can use this method.
     * 
     * @param request to fetch from
     * @param name of parameter to fetch
     * @return String value from request, null if not found.
     */
    public static String getParameterWithSpecialCharacters(HttpServletRequest request, 
            String name) {
        String queryString = request.getQueryString();
        if (StringUtils.isEmpty(queryString)) {
            return null;
        }
        String[] pairs = StringUtils.split(queryString, "&");
        for (int i = 0; i < pairs.length; i++) {
            String[] param = StringUtils.split(pairs[i], "=");
            String iname = param[0];
            if (StringUtils.equals(name, iname) && param.length > 1) {
                String value = param[1];
                return value;
            }
        }
        
        return null;
    }
}
