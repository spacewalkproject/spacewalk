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
package com.redhat.rhn.domain.channel;

import com.redhat.rhn.frontend.struts.Selectable;

/**
 * Wrapper class to enable Channels to be used and be selectable
 * SelectableChannel
 * @version $Rev$
 */
public class SelectableChannel  implements Selectable, Comparable {

    private Channel channel;
    private boolean selected = false;



    /**
     * Constuctor
     * @param chan the chan to wrap
     */
    public SelectableChannel(Channel chan) {
        channel = chan;
    }


    /**
     * checks to see if this is a base channel
     * @return true if it is a base channel, false otherwise
     */
    public boolean isBaseChannel() {
        return channel.isBaseChannel();
    }



    /**
     * @return Returns the channel.
     */
    public Channel getChannel() {
        return channel;
    }


    /**
     * @param channelIn The channel to set.
     */
    public void setChannel(Channel channelIn) {
        this.channel = channelIn;
    }


    /**
     * @return Returns the id.
     */
    public Long getId() {
        return channel.getId();
    }


    /**
     * @param id The id to set.
     */
    public void setId(Long id) {
        channel.setId(id);
    }


    /**
     * @return Returns the name.
     */
    public String getName() {
        return channel.getName();
    }


    /**
     * @param name The name to set.
     */
    public void setName(String name) {
        channel.setName(name);
    }

    /**
     * {@inheritDoc}
     */
    public String getSelectionKey() {
        return null;
    }

    /**
     * {@inheritDoc}
     */
    public boolean isSelectable() {
        return true;
    }

    /**
     * {@inheritDoc}
     */
    public boolean isSelected() {
        return selected;
    }

    /**
     * {@inheritDoc}
     */
    public void setSelected(boolean selectedIn) {
        selected = selectedIn;
    }

    /**
     * {@inheritDoc}
     */
    public int compareTo(Object o) {
       return this.getChannel().getName().compareTo(((SelectableChannel)o).
               getChannel().getName());
    }



}
