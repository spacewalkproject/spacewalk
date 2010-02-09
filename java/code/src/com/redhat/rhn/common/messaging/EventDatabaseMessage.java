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

package com.redhat.rhn.common.messaging;

import org.hibernate.Transaction;

/**
 * A interface representing a class that can act on a EventMessage that contains
 * a database transaction.  We pass a Transaction into this EventMessage so the
 * MessageQueue can *wait* on the caller's Transaction to finish before starting its work.
 * 
 *  This is useful if your Event needs to wait for the caller to finish writing
 *  things to the database.
 *
 * @version $Rev: 94458 $
 */
public interface EventDatabaseMessage extends EventMessage {

    /**
     *  Get the Transaction from the caller/creator of this EventMessage.
     * 
     * @return Transaction associated with the caller/creator of the EventMessage.
     */
    Transaction getTransaction();
}


