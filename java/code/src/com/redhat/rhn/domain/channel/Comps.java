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

import com.redhat.rhn.domain.BaseDomainHelper;
/**
 *
 * @version $Rev $
 *
 */
public class Comps extends BaseDomainHelper {

    private Long id;
    private String relativeFilename;
    private Channel channel;

    /**
     *
     * @return Returns Id
     */
    public Long getId() {
        return id;
    }

    /**
     *
     * @param idIn The Id to set.
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     *
     * @return Returns Relative filename
     */
    public String getRelativeFilename() {
        return relativeFilename;
    }

    /**
     *
     * @param relativeFilenameIn The filename to set.
     */
    public void setRelativeFilename(String relativeFilenameIn) {
        this.relativeFilename = relativeFilenameIn;
    }

    /**
     *
     * @param channelIn The channel to set.
     */
    public void setChannel(Channel channelIn) {
        this.channel = channelIn;
    }

    /**
     *
     * @return Returns channel object
     */
    public Channel getChannel() {
        return channel;
    }
}
