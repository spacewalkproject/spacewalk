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

import com.redhat.rhn.common.messaging.EventMessage;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.channel.ssm.ChannelActionDAO;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.ssm.SsmManager;
import com.redhat.rhn.manager.ssm.SsmOperationManager;

import java.util.List;

/**
 * Handles performing subscription changes for servers in the SSM.
 * 
 * @see com.redhat.rhn.frontend.events.SsmChangeChannelSubscriptionsEvent
 * @version $Revision$
 */
public class SsmChangeChannelSubscriptionsAction extends AbstractDatabaseAction {

    /** {@inheritDoc} */
    protected void doExecute(EventMessage msg) {
        SsmChangeChannelSubscriptionsEvent event = (SsmChangeChannelSubscriptionsEvent) msg;

        User user = event.getUser();
        List<ChannelActionDAO> changes = event.getChanges();

        // Parse and store the changes into RhnSets
        SsmManager.populateSsmChannelServerSets(user, changes);

        // Log the change operation
        
        /* Since the servers are in two separate sets, make explicit associations from
           those sets to the operation.
         */
        long operationId = SsmOperationManager.createOperation(user,
            "Channel Subscription Updates", null);

        SsmOperationManager.associateServersWithOperation(operationId, user.getId(),
            RhnSetDecl.SSM_CHANNEL_SUBSCRIBE.getLabel());
        SsmOperationManager.associateServersWithOperation(operationId, user.getId(),
            RhnSetDecl.SSM_CHANNEL_UNSUBSCRIBE.getLabel());

        // Do the changes
        
        /* Anything after the operation is created should be in a try..finally to
           attempt to prevent a hanging, perpetually in progress operation. This is
           an added safety once a taskomatic task is created to automatically time out
           long requests.
         */
        try {
            SsmManager.performChannelActions(user);
        }
        finally {
            // Complete the action
            SsmOperationManager.completeOperation(user, operationId);
        }
    }
}
