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
package com.redhat.rhn.testing;

import com.mockobjects.servlet.MockHttpSession;

import java.util.HashMap;
import java.util.Map;

/**
 * Override MockHttpSession's implementation of get/setAttribute so we
 * don't have to define ahead of time all the attributes that will be set
 * on the session.
 * @version $Rev$
 */
public class RhnMockHttpSession extends MockHttpSession {

    private Map attributes;

    /**
     * default constructor
     */
    public RhnMockHttpSession() {
        super();
        attributes = new HashMap();
    }

    /**
     * Returns the attribute bound to the given name.
     * @param name Name of attribute whose value is sought.
     * @return Object value of attribute with given name.
     */
    public Object getAttribute(String name) {
        return attributes.get(name);
    }

    /**
     * Adds a new attribute the Session.
     * @param name attribute name
     * @param value attribute value
     */
    public void setAttribute(String name, Object value) {
        attributes.put(name, value);
    }

    /**
     * Removes an attribute from the session
     * @param name attribute name
     */
    public void removeAttribute(String name) {
        attributes.remove(name);
    }

    /** {@inheritDoc} */
    public String toString() {
        return this.getClass().getName() + " attributes: " + attributes;
    }
}
