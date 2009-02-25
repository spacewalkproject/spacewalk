/**
 * Copyright (c) 2009 Red Hat, Inc.
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
import com.redhat.rhn.domain.user.User;

import org.hibernate.Transaction;

import java.util.Collection;

/**
 * CloneErrataAction - publish event to clone the errata into a channel
 * or a set of Channels.
 * 
 * @version $Rev$
 */
public class CloneErrataEvent implements EventDatabaseMessage {



    private Channel chan;
    private Collection<Long> errata;
    private Transaction txn;
    private User user;

    /**
     * constructor
     * @param chanIn channel to clone errata into
     * @param errataIn the errata list to clone
     * @param userIn the user 
     */
    public CloneErrataEvent(Channel chanIn, Collection<Long> errataIn, User userIn) {
        chan = chanIn;
        errata = errataIn;
        user = userIn;
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
     * @return Returns the chan.
     */
    public Channel getChan() {
        return chan;
    }

    
    /**
     * @param chanIn The chan to set.
     */
    public void setChan(Channel chanIn) {
        this.chan = chanIn;
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
        return user;
    }
    
  
}
