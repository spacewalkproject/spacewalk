/**
 * Copyright (c) 2009--2015 Red Hat, Inc.
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
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.manager.errata.ErrataManager;

import java.util.ArrayList;
import java.util.List;

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
        Errata erratum = ErrataFactory.lookupById(eid);
        Channel channel = msg.getChan();
        if (channel != null && erratum != null) {
            errata.add(erratum);
            ErrataManager.cloneErrataApi(msg.getChan(), errata,
                msg.getUser(), msg.isInheritPackages());
        }
        msg.deregister();
    }
}
