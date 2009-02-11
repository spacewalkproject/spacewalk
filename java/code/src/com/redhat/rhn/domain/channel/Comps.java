package com.redhat.rhn.domain.channel;

import com.redhat.rhn.domain.BaseDomainHelper;

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
     * @param id The Id to set.
     */
    public void setId(Long id) {
        this.id = id;
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
     * @param relativeFilename The filename to set.
     */
    public void setRelativeFilename(String relativeFilename) {
        this.relativeFilename = relativeFilename;
    }

    /**
     * 
     * @param channel The channel to set.
     */
    public void setChannel(Channel channel) {
        this.channel = channel;
    }

    /**
     * 
     * @return Returns channel object
     */
    public Channel getChannel() {
        return channel;
    }
}
