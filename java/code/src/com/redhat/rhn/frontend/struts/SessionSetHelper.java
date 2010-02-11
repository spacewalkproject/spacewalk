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

import java.util.HashSet;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;


/**
 * @author paji
 * @version $Rev$
 */
public class SessionSetHelper extends BaseSetHelper {

    /**
     * Constructor
     * 
     * @param requestIn to associate
     */
    public  SessionSetHelper(HttpServletRequest requestIn) {
        this.request = requestIn;
    }
    
        
            
    /**
     * Returns the label name associated with this declaration
     * @param decl the set declaration
     * @return the label name associated with this declaration
     */
    private static String makeLabel(String label) { 
        return "__session_set_" + label;
    }
    
    /**
     * returns true if a set associated with the declaration exists in the set 
     * @param request the servlet request
     * @param label the declaration 
     * @return true if a set associated with the declaration exists in the set
     */
    public static boolean exists(HttpServletRequest request, String label) {
        return  request.getSession().getAttribute(makeLabel(label)) != null;
    }
    
    /**
     * returns the set if there exists a associated to a set declaration
     * in the session.. If no such set exists, the method
     * creates a new session set and associates it to the session
     * @param request the servlet request 
     * @param label set declaration
     * @return the set
     */
    public static Set <String> lookupAndBind(HttpServletRequest request, String label) {
        String lbl = makeLabel(label);
        
        Set<String> set = (Set<String>) request.getSession().getAttribute(lbl); 
        if (set == null) {
            set = new HashSet<String>();
            request.getSession().setAttribute(lbl, set);
        }
        
        return set;
    }
    
    /**
     * removes the set with the given label
     * @param request the servlet request 
     * @param label set declaration
     */
    public static void obliterate(HttpServletRequest request, String label) {
        request.getSession().removeAttribute(makeLabel(label));
    }
}
