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

import java.util.Date;

/**
 * ContentSourceType
 * @version $Rev$
 */
public class ContentSource extends BaseDomainHelper {

    private Long id;
    private Channel channel;
    private ContentSourceType type;
    private String sourceUrl;
    private Date lastSynced;
    private String label;


    
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
     * @return Returns the chan.
     */
    public Channel getChannel() {
        return channel;
    }

    
    /**
     * @param chanIn The chan to set.
     */
    public void setChannel(Channel chanIn) {
        this.channel = chanIn;
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
     * @return Returns the lastSynced.
     */
    public Date getLastSynced() {
        return lastSynced;
    }

    
    /**
     * @param lastSyncedIn The lastSynced to set.
     */
    public void setLastSynced(Date lastSyncedIn) {
        this.lastSynced = lastSyncedIn;
    }

 

}
