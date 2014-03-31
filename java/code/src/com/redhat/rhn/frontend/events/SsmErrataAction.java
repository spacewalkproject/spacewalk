/**
 * Copyright (c) 2013 SUSE
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
import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.action.ActionChainFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.ssm.SsmOperationManager;

import org.apache.log4j.Logger;

/**
 * SSM Errata Action
 *
 * @author Bo Maryniuk
 */
public class SsmErrataAction extends AbstractDatabaseAction {
    private static Logger log = Logger.getLogger(SsmRemovePackagesAction.class);

    /** {@inheritDoc} */
    @Override
    protected void doExecute(EventMessage msg) {
        SsmErrataAction.log.debug("Scheduling errata in SSM.");

        SsmErrataEvent event = (SsmErrataEvent) msg;
        User user = UserFactory.lookupById(event.getUserId());
        ActionChain actionChain = ActionChainFactory.getActionChain(event
            .getActionChainId());

        try {
            ErrataManager.applyErrata(user,
                                      event.getErrataIds(),
                                      event.getEarliest(),
                                      actionChain,
                                      event.getServerIds());
        }
        catch (Exception e) {
            SsmErrataAction.log.error("Error scheduling SSM errata for event: " + event, e);
        }
        finally {
            SsmOperationManager.completeOperation(
                    user,
                    SsmOperationManager.createOperation(user,
                                                        "ssm.package.remove.operationname",
                                                        RhnSetDecl.SYSTEMS.getLabel())
            );
        }
    }
}
