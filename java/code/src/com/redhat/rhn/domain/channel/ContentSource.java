/**
 * Copyright (c) 2009--2013 Red Hat, Inc.
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
import com.redhat.rhn.domain.Identifiable;
import com.redhat.rhn.domain.org.Org;

import java.util.HashSet;
import java.util.Set;

/**
 * ContentSourceType
 * @version $Rev$
 */
public class ContentSource extends BaseDomainHelper implements Identifiable {

    private Long id;
    private Org org;
    private ContentSourceType type;
    private String sourceUrl;
    private String label;
    private Set<Channel> channels = new HashSet<Channel>();
    private Set<SslContentSource> sslSets = new HashSet<SslContentSource>();

    /**
     * Constructor
     */
    public ContentSource() {
    }

    /**
     * Copy Constructor
     * @param cs @param cs content source template
     */
    public ContentSource(ContentSource cs) {
        org = cs.getOrg();
        type = cs.getType();
        sourceUrl = cs.getSourceUrl();
        label = cs.getLabel();
        channels = new HashSet<Channel>(cs.getChannels());
        sslSets = new HashSet<SslContentSource>(cs.getSslSets());
    }


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

    /**
     *
     * @return SSL sets for content source
     */
    public Set<SslContentSource> getSslSets() {
        return sslSets;
    }

    /**
     *
     * @param sslSetsIn SSL sets to assign to repository
     */
    public void setSslSets(Set<SslContentSource> sslSetsIn) {
        this.sslSets = sslSetsIn;
    }
}
