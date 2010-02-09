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
package com.redhat.rhn.frontend.filter;

/**
 * Basically an interface user by the TreeFilter
 *  to ascertain the Depth of a DTO..   
 * DepthAware
 * @version $Rev$
 */
public interface DepthAware {
    /**
     * Returns the depth of a given dto. The depth value has to be >=0
     * with 0 being the root depth.
     * @return the depth of a given DTO object in a tree.
     */
    long depth();

}
