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

import java.util.HashSet;
import java.util.Set;

import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.org.Org;

/**
 * ContentSourceType
 * @version $Rev$
 */
public class ContentSource extends BaseDomainHelper {

    private Long id;
    private Org org;
    private ContentSourceType type;
    private String sourceUrl;
    private String label;
    private Set<Channel> channels = new HashSet<Channel>();
    /**
     * @return Returns the label.
     */
    public String getLabel() {
        return label;
    }


    /**
     * @param labelIn The label to set.
     */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }

    /**
     *
     * @return Org this content source belongs to
     */
    public Org getOrg() {
        return org;
    }

    /**
     *
     * @param orgIn Org to set
     */
    public void setOrg(Org orgIn) {
        org = orgIn;
    }

    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }

    /**
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }


    /**
     * @return Returns the type.
     */
    public ContentSourceType getType() {
        return type;
    }


    /**
     * @param typeIn The type to set.
     */
    public void setType(ContentSourceType typeIn) {
        this.type = typeIn;
    }


    /**
     * @return Returns the sourceUrl.
     */
    public String getSourceUrl() {
        return sourceUrl;
    }


    /**
     * @param sourceUrlIn The sourceUrl to set.
     */
    public void setSourceUrl(String sourceUrlIn) {
        this.sourceUrl = sourceUrlIn;
    }

    /**
     *
     * @param channelsIn of channels this repo is pushed to
     */
    public void setChannels(Set<Channel> channelsIn) {
        this.channels = channelsIn;
    }

    /**
     *
     * @return set of channels that this repo will be pushed to
     */
    public Set<Channel> getChannels() {
        return channels;
    }

}
