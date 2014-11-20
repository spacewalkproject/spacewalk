/**
 * Copyright (c) 2014 Red Hat, Inc.
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
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.channel.ssm.ChannelActionDAO;
import com.redhat.rhn.manager.ssm.SsmOperationManager;
import com.redhat.rhn.manager.system.UpdateBaseChannelCommand;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.util.Collection;

/**
 * Handles performing subscription changes for servers in the SSM.
 *
 * @see com.redhat.rhn.frontend.events.SsmChangeChannelSubscriptionsEvent
 * @version $Revision$
 */
public class SsmChangeBaseChannelSubscriptionsAction extends AbstractDatabaseAction {
    /** Logger instance. */
    private static Log log = LogFactory.getLog(
            SsmChangeBaseChannelSubscriptionsAction.class);

    /** {@inheritDoc} */
    protected void doExecute(EventMessage msg) {
        SsmChangeChannelSubscriptionsEvent event = (SsmChangeChannelSubscriptionsEvent) msg;

        User user = event.getUser();
        Collection<ChannelActionDAO> changes = event.getChanges();

        /* Anything after the operation is created should be in a try..finally to
           attempt to prevent a hanging, perpetually in progress operation. This is
           an added safety once a taskomatic task is created to automatically time out
           long requests.
         */
        try {
            for (ChannelActionDAO server : changes) {
                Server s = ServerFactory.lookupById(server.getId());
                try {
                    for (Long cid : server.getSubscribeChannelIds()) {
                        UpdateBaseChannelCommand ubcc = new UpdateBaseChannelCommand(user,
                                s, cid);
                        // don't care about the return value
                        ubcc.store();
                    }
                    // commit after each server to keep this from blocking other operations
                    HibernateFactory.commitTransaction();
                }
                catch (Exception e) {
                    // Exception just means user didn't have entitlements / permission
                    // to change channel subscription. Something changed since the event
                    // was scheduled. Can't pass the message back to the user at this
                    // point, let's not change anything and move along.
                    HibernateFactory.rollbackTransaction();
                }

                HibernateFactory.closeSession();
                HibernateFactory.getSession();
            }
        }
        catch (Exception e) {
            log.error("Error changing channel subscriptions " + event, e);
        }
        finally {
            // Complete the action
            SsmOperationManager.completeOperation(user, event.getOpId());
        }
    }
}
