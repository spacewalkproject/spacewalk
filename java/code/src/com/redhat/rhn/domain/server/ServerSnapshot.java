/**
 * Copyright (c) 2009--2015 Red Hat, Inc.
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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.PackageNevra;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.frontend.dto.PackageMetadata;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.commons.lang.builder.HashCodeBuilder;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
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
    private Set<Channel> channels = new HashSet<Channel>();
    private Set<ConfigChannel> configChannels = new HashSet<ConfigChannel>();
    private Set<ConfigRevision> configRevisions = new HashSet<ConfigRevision>();
    private Set<ServerGroup> groups = new HashSet<ServerGroup>();
    private Set<PackageNevra> packages = new HashSet<PackageNevra>();
    private InvalidSnapshotReason invalidReason;
    private static final DateFormat DF = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

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
     * adds tag to the snapshot
     * @param tagName name of the tag
     * @return true if tag was added to snapshot
     */
    public boolean addTag(String tagName) {
        for (SnapshotTag tag : getTags()) {
            if (tagName.equals(tag.getName().getName())) {
                return false;
            }
        }
        ServerFactory.addTagToSnapshot(getId(), getOrg().getId(), tagName);
        return true;
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

    /**
     * @return Returns date in format yyyy-MM-dd HH:mm:ss so it can be used as a name
     */
    public String getName() {
        return DF.format(this.getCreated());
    }

    /**
     * counts number of group diffs between server and snapshot
     * @param sid server id
     * @return number of differences
     */
    public int groupDiffs(Long sid) {
        return getDiffs(sid, "SystemGroup_queries", "snapshot_group_diff");
    }

    /**
     * counts number of channel diffs between server and snapshot
     * @param sid server id
     * @return number of differences
     */
    public int channelDiffs(Long sid) {
        return getDiffs(sid, "Channel_queries", "snapshot_channel_diff");
    }

    /**
     * counts number of package diffs between server and snapshot
     * @param sid server id
     * @return number of differences
     */
    public int packageDiffs(Long sid) {
        return getDiffs(sid, "Package_queries", "compare_packages_to_snapshot");
    }

    /**
     * counts number of config channel diffs between server and snapshot
     * @param sid server id
     * @return number of differences
     */
    public int configChannelsDiffs(Long sid) {
        return getDiffs(sid, "config_queries", "snapshot_configchannel_diff");
    }

    /**
     * private function to retrieve number of diffs from database
     * @param sid server id
     * @param name filename for ModeFactory.getMode()
     * @param mode query name for ModeFactory.getMode()
     * @return number of differences
     */
    private int getDiffs(Long sid, String name, String mode) {
        SelectMode m = ModeFactory.getMode(name, mode);
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("ss_id", id);
        params.put("sid", sid);
        DataResult dr = m.execute(params);

        return dr.size();
    }

    /**
     * cancel pending action on system (needed fo rollback)
     */
    public void cancelPendingActions() {
        ActionFactory.cancelPendingForSystem(this.server.getId());
    }

    /**
     * rollback server channels to snapshot
     */
    public void rollbackChannels() {
        // unsubscribe from all channels
        DataResult<Map<String, Object>> chs = SystemManager.channelsForServer(
                                                                        this.server);
        for (Map<String, Object> ch : chs) {
            SystemManager.unsubscribeServerFromChannel(this.server.getId(),
                                                       (Long) ch.get("id"));
        }
        // subscribe to appropriate channels
        chs = snapshotChannelList();
        for (Map<String, Object> ch : chs) {
            SystemManager.subscribeServerToChannel(null, this.server,
                                ChannelFactory.lookupById((Long) ch.get("id")));
        }
    }

    /**
     * rollback server groups to snapshot
     */
    public void rollbackGroups() {
        // remove from all groups
        Long sid = this.server.getId();
        DataResult<Map<String, Object>> grps = SystemManager.listSystemGroups(sid);
        for (Map<String, Object> grp : grps) {
            ServerFactory.removeServerFromGroup(sid, (Long) grp.get("id"));
        }
        // add to appropriate groups
        for (ServerGroup grp : getGroups()) {
            ServerFactory.addServerToGroup(this.server, grp);
        }
    }

    /**
     * rollback server packages to snapshot
     * @param user who schedules file deployment
     * @return true if package update has been scheduled
     */
    public boolean rollbackPackages(User user) {
        // schedule package delta, if needed
        if (packageDiffs(this.server.getId()) > 0) {
            DataResult pkgs = preparePackagesForSync();
            PackageAction action =
                    ActionManager.schedulePackageRunTransaction(
                                            user, this.server, pkgs, new Date());
            return true;
        }
        return false;
    }

    /**
     * rollback server chonfig files to snapshot
     * @param user who schedules file deployment
     * @return true if any config files has been deployed
     */
    public boolean rollbackConfigFiles(User user) {
        boolean deployed = false;
        // current config_channels
        Set<ConfigChannel> ccs = new HashSet<ConfigChannel>(
                                                this.server.getConfigChannels());
        if (ccs != null) {
            for (ConfigChannel cc : ccs) {
                if (cc.isGlobalChannel()) {
                    this.server.unsubscribe(cc);
                }
            }
        }
        // get the config_channels recorded from the snapshot
        ccs = getConfigChannels();
        // tie config_channel list to server
        if (ccs != null) {
            for (ConfigChannel cc : ccs) {
                if (cc.isGlobalChannel()) {
                    this.server.subscribe(cc);
                }
            }
        }
        // deploy the particular config files
        Set<ConfigRevision> revs = getConfigRevisions();
        if (revs != null) {
            List<Long> revLongs = new ArrayList<Long>();
            for (ConfigRevision rev : revs) {
                revLongs.add(rev.getId());
                deployed = true;
            }
            List<Long> serverIds = new ArrayList<Long>();
            serverIds.add(this.server.getId());
            Action action = ActionManager.createConfigAction(user, revLongs, serverIds,
                                  ActionFactory.TYPE_CONFIGFILES_DEPLOY, new Date());
        }
        return deployed;
    }

    /**
     * list of channel associated with snapshot
     * @return Returns a DataResult of maps representing channels
     */
    public DataResult<Map<String, Object>> snapshotChannelList() {
       Map<String, Long> params = new HashMap<String, Long>();
       params.put("sid", server.getId());
       params.put("ss_id", this.id);
       SelectMode m = ModeFactory.getMode("Channel_queries",
                                          "system_snapshot_channel_list", Map.class);
       return m.execute(params);
    }

    @SuppressWarnings("rawtypes")
    private DataResult preparePackagesForSync() {
        SelectMode m = ModeFactory.getMode("Package_queries",
                "compare_packages_to_snapshot");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("sid", this.server.getId());
        params.put("ss_id", this.id);
        DataResult<Map<String, Object>> pkgsDiff = m.execute(params);

        List<PackageMetadata> pkgsMeta =  new ArrayList<PackageMetadata>();

        for (Map pkgDiff : pkgsDiff) {
            PackageListItem systemPkg   = new PackageListItem();
            systemPkg.setName((String) pkgDiff.get("package_name"));
            systemPkg.setArch((String) pkgDiff.get("arch"));
            systemPkg.setEpoch((String) pkgDiff.get("server_epoch"));
            systemPkg.setVersion((String) pkgDiff.get("server_version"));
            systemPkg.setRelease((String) pkgDiff.get("server_release"));

            PackageListItem snapshotPkg = new PackageListItem();
            snapshotPkg.setName((String) pkgDiff.get("package_name"));
            snapshotPkg.setArch((String) pkgDiff.get("arch"));
            snapshotPkg.setEpoch((String) pkgDiff.get("snapshot_epoch"));
            snapshotPkg.setVersion((String) pkgDiff.get("snapshot_version"));
            snapshotPkg.setRelease((String) pkgDiff.get("snapshot_release"));

            PackageMetadata pm = new PackageMetadata(systemPkg, snapshotPkg);
            int comparison;
            switch (((Number) pkgDiff.get("comparison")).intValue()) {
            case -2: comparison = PackageMetadata.KEY_OTHER_ONLY;
                     break;
            case -1: comparison = PackageMetadata.KEY_OTHER_NEWER;
                     break;
            case 1:  comparison = PackageMetadata.KEY_THIS_NEWER;
                     break;
            case 2:  comparison = PackageMetadata.KEY_THIS_ONLY;
                     break;
            default: comparison = PackageMetadata.KEY_NO_DIFF;
            }
            pm.setComparison(comparison);
            pm.updateActionStatus();
            pkgsMeta.add(pm);
        }
        DataResult<PackageMetadata> ret = new DataResult<PackageMetadata>(pkgsMeta);
        return ret;
    }

    /**
     * @return return list of unservable packages for snapshot
     */
    public DataResult<Map<String, Object>> getUnservablePackages() {
        return SystemManager.systemSnapshotUnservablePackages(org.getId(),
                server.getId(), id, null);
    }
}
