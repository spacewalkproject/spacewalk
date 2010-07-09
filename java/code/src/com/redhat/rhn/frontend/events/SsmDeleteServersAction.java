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
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.ssm.SsmOperationManager;
import com.redhat.rhn.manager.system.SystemManager;

import java.util.List;

/**
 * Handles performing subscription changes for servers in the SSM.
 *
 * @see com.redhat.rhn.frontend.events.SsmDeleteServersEvent
 * @version $Revision$
 */
public class SsmDeleteServersAction extends AbstractDatabaseAction {
    public static final String OPERATION_NAME = "Server Delete";

    /** {@inheritDoc} */
    protected void doExecute(EventMessage msg) {
        SsmDeleteServersEvent event = (SsmDeleteServersEvent) msg;
        User user = UserFactory.lookupById(event.getUser());
        List<Long> sids = event.getSids();

        long operationId = SsmOperationManager.createOperation(user,
                        OPERATION_NAME, null);

        SsmOperationManager.associateServersWithOperation(operationId,
                                                        user.getId(), sids);

        try {
            for (Long sid : sids) {
                SystemManager.deleteServer(user, sid);
            }
        }
        finally {
            // Complete the action
            SsmOperationManager.completeOperation(user, operationId);
        }

    }
}
