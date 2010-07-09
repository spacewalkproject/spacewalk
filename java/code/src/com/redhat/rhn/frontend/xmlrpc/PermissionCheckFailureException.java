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

/*
 * AUTOMATICALLY GENERATED FILE, DO NOT EDIT.
 */
package com.redhat.rhn.frontend.xmlrpc;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.domain.org.OrgEntitlementType;
import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.domain.server.Server;

/**
 * permission check failure
 * <p>

 *
 * @version definition($Rev: 76724 $)/template($Rev: 67725 $)
 */
public class PermissionCheckFailureException extends FaultException  {


    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = -5042826165636954528L;

        /////////////////////////
    // Constructors
    /////////////////////////
        /**
     * Constructor
     */
    public PermissionCheckFailureException() {
        super(-23, "permissionCheckFailure" , "You do not have permissions to " +
                "perform this action.");
        // begin member variable initialization
    }

        /**
     * Constructor
     * @param cause the cause (which is saved for later retrieval
     * by the Throwable.getCause() method). (A null value is
     * permitted, and indicates that the cause is nonexistent or
     * unknown.)
     */
    public PermissionCheckFailureException(Throwable cause) {
        super(-23 , "permissionCheckFailure", "You do not have permissions to " +
                "perform this action.", cause);
        // begin member variable initialization
    }

    /**
     * Constructor
     * @param role Cause for the exception (bad role)
     */
    public PermissionCheckFailureException(Role role) {
        super(-23, "permissionCheckFailure", "You do not have permissions to " +
                "perform this action. You need to have at least a " + role.getName() +
                                 " role to perform this action");
        // begin member variable initialization
    }

    /**
     * Constructor
     * @param ent  Cause for the exception (bad org entitlement type)
     */
    public PermissionCheckFailureException(OrgEntitlementType ent) {
        super(-23, "permissionCheckFailure" , "You do not have permissions to " +
                "perform this action. You need to have at least a " + ent.getName() +
                                 " entitement to perform this action");
        // begin member variable initialization
    }

    /**
     * Constructor
     * @param server  Cause for the exception (not permitted for server)
     */
    public PermissionCheckFailureException(Server server) {
        super(-23, "permissionCheckFailure" , "You do not have permissions to " +
                "perform this action for system id[" + server.getId() + "]");
        // begin member variable initialization
    }
    /////////////////////////
    // Getters/Setters
    /////////////////////////
}
