package com.redhat.rhn.domain.channel;

import com.redhat.rhn.domain.BaseDomainHelper;

public class Comps extends BaseDomainHelper {

    private Long id;
    private String relativeFilename;
    private Channel channel;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getRelativeFilename() {
        return relativeFilename;
    }

    public void setRelativeFilename(String relativeFilename) {
        this.relativeFilename = relativeFilename;
    }

    public void setChannel(Channel channel) {
        this.channel = channel;
    }

    public Channel getChannel() {
        return channel;
    }
}
