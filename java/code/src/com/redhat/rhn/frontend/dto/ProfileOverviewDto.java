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
 *
 * ProfileOverviewDto class represents a stored profile typically listed
 * within the Systems->Stored Profiles
 *
 * @version $Rev$
 */
public class ProfileOverviewDto extends BaseDto {

    private Long id;
    private String name;
    private String created;
    private String channelName;

    /**
     * Retrieve profile id.
     * {@inheritDoc}
     */
    public Long getId() {
        return id;
    }

    /**
     * Set profile id.
     * @param idIn profile id
     */
    public void setId(Long idIn) {
        id = idIn;
    }

    /**
     * Retrieve profile name
     * @return Name of profile
     */
    public String getName() {
        return name;
    }

    /**
     * Set profile name
     * @param nameIn Name of profile
     */
    public void setName(String nameIn) {
        name = nameIn;
    }

    /**
     * Retrieve base channel name
     * @return Name of channel
     */
    public String getChannelName() {
        return channelName;
    }

    /**
     * Set base channel name
     * @param nameIn Name of channel
     */
    public void setChannelName(String nameIn) {
        channelName = nameIn;
    }

    /**
     * Retrieve profile creation date
     * @return date profile was created
     */
    public String getCreated() {
        return created;
    }

    /**
     * Set profile creation date
     * @param createdIn date profile was created
     */
    public void setCreated(String createdIn) {
        created = createdIn;
    }
}
