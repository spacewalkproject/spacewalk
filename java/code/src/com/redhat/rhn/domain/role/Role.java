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

package com.redhat.rhn.domain.role;

/**
 * Class UserGroup that reflects the DB representation of RHNUSERGROUP
 * This class and package are only intended to be used internally by the
 * parent of this package, com.redhat.rhn.domain.org
 *
 * DB table: RHNUSERGROUP
 * @version $Rev$
 */
public interface Role {

    /**
     * Getter for id
     * @return id
     */
    Long getId();

    /**
     * Getter for label
     * @return label
     */
    String getLabel();

    /**
     * Setter for label
     * @param labelIn Value to set label to.
     */
    void setLabel(String labelIn);

    /**
     * Getter for name
     * @return name
     */
    String getName();

    /**
     * Setter for name
     * @param nameIn Value to set name to.
     */
    void setName(String nameIn);

}
