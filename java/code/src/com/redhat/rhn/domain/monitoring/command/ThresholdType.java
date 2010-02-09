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
package com.redhat.rhn.domain.monitoring.command;

import java.util.ArrayList;

/**
 * An enumeration type that lists all hte values from <tt>rhn_threshold_type</tt>
 * @version $Rev$
 */
public class ThresholdType implements Comparable {
    
    // Replicates table rhn_threshold_type
    private static final ArrayList TYPES = new ArrayList();
    
    public static final ThresholdType CRIT_MIN = makeType("crit_min",  0);
    public static final ThresholdType WARN_MIN = makeType("warn_min", 10);
    public static final ThresholdType WARN_MAX = makeType("warn_max", 20);
    public static final ThresholdType CRIT_MAX = makeType("crit_max", 30);
    
    
    private String name;
    private int sortKey;
    
    private ThresholdType() {
    }
    
    private ThresholdType(String name0, int sortKey0) {
        name = name0;
        sortKey = sortKey0;
    }
    
    /**
     * @return Returns the name.
     */
    public String getName() {
        return name;
    }
    
    /**
     * @return Returns the sortKey.
     */
    public int getSortKey() {
        return sortKey;
    }

    /**
     * {@inheritDoc}
     */
    public int compareTo(Object o) {
        ThresholdType other = (ThresholdType) o;
        return getSortKey() - other.getSortKey(); 
    }
    
    /**
     * {@inheritDoc}
     */
    public boolean equals(Object obj) {
        if (obj instanceof ThresholdType) {
            return getName().equals(((ThresholdType) obj).getName());
        }
        return false;
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return getSortKey();
    }

    /**
     * Return the threshold type with the given <code>name</code>
     * @param name the name of the threshold type
     * @return the threshold type with the given <code>name</code>
     * @throws IllegalArgumentException if no such type exists
     */
    public static final ThresholdType findType(String name) {
        for (int i = 0; i < TYPES.size(); i++) {
            ThresholdType t = (ThresholdType) TYPES.get(i);
            if (t.getName().equals(name)) {
                return t;
            }
        }
        throw new IllegalArgumentException("There is no threshold type with name " + name);
    }
    
    private static ThresholdType makeType(String name, int sortKey) {
        ThresholdType result = new ThresholdType(name, sortKey);
        TYPES.add(result);
        return result;
    }
}
