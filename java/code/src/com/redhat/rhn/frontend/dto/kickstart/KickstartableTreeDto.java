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
package com.redhat.rhn.frontend.dto.kickstart;

import com.redhat.rhn.frontend.dto.BaseDto;

/**
 * Kickstartable Tree DTO
 *
 * @version $Rev $
 */
public class KickstartableTreeDto extends BaseDto {

    private Long id;
    private String treeLabel;
    private String channelLabel;

    /**
     * Returns id
     * @return id
     */
    public Long getId() {
        return this.id;
    }

    /**
     * Sets id
     * @param idIn id to set
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     * returns tree label
     * @return label
     */
    public String getKickstartlabel() {
        return this.treeLabel;
    }

    /**
     * sets tree label
     * @param labelIn label to set
     */
    public void setKickstartlabel(String labelIn) {
        this.treeLabel = labelIn;
    }

    /**
     * returns base channel label
     * @return label
     */
    public String getChannellabel() {
        return this.channelLabel;
    }

    /**
     * sets base channel label
     * @param labelIn label to set
     */
    public void setChannellabel(String labelIn) {
        this.channelLabel = labelIn;
    }

}
