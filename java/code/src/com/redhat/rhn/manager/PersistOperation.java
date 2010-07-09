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
package com.redhat.rhn.manager;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.user.User;

/**
 * PersistOperation - interface defining a way to store objects to a
 * persistence layer.  The main method is "store()" that defines the Operation
 * for storing an Object to the db.
 *
 * @version $Rev$
 */
public interface PersistOperation {

    /**
     * All PersistOperations must have a User object
     * who is performing the Operation.
     * @return User performing the Operation.
     */
    User getUser();


    /**
     * Perform the storage Operation to the Persistence
     * Layer.
     * @return ValidatorError if there was an error trying
     * to store the object.
     */
    ValidatorError store();


}
