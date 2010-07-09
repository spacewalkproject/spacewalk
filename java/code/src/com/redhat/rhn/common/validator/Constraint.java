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
package com.redhat.rhn.common.validator;


/**
 * <p>
 *  The <code>Constraint</code> class represents a single data constraint
 * </p>
 * @version $Rev$
 */
public interface Constraint {

    /**
    * Check the field against this Constraint to see
    * if it is in a valid state.
    * @param value the value to check
    * @return String error message if the constraint check failed.  Null
    *         otherwise.
    */
    ValidatorError checkConstraint(Object value);


    /**
    * Get the named identifier of this Constraint
    * @return String identifier
    */
    String getIdentifier();

    /**
     * <p>
     *  This will return the <code>String</code> version of the Java data type for this
     *    constraint.
     * </p>
     *
     * @return <code>String</code> - the data type for this constraint.
     */
    String getDataType();


    /**
     * <p>
     *  This will allow the data type for the constraint to be set. The type is specified
     *    as a Java <code>String</code>.
     * </p>
     *
     * @param dataTypeIn <code>String</code> that is the Java data type for this constraint.
     */
    void setDataType(String dataTypeIn);

}
