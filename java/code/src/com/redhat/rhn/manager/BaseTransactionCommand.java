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

import org.apache.log4j.Logger;
import org.hibernate.HibernateException;

/**
 * BaseTransactionCommand - simple baseclass to hold logic for handling tx
 *
 * @version $Rev$
 */
public class BaseTransactionCommand {

    private Logger log;

    /**
     * Constructor
     * @param logIn to use.
     */
    public BaseTransactionCommand(Logger logIn) {
        log = logIn;
    }

    protected void handleTransaction() {
        boolean committed = false;

        try {
            HibernateFactory.commitTransaction();
            committed = true;

            if (log.isDebugEnabled()) {
                log.debug("Transaction committed");
            }
        }
        catch (HibernateException e) {
            log.error("Rolling back transaction", e);
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
