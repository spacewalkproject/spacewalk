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
package com.redhat.rhn.domain.server;

import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.PackageNevra;

import org.apache.commons.lang.builder.HashCodeBuilder;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 *
 * ServerSnapshot
 * @version $Rev$
 */
public class ServerSnapshot extends BaseDomainHelper {

    private Org org;
    private Server server;
    private Long id;
    private String reason;
    private Set<Channel> channels = new HashSet();
    private Set<ConfigChannel> configChannels = new HashSet();
    private Set<ConfigRevision> configRevisions = new HashSet();
    private Set<ServerGroup> groups = new HashSet();
    private Set<PackageNevra> packages = new HashSet();
    private InvalidSnapshotReason invalidReason;

    /**
     * @return Returns the channels.
     */
    public Set<Channel> getChannels() {
        return channels;
    }

    /**
     * @param channelsIn The channels to set.
     */
    public void setChannels(Set<Channel> channelsIn) {
        this.channels = channelsIn;
    }

    /**
     * @return Returns the configChannels.
     */
    public Set<ConfigChannel> getConfigChannels() {
        return configChannels;
    }

    /**
     * @param configChannelsIn The configChannels to set.
     */
    public void setConfigChannels(Set<ConfigChannel> configChannelsIn) {
        this.configChannels = configChannelsIn;
    }

    /**
     * @return Returns the configRevisions.
     */
    public Set<ConfigRevision> getConfigRevisions() {
        return configRevisions;
    }

    /**
     * @param configRevisionsIn The configRevisions to set.
     */
    public void setConfigRevisions(Set<ConfigRevision> configRevisionsIn) {
        this.configRevisions = configRevisionsIn;
    }


    /**
     * @return Returns the groups.
     */
    public Set<ServerGroup> getGroups() {
        return groups;
    }

    /**
     * Add a group to the snapshot
     * @param grp group to add
     */
    public void addGroup(ServerGroup grp) {
            groups.add(grp);
    }

    /**
     * @param groupsIn The groups to set.
     */
    public void setGroups(Set<ServerGroup> groupsIn) {
        this.groups = groupsIn;
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
     * @return Returns the org.
     */
    public Org getOrg() {
        return org;
    }

    /**
     * @param orgIn The org to set.
     */
    public void setOrg(Org orgIn) {
        this.org = orgIn;
    }

    /**
     * @return Returns the reason.
     */
    public String getReason() {
        return reason;
    }

    /**
     * @param reasonIn The reason to set.
     */
    public void setReason(String reasonIn) {
        this.reason = reasonIn;
    }


    /**
     * @return Returns the server.
     */
    public Server getServer() {
        return server;
    }


    /**
     * @param serverIn The server to set.
     */
    public void setServer(Server serverIn) {
        this.server = serverIn;
    }


    /**
     * @return Returns the packages.
     */
    public Set<PackageNevra> getPackages() {
        return packages;
    }


    /**
     * @param packagesIn The packages to set.
     */
    public void setPackages(Set<PackageNevra> packagesIn) {
        this.packages = packagesIn;
    }


    /**
     * @return Returns the invalidReason.
     */
    public InvalidSnapshotReason getInvalidReason() {
        return invalidReason;
    }


    /**
     * @param invalidReasonIn The invalidReason to set.
     */
    public void setInvalidReason(InvalidSnapshotReason invalidReasonIn) {
        this.invalidReason = invalidReasonIn;
    }


    /**
     * @return Returns the tags.
     */
    public List<SnapshotTag> getTags() {
        return ServerFactory.getSnapshotTags(this);
    }

    /**
     *
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(reason.hashCode())
                                    .append(channels.hashCode())
                                    .append(configChannels.hashCode())
                                    .append(configRevisions.hashCode())
                                    .append(server.hashCode())
                                    .append(groups.hashCode())
                                    .toHashCode();
    }

}
