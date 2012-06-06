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

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.messaging.EventDatabaseMessage;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;

import org.hibernate.Transaction;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * NewCloneErrataAction - publish event to clone the errata into a channel.
 *
 * @version $Rev$
 */
public class NewCloneErrataEvent implements EventDatabaseMessage {



    private Long chanId;
    private Collection<Long> errata;
    private final Transaction txn;
    private final Long userId;
    private boolean inheritPackages;

    /**
     * constructor
     * @param chanIn channel to clone errata into
     * @param errataIn the errata list to clone
     * @param userIn the user
     * @param inheritPackagesIn inheritPackages
     */
    public NewCloneErrataEvent(Channel chanIn, Collection<Long> errataIn,
            User userIn, boolean inheritPackagesIn) {
        chanId = chanIn.getId();
        errata = errataIn;
        userId = userIn.getId();
        inheritPackages = inheritPackagesIn;
        this.txn = HibernateFactory.getSession().getTransaction();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String toText() {
        // really a noop
        return "";
    }

    /**
     *
     * {@inheritDoc}
     */
    @Override
    public Transaction getTransaction() {
        return txn;
    }

    /**
     * @return Returns the value of inheritPackages
     */
    public boolean isInheritPackages() {
        return inheritPackages;
    }

    /**
     * @param inheritPackagesIn inheritPackages
     */
    public void setInheritPackages(boolean inheritPackagesIn) {
        this.inheritPackages = inheritPackagesIn;
    }

    /**
     * @return Returns the chan.
     */
    public Channel getChan() {
        return ChannelFactory.lookupById(chanId);
    }


    /**
     * @param chanIn The chan to set.
     */
    public void setChan(Channel chanIn) {
        this.chanId = chanIn.getId();
    }

    /**
     * @return A List of Errata objects
     */
    public List<Errata> getHydratedErrata() {
        List<Errata> errataList = new ArrayList<Errata>();
        for (Long erratum : errata) {
            errataList.add(ErrataFactory.lookupById(erratum));
        }
        return errataList;
    }


    /**
     * @return Returns the errata.
     */
    public Collection<Long> getErrata() {
        return errata;
    }


    /**
     * @param errataIn The errata to set.
     */
    public void setErrata(Collection<Long> errataIn) {
        this.errata = errataIn;
    }


    /**
     * @return Returns the user.
     */
    public User getUser() {
        return UserFactory.lookupById(userId);
    }


}
