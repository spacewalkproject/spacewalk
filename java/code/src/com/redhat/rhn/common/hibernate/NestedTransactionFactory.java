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
package com.redhat.rhn.common.hibernate;

import org.hibernate.ConnectionReleaseMode;
import org.hibernate.HibernateException;
import org.hibernate.Transaction;
import org.hibernate.TransactionException;
import org.hibernate.jdbc.JDBCContext;
import org.hibernate.transaction.JDBCTransactionFactory;
import org.hibernate.transaction.TransactionFactory;

import java.util.Properties;

import javax.transaction.Synchronization;

/**
 * A transaction factory that ignores transaction nesting. Only toplevel transactions
 * are actually connected to the database, and calling <code>commit</code> and
 * <code>rollback</code> on them will have an effect. A transaction is a toplevel
 * transaction if it is the first transaction within a thread and a session. The scope
 * of a toplevel transaction extends to the first call to <code>commit</code> or
 * <code>rollback</code> on that transaction object, or to the end of the session,
 * if the transaction is never committed or rolled back. The following code snippet
 * illustrates this:
 * <pre>
 *   Session session = getHibernateSession();
 *   Transaction txn1 = session.beginTransaction(); // Toplevel txn
 *   Transaction txn2 = session.beginTransaction(); // Nested txn, ignored
 *   txn2.rollback();                               // ignored
 *   txn1.commit();                                 // Actual commit to the DB
 *   Transaction txn3 = session.beginTransaction(); // Toplevel txn
 *   txn3.rollback();                               // Actual rollback in DB
 * </pre>
 *
 * @version $Rev$
 */
public class NestedTransactionFactory implements TransactionFactory {

    private static final ThreadLocal TXN_TLS = new ThreadLocal();
    private final JDBCTransactionFactory jdbcTxnFactory = new JDBCTransactionFactory();

    /**
     * {@inheritDoc}
     */
    public Transaction createTransaction(JDBCContext jdbcContext, Context context)
        throws HibernateException {
        ToplevelTransaction txn = getTransaction();
        if (txn == null || jdbcContext != txn.jdbcCtx) {
            // Create new toplevel (JDBC) txn
            Transaction realTxn = jdbcTxnFactory.createTransaction(jdbcContext, context);
            txn = new ToplevelTransaction(realTxn, jdbcContext, context);
            TXN_TLS.set(txn);
            return txn;
        }
        else {
            // An outermost transaction exists
            throw new TransactionException("Nesting transactions is not allowed.");
        }
    }

    static Transaction threadTransaction() {
        return getTransaction();
    }

    private static ToplevelTransaction getTransaction() {
        return (ToplevelTransaction) TXN_TLS.get();
    }

    /**
     * {@inheritDoc}
     */
    public void configure(Properties props) throws HibernateException {
        // noop
    }

    /** {@inheritDoc} */
    public ConnectionReleaseMode getDefaultReleaseMode() {
        // match the default 3.1 behavior, in our case
        // this is at the end of the request.
        return ConnectionReleaseMode.ON_CLOSE;
    }

    /**
     * {@inheritDoc}
     */
    public boolean isTransactionManagerRequired() {
        // we don't need access to the JTA txn mgr
        return false;
    }

    /**
     * {@inheritDoc}
     */
    public boolean areCallbacksLocalToHibernateTransactions() {
        // sure why not
        return true;
    }

    private class ToplevelTransaction implements Transaction {

        private JDBCContext jdbcCtx;
        private Context ctx;
        private Transaction realTxn;

        public void begin() throws HibernateException {
            //System.out.println("XXX begin");
            realTxn.begin();
        }

        public void setTimeout(int arg0) {
            realTxn.setTimeout(arg0);
        }

        public ToplevelTransaction(Transaction txn, JDBCContext jdbcContext,
                                   Context context) {

            jdbcCtx = jdbcContext;
            ctx = context;
            realTxn = txn;
        }

        public void commit() throws HibernateException {
            realTxn.commit();
            //System.out.println("XXX commit: setting TXN_TLS to null");
            TXN_TLS.set(null);
        }

        public void rollback() throws HibernateException {
            realTxn.rollback();
            //System.out.println("XXX rollback: setting TXN_TLS to null");
            TXN_TLS.set(null);
        }

        public boolean wasCommitted() throws HibernateException {
            return realTxn.wasCommitted();
        }

        public boolean wasRolledBack() throws HibernateException {
            return realTxn.wasRolledBack();
        }

        public boolean isActive() throws HibernateException {
            return realTxn.isActive();
        }

        public void registerSynchronization(Synchronization synchronization)
                throws HibernateException {
            realTxn.registerSynchronization(synchronization);

        }
    }

    /**
     *
     * {@inheritDoc}
     */
    public boolean isTransactionInProgress(JDBCContext arg0, Context arg1,
            Transaction arg2) {
        // TODO Auto-generated method stub
        return false;
    }
}
