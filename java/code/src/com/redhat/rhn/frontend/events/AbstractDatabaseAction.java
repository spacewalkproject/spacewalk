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
package com.redhat.rhn.frontend.events;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.messaging.EventMessage;
import com.redhat.rhn.common.messaging.MessageAction;

import org.apache.log4j.Logger;
import org.hibernate.HibernateException;

/**
 * Base action for any action that communicates with the database. This class will
 * take care of committing the transaction and any cleanup that is necessary.
 *
 * @version $Rev$
 */
public abstract class AbstractDatabaseAction implements MessageAction {

    private static Logger log = Logger.getLogger(AbstractDatabaseAction.class);
    private static final String ROLLBACK_MSG = "Error during transaction. Rolling back.";

    /**
     * Performs the business logic of the action. This method should be implemented
     * instead of overriding {@link #execute(EventMessage)}.
     *
     * @param msg event being executed; will not be <code>null</code>
     */
    protected abstract void doExecute(EventMessage msg);

    /** {@inheritDoc} */
    public void execute(EventMessage msg) {
        boolean commit = true;
        try {
            doExecute(msg);
        }
        catch (Exception e) {
            commit = false;
            e.printStackTrace();
        }
        finally {
            handleTransactions(commit);
        }
    }


    /**
     * Commits the current thread transaction, as well as close the Hibernate session.
     * <p/>
     * Note that this call <em>MUST</em> take place for any database operations done in
     * a message queue action for the transaction to be committed.
     */
    protected void handleTransactions(boolean commit) {
        boolean committed = false;

        try {
            if (commit) {
                HibernateFactory.commitTransaction();
                committed = true;

                if (log.isDebugEnabled()) {
                    log.debug("Transaction committed");
                }
            }
        }
        catch (HibernateException e) {
            log.error(ROLLBACK_MSG, e);
        }
        finally {
            try {
                if (!committed) {
                    try {
                        if (log.isDebugEnabled()) {
                            log.debug("Rolling back transaction");
                        }
                        HibernateFactory.rollbackTransaction();
                    }
                    catch (HibernateException e) {
                        final String msg = "Additional error during rollback";
                        log.warn(msg, e);
                    }
                }
            }
            finally {
                // cleanup the session
                    HibernateFactory.closeSession();
            }
        }
    }

}
