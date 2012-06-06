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
package com.redhat.rhn.frontend.events;

import com.redhat.rhn.common.messaging.EventMessage;
import com.redhat.rhn.manager.errata.ErrataManager;
import org.apache.log4j.Logger;

/**
 * NewCloneErrataAction
 * @version $Rev$
 */
public class NewCloneErrataAction
extends AbstractDatabaseAction {

    private static Logger log = Logger.getLogger(NewCloneErrataAction.class);

    /**
     * {@inheritDoc}
     */
    @Override
    public void doExecute(EventMessage msgIn) {
        NewCloneErrataEvent msg = (NewCloneErrataEvent) msgIn;
        ErrataManager.cloneErrataApi(msg.getChan(), msg.getHydratedErrata(),
                msg.getUser(), msg.isInheritPackages());
    }
}
