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
package com.redhat.rhn.frontend.dto;

import com.redhat.rhn.domain.org.Org;

import java.util.ArrayList;
import java.util.List;

/**
 * @version $Rev: 101893 $
 */
public class OrgTrust extends BaseDto {

    private final Org org;
    private List<Long> subscribed = new ArrayList<Long>();

    /**
     * @param orgIn An org.
     */
    public OrgTrust(Org orgIn) {
        org = orgIn;
    }

    /**
     * {@inheritDoc}
     */
    public Long getId() {
        return org.getId();
    }

    /**
     * Get the org.
     * @return The org.
     */
    public Org getOrg() {
        return org;
    }

    /**
     * Get the number or orgs trusted by this org.
     * @return The number of tusted orgs.
     */
    public int getNumTrusted() {
        return org.getTrustedOrgs().size();
    }

    /**
     * Get the number of subscribed servers that have been
     * enabled by this trust.
     * @return The number of subscribed servers.
     */
    public List<Long> getSubscribed() {
        return subscribed;
    }

    /**
     * Set the number of subscribed servers that have been
     * enabled by this trust.
     * @param subscribedIn The number of subscribed servers.
     */
    public void setSubscribed(List<Long> subscribedIn) {
        subscribed = subscribedIn;
    }
    
    /**
     * gets the org name of the trust
     * @return the org name
     */
    public String getOrgName() {
        return this.getOrg().getName();
    }
    
}
