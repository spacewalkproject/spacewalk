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

import java.util.List;

/**
 * SystemsPerChannelDto - how many systems are sub'd to this base channel? What
 * other base channels are those systems allowed to sub to? What are the
 * available child-channels for this base?
 * @version $Rev$
 */
public class SystemsPerChannelDto extends BaseDto {

    private Long                id;
    private String                    name;
    private int                       systemCount;
    private List<EssentialChannelDto> allowedBaseChannels;
    private List<EssentialChannelDto> allowedCustomChannels;
    private List<ChildChannelDto>     availableChildren;

    /**
     * Constructor
     */
    public SystemsPerChannelDto() {
        super();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Long getId() {
        return id;
    }

    /**
     * Set the id of the channel of interest
     * @param inId ID to set.
     */
    public void setId(Long inId) {
        id = inId;
    }

    /**
     * What's this channels name?
     * @return rhnChannel.name
     */
    public String getName() {
        return name;
    }

    /**
     * Set the name of the channel of interest
     * @param nameIn new name
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /**
     * How many systems are currently subscribed to this channel?
     * @return # of systems
     */
    public int getSystemCount() {
        return systemCount;
    }

    /**
     * Set the number of systems subscribed to this channel
     * @param inSC new # of systems subscribed
     */
    public void setSystemCount(int inSC) {
        systemCount = inSC;
    }

    /**
     * What base channels could systems subscribed to "this" channel, be
     * resubscribed to?
     * @return list of appropriate channels
     */
    public List<EssentialChannelDto> getAllowedBaseChannels() {
        return allowedBaseChannels;
    }

    /**
     * Set the list of channels appropriate for systems subscribed to "this"
     * channel, be resubscribed to
     * @param abc list of allowed channels
     */
    public void setAllowedBaseChannels(List<EssentialChannelDto> abc) {
        allowedBaseChannels = abc;
    }

    /**
     * What child-channels are available to this channel
     * @return children of this
     */
    public List<ChildChannelDto> getAvailableChildren() {
        return availableChildren;
    }

    /**
     * Set the child-channels available to this channel
     * @param inAC available child channels
     */
    public void setAvailableChildren(List<ChildChannelDto> inAC) {
        availableChildren = inAC;
    }

    /**
     *
     * @return Allowed custom channels.
     */
    public List<EssentialChannelDto> getAllowedCustomChannels() {
        return allowedCustomChannels;
    }

    /**
     *
     * @param allowedCustomChannelsIn Allowed custom channels to set.
     */
    public void setAllowedCustomChannels(List<EssentialChannelDto>
        allowedCustomChannelsIn) {
        this.allowedCustomChannels = allowedCustomChannelsIn;
    }

}
