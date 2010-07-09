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

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.HibernateRuntimeException;

import org.apache.log4j.Logger;
import org.hibernate.HibernateException;
import org.hibernate.Transaction;

/**
 * The logical work that should happen within one transaction. The
 * {@link #execute}method takes care of beginning and committing a transaction,
 * and of rolling it back if an error happens within the business logic. The
 * business logic should be implemented by overiding the {@link #run} method.
 *
 * @version $Rev$
 */
public abstract class Worker {

    private static final Logger LOG = Logger.getLogger(Worker.class);

    /**
     * Execute the business logic from the {@link #run} method within a database
     * transaction. Exceptions raised by either {@link #run} or the transaction
     * handling code are logged and rethrown. If any exceptions happen in
     * {@link #run}, the transaction is automatically rolled back.
     */
    public final void execute() {
        Transaction txn = null;
        try {
            txn = HibernateFactory.getSession().beginTransaction();
            run();
            txn.commit();
            txn = null;
        }
        catch (HibernateException e) {
            final String msg = "Error executing " + getClass().getName();
            LOG.error(msg, e);
            throw new HibernateRuntimeException(msg, e);
        }
        finally {
            if (txn != null) {
                try {
                    txn.rollback();
                }
                catch (HibernateException e) {
                    final String msg = "Additional error during rollback in " +
                            getClass().getName();
                    LOG.warn(msg, e);
                }
            }
        }
    }

    /**
     * This method is called by {@link #execute}, and is run in the context of
     * a database transaction. If this method returns without throwing an
     * exception, the transaction is committed. If an exception is raised by
     * this method, the transaction is rolled back.
     */
    protected abstract void run();

}
