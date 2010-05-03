/**
 * Copyright (c) 2010 Red Hat, Inc.
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

import com.redhat.rhn.frontend.struts.Expandable;


/**
 * RlTagFunctions - class to encapsulate the set of static methods that 
 * a JSP can interact with.  See rl-taglib.tld for list of <function> definitions
 * @version $Rev$
 */
public class RhnListTagFunctions {
    // Pure util class.  No need for construction.
    private RhnListTagFunctions() {
    }
    
    /**
     * Quick check to see if the passed in object is expandable.
     * 
     * @param current The object to be checked
     * @return true if the current object is expandable
     */
    public static boolean isExpandable(Object current) {
        return current instanceof Expandable;
    }
    
    /**
     * Quick check to see if the passed in object is expandable.
     * 
     * @param current The object to be checked
     * @return true if the current object is expandable
     */
    public static int getChildrenCount(Object current) {
        if (!isExpandable(current)) {
            return 0;
        }
        return ((Expandable)current).expand().size();
    }    
}
