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
package com.redhat.rhn.common.client;

import java.util.ArrayList;
import java.util.List;

/**
 * Structure representing internal data of a ClientCertificate.
 * @version $Rev$
 */
public class Member {

    private String name;
    private List values;
    
    /**
     * Public ctor
     */
    public Member() {
        name = "";
        values = new ArrayList();
    }
    
    /**
     * Returns the name
     * @return the name.
     */
    public String getName() {
        return name;
    }
    
    /**
     * Sets the name
     * @param nameIn The name to set.
     */
    public void setName(String nameIn) {
        name = nameIn;
    }
    
    /**
     * Returns the values.
     * @return the values.
     */
    public String[] getValues() {
        return (String[])values.toArray(new String[values.size()]);
    }
    
    /**
     * Adds a value for this Member
     * @param value to be added
     */
    public void addValue(String value) {
        values.add(value);
    }

    /**
     * Replace all values with the new list of values.
     * @param valuesLst used to replace current list.
     */
    public void setValues(List valuesLst) {
        values = valuesLst;
    }
}
