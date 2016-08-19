/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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

import org.apache.log4j.Logger;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * Utility class which encapsulates the logic necessary to dispatch actions
 *
 * @version $Rev $
 */
class ActionExecutor implements Runnable {

    private static final Logger LOG = Logger.getLogger(ActionExecutor.class);

    private EventMessage msg;
    private List<MessageAction> actionHandlers = new ArrayList<MessageAction>();

    /**
     * Constructor
     * @param handlers list of event handlers to dispatch to
     * @param eventMsg message published to queue
     */
    public ActionExecutor(List<MessageAction> handlers, EventMessage eventMsg) {
        actionHandlers.addAll(handlers);
        msg = eventMsg;
    }

    /**
     * Iterates over the list of handlers and dispatches
     * the message to each
     */
    public void run() {
        for (Iterator<MessageAction> iter = actionHandlers.iterator(); iter.hasNext();) {
            MessageAction action = iter.next();
            LOG.debug("run() - got action: " + action.getClass().getName());
            try {
                if (msg instanceof EventDatabaseMessage) {
                    EventDatabaseMessage evtdb = (EventDatabaseMessage) msg;
                    LOG.debug("Got a EventDatabaseMessage");
                    while (evtdb.getTransaction().isActive()) {
                        if (LOG.isDebugEnabled()) {
                            LOG.debug("DB message, waiting for txn: active: " +
                                    evtdb.getTransaction().isActive() + " commited: " +
                                    evtdb.getTransaction().wasCommitted());
                        }
                        Thread.sleep(10);
                    }
                    LOG.debug("Transaction finished.  Executing");
                    action.execute(msg);
                }
                else {
                    action.execute(msg);
                }

            }
            catch (Throwable t) {
                LOG.error(t);
                t.printStackTrace();
            }
        }
    }
}
