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

import com.redhat.rhn.domain.channel.Channel;


/**
 * EssentialChannelDto
 * @version $Rev$
 */
public class EssentialChannelDto extends BaseDto {

    private Long id;
    private Long ownerId;
    private String name;
    private String label;
    private boolean isCustom;
    private String release;

    /**
     * Constructor
     */
    public EssentialChannelDto() {
        super();
    }

    /**
     * Constructor
     * @param c Channel
     */
    public EssentialChannelDto(Channel c) {
        setId(c.getId());
        setName(c.getName());
        setLabel(c.getLabel());
    }

    /**
     * get release
     * @return the release
     */
    public String getRelease() {
        return release;
    }

    /**
     * set release
     * @param releaseIn the release
     */
    public void setRelease(String releaseIn) {
        this.release = releaseIn;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Long getId() {
        return id;
    }

    /**
     *
     * @return True is channel is a custom channel.
     */
    public boolean isCustom() {
        return isCustom;
    }

    /**
     * Set isCustom.
     * @param isCustomIn True if this is a custom channel.
     */
    public void setIsCustom(boolean isCustomIn) {
        this.isCustom = isCustomIn;
    }

    /**
     * Set isCustom from a Long.
     * @param in 1 if this is a custom channel.
     */
    public void setIsCustom(Long in) {
        isCustom = in.intValue() == 1;
    }

    /**
     * Get the label
     * @return Channel label to set.
     */
    public String getLabel() {
        return label;
    }

    /**
     * Set the label
     * @param labelIn Label to set.
     */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }

    /**
     * @return Channel name.
     */
    public String getName() {
        return name;
    }

    /**
     * @param nameIn Channel name to set.
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /**
     * @param idIn Id to set.
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }


    /**
     *
     * @return the owner ID.
     */
    public Long getOwnerId() {
        return ownerId;
    }


    /**
     * Set the owner ID.
     * @param ownerIdIn to set.
     */
    public void setOwnerId(Long ownerIdIn) {
        this.ownerId = ownerIdIn;
    }

}
