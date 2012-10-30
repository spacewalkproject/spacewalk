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

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.messaging.EventDatabaseMessage;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.errata.AsyncErrataCloneCounter;

import org.hibernate.Transaction;

/**
 * NewCloneErrataAction - publish event to clone the errata into a channel.
 *
 * I wanted this to contain a list of errata ids and do multiple
 * clones per event, but I couldn't get it to recall the list of ids
 * once the message got popped back off
 * @version $Rev$
 */
public class NewCloneErrataEvent implements EventDatabaseMessage {



    private Long chanId;
    private Long errata;
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
    public NewCloneErrataEvent(Channel chanIn, Long errataIn,
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
    public String toText() {
        // really a noop
        return "";
    }

    /**
     *
     * {@inheritDoc}
     */
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
     * @return Returns the errata.
     */
    public Long getErrata() {
        return errata;
    }


    /**
     * @param errataIn The errata to set.
     */
    public void setErrata(Long errataIn) {
        this.errata = errataIn;
    }


    /**
     * @return Returns the user.
     */
    public User getUser() {
        return UserFactory.lookupById(userId);
    }

    /**
     * Register the async clone event with the counter
     */
    public void register() {
        AsyncErrataCloneCounter.getInstance().addAsyncErrataCloneJob(chanId);
    }

    /**
     * De-regiser the async clone event from the counter
     */
    public void deregister() {
        AsyncErrataCloneCounter.getInstance().removeAsyncErrataCloneJob(chanId);
    }
}
