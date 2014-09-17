/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.redhat.rhn.common.messaging.EventMessage;
import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.action.ActionChainFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.action.ActionChainManager;

/**
 * Schedules config files actions for systems.
 */
public class SsmConfigFilesAction extends AbstractDatabaseAction {

    private final Log log = LogFactory.getLog(this.getClass());

    /** {@inheritDoc} */
    protected void doExecute(EventMessage msg) {
        SsmConfigFilesEvent event = (SsmConfigFilesEvent) msg;

        User user = UserFactory.lookupById(event.getUserId());
        ActionChain actionChain = ActionChainFactory.getActionChain(
                event.getActionChainId());

        try {
            ActionChainManager.createConfigActions(
                    user,
                    event.getRevisionMappings(),
                    event.getSystemIds(),
                    event.getType(),
                    event.getEarliest(),
                    actionChain);
        }
        catch (Exception e) {
            log.error("Error scheduling configuration files deployment for event " +
                    event, e);
        }

    }
}
