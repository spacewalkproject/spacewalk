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
package com.redhat.rhn.domain.monitoring.notification;

import com.redhat.rhn.common.util.Asserts;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

/**
 * An enumeration type for match types
 * @version $Rev$
 */
public class MatchType {

    public static final String CAT_SCOPE = "scope";
    public static final String CAT_STATE = "state";
    public static final String CAT_REGEX = "regex";
    public static final String CAT_CONTACT = "contact";
    
    private static final HashMap TYPES = new HashMap();
    private static final HashMap CATEGORIES = new HashMap();
    
    public static final MatchType PROBE = create("PROBE_ID", "probe", CAT_SCOPE);
    public static final MatchType SCOUT = create("NETSAINT_ID", "scout", CAT_SCOPE);
    public static final MatchType ORG   = create("CUSTOMER_ID", "org", CAT_SCOPE);

    public static final MatchType STATE = create("SERVICE_STATE", null, CAT_STATE);
    
    public static final MatchType REGEX      = create("CASE_SEN_MSG_PATTERN", null, 
                                                      CAT_REGEX);
    public static final MatchType REGEX_CASE = create("CASE_INSEN_MSG_PATTERN", null, 
                                                      CAT_REGEX);
    public static final MatchType CONTACT = create("CONTACT_GROUP_ID", null, CAT_CONTACT);

    
    private static MatchType create(String name, String scope, String category) {
        MatchType result = new MatchType(name, scope, category);
        TYPES.put(name, result);
        Set catSet = (Set) CATEGORIES.get(category);
        if (catSet == null) {
            catSet = new HashSet();
            CATEGORIES.put(category, catSet);
        }
        catSet.add(result);
        return result;
    }
    
    private String name;
    private String scope;
    private String category;
    
    private MatchType(String name0, String scope0, String category0) {
        Asserts.assertNotNull(name0, "name0");
        name = name0;
        scope = scope0;
        category = category0;
    }
    
    /**
     * Get the name
     * @return the name
     */
    public String getName() {
        return name;
    }

    
    /**
     * @return Returns the scope.
     */
    public String getScope() {
        return scope;
    }

    
    /**
     * Return the category of the match type, one of the constants
     * {@link #CAT_SCOPE}, {@link #CAT_STATE}, or {@link #CAT_REGEX}
     * @return Returns the category.
     */
    public String getCategory() {
        return category;
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(Object obj) {
        if (!(obj instanceof MatchType)) {
            return false;
        }
        MatchType other = (MatchType) obj;
        return name.equals(other.getName());
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return name.hashCode();
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return "<matchType:" + name + ">";
    }

    static MatchType findMatchType(String match) {
        Asserts.assertNotNull(match, "match");
        MatchType result = (MatchType) TYPES.get(match);
        if (result == null) {
            throw new IllegalArgumentException("Unknown MatchType '" + match + "'");
        }
        return result;
    }
    
    /**
     * Return a set of all the match types with the given category
     * @param category the category for which to return match types
     * @return a set of all match types with the given category
     */
    public static Set typesInCategory(String category) {
        Set result = (Set) CATEGORIES.get(category);
        Asserts.assertNotNull(result, "category");
        return result;
    }
}
