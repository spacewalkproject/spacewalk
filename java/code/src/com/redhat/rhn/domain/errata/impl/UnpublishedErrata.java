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
package com.redhat.rhn.domain.errata.impl;

import com.redhat.rhn.common.security.errata.PublishedOnlyException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.errata.AbstractErrata;
import com.redhat.rhn.domain.errata.Cve;
import com.redhat.rhn.domain.errata.Keyword;

import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Errata - Class representation of the table rhnErrata.
 * @version $Rev: 51306 $
 */
public class UnpublishedErrata extends AbstractErrata {

    private Set<Cve> cves = new HashSet<Cve>();

    /**
     * {@inheritDoc}
     */
    public boolean isCloned() {
        return false;
    }

    /**
     * {@inheritDoc}
     */
    public boolean isPublished() {
        return false;
    }

    /**
     * Convienience method so we can add keywords logically Adds a keyword to
     * the keywords set
     * @param keywordIn The keyword to add.
     */
    public void addKeyword(String keywordIn) {
        // Create an Unpublished Keyword and add to the set
        Keyword k = new UnpublishedKeyword();
        k.setKeyword(keywordIn);
        addKeyword(k);
        k.setErrata(this);
    }

    /*
     * Unpublished Erratas cannot have channels yet or have anything in their
     * notification queue.
     */
    /**
     * {@inheritDoc}
     */
    public void addChannel(Channel channelIn) {
        throw new PublishedOnlyException("Only published erratas can have channels");
    }

    /**
     * {@inheritDoc}
     */
    public void setChannels(Set channelsIn) {
        throw new PublishedOnlyException("Only published erratas can have channels");
    }

    /**
     * {@inheritDoc}
     */
    public Set<Channel> getChannels() {
        //if this gets called on an unpublished errata, just return an empty set:
        return new HashSet<Channel>();
    }

    /**
     * {@inheritDoc}
     */
    public void addNotification(Date dateIn) {
        throw new PublishedOnlyException("Only published erratas can have notifications");
    }

    /**
     * {@inheritDoc}
     */
    public void setNotificationQueue(Set queueIn) {
        throw new PublishedOnlyException("Only published erratas can have notifications");
    }

    /**
     * {@inheritDoc}
     */
    public List getNotificationQueue() {
        // if this gets called on an unpublished errata, just return null
        return null;
    }

    /**
     * {@inheritDoc}
     */
    public void setCves(Set<Cve> cvesIn) {
        this.cves = cvesIn;
    }

    /**
     * {@inheritDoc}
     */
    public Set<Cve> getCves() {
        return cves;
    }
}
