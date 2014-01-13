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

import java.util.ArrayList;
import java.util.List;

import com.redhat.rhn.common.messaging.EventMessage;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.manager.errata.ErrataManager;

/**
 * NewCloneErrataAction
 * @version $Rev$
 */
public class NewCloneErrataAction
extends AbstractDatabaseAction {

    /**
     * {@inheritDoc}
     */
    @Override
    public void doExecute(EventMessage msgIn) {
        NewCloneErrataEvent msg = (NewCloneErrataEvent) msgIn;
        Long eid = msg.getErrata();
        List<Errata> errata = new ArrayList<Errata>();
        errata.add(ErrataFactory.lookupById(eid));
        ErrataManager.cloneErrataApi(msg.getChan(), errata,
                msg.getUser(), msg.isInheritPackages());
        msg.deregister();
    }
}
