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


/**
 * Simple DTO for transfering data from the DB to the UI through datasource.
 *
 * @version $Rev$
 */
public class ChannelPerms {
    private Long id;
    private String name;
    private boolean hasPerm;
    private boolean globallySubscribable;

    /**
     * Is the channel gobally subscribable
     * @return Returns the globallySubscribable.
     */
    public boolean isGloballySubscribable() {
        return globallySubscribable;
    }

    /**
     * Set if the channel is globally subscribable
     * @param value 1 if the channel is globally subscribable.
     */
    public void setGloballySubscribable(Integer value) {
        if (value == null || (!value.equals(new Integer(1)))) {
            this.globallySubscribable = false;
            return;
        }
        this.globallySubscribable = true;
    }

    /**
     * Does the user have permission to this channel
     * @return Returns the hasPerm.
     */
    public boolean isHasPerm() {
        return hasPerm;
    }

    /**
     * Set if the user has permission to this channel
     * @param value 1 if the user has permissions to this channel
     */
    public void setHasPerm(Integer value) {
        if (value == null || (!value.equals(new Integer(1)))) {
            this.hasPerm = false;
            return;
        }
        this.hasPerm = true;
    }

    /**
     * Get the id of the channel
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }

    /**
     * Set the id of the channel
     * @param i The id to set.
     */
    public void setId(Long i) {
        this.id = i;
    }

    /**
     * Get the name of the channel
     * @return Returns the name.
     */
    public String getName() {
        return name;
    }

    /**
     * Set the name of the channel
     * @param n The name to set.
     */
    public void setName(String n) {
        this.name = n;
    }
}

