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

import com.redhat.rhn.domain.kickstart.KickstartInstallType;

import java.util.HashMap;
import java.util.Map;

/**
 * Simple enum class to represent the RHEL version of a channel.
 * ChannelVersion
 * @version $Rev$
 */
public class ChannelVersion {

    private String name;
    private String version;

    public static final ChannelVersion LEGACY = new ChannelVersion(
            "RedHat Legacy Channels", "legacy");
    public static final ChannelVersion RHEL21 = new ChannelVersion(
            "Red Hat Enterprise Linux 2.1", "2.1");
    public static final ChannelVersion RHEL3 = new ChannelVersion(
            "Red Hat Enterprise Linux 3", "3");
    public static final ChannelVersion RHEL4 = new ChannelVersion(
            "Red Hat Enterprise Linux 4", "4");
    public static final ChannelVersion RHEL5 = new ChannelVersion(
            "Red Hat Enterprise Linux 5", "5");
    public static final ChannelVersion RHEL6 = new ChannelVersion(
            "Red Hat Enterprise Linux 6", "6");

    // Map kickstart install type labels to channel version constants.
    private static final Map KICKSTART_INSTALL_TYPE_TO_CHANNEL_VERSION = new HashMap();

    // Map releases to channel version constants. Anything not in this map
    // will be assumed to be legacy.
    public static final Map DIST_CHANNEL_MAP_TO_CHANNEL_VERSION = new HashMap();

    static {
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("5Client", ChannelVersion.RHEL5);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("5Server", ChannelVersion.RHEL5);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("4.92Client", ChannelVersion.RHEL5);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("4.92Server", ChannelVersion.RHEL5);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("4.91Client", ChannelVersion.RHEL5);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("4.91Server", ChannelVersion.RHEL5);

        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("4AS", ChannelVersion.RHEL4);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("4ES", ChannelVersion.RHEL4);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("4WS", ChannelVersion.RHEL4);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("4Desktop", ChannelVersion.RHEL4);

        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("4AS-shadow", ChannelVersion.RHEL4);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("4ES-shadow", ChannelVersion.RHEL4);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("4WS-shadow", ChannelVersion.RHEL4);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("4Desktop-shadow", ChannelVersion.RHEL4);

        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("3.93AS", ChannelVersion.RHEL4);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("3.93ES", ChannelVersion.RHEL4);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("3.93WS", ChannelVersion.RHEL4);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("3.93Desktop", ChannelVersion.RHEL4);

        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("3AS", ChannelVersion.RHEL3);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("3ES", ChannelVersion.RHEL3);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("3WS", ChannelVersion.RHEL3);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("3Desktop", ChannelVersion.RHEL3);

        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("3AS-shadow", ChannelVersion.RHEL3);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("3ES-shadow", ChannelVersion.RHEL3);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("3WS-shadow", ChannelVersion.RHEL3);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("3Desktop-shadow", ChannelVersion.RHEL3);

        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("2.1AS", ChannelVersion.RHEL21);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("2.1ES", ChannelVersion.RHEL21);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("2.1WS", ChannelVersion.RHEL21);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("2.1AW", ChannelVersion.RHEL21);
        DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.put("2.1ASDE", ChannelVersion.RHEL21);

        KICKSTART_INSTALL_TYPE_TO_CHANNEL_VERSION.put(KickstartInstallType.RHEL_21,
                ChannelVersion.RHEL21);
        KICKSTART_INSTALL_TYPE_TO_CHANNEL_VERSION.put(KickstartInstallType.RHEL_3,
                ChannelVersion.RHEL3);
        KICKSTART_INSTALL_TYPE_TO_CHANNEL_VERSION.put(KickstartInstallType.RHEL_4,
                ChannelVersion.RHEL4);
        KICKSTART_INSTALL_TYPE_TO_CHANNEL_VERSION.put(KickstartInstallType.RHEL_5,
                ChannelVersion.RHEL5);
    }

    /**
     * Private contructor, nobody should be instantiating one of these directly.
     *
     */
    protected ChannelVersion(String nameIn, String versionIn) {
        name = nameIn;
        version = versionIn;
    }

    /**
     * Returns the channel version constant for the given kickstart install
     * type, based on it's label and the contents of a static mapping.
     * @param type KickstartInstallType to lookup channel version for.
     * @return ChannelVersion for this KickstartInstallType.
     */
    public static ChannelVersion getChannelVersionForKickstartInstallType(
            KickstartInstallType type) {
        return (ChannelVersion)KICKSTART_INSTALL_TYPE_TO_CHANNEL_VERSION.get(
                type.getLabel());
    }

    /**
     * Returns the channel version constant for the given DistChannelMap,
     * based on the map's release and a static mapping.
     * @param dcm DistChannel map to lookup channel version for.
     * @return ChannelVersion for this DistChannelMap.
     */
    public static ChannelVersion getChannelVersionForDistChannelMap(
            DistChannelMap dcm) {
        if (DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.containsKey(dcm.getRelease())) {
            return ((ChannelVersion)DIST_CHANNEL_MAP_TO_CHANNEL_VERSION.get(
                    dcm.getRelease()));
        }
        return ChannelVersion.LEGACY;
    }



    /**
     * @return Returns the name.
     */
    public String getName() {
        return name;
    }


    /**
     * @param nameIn The name to set.
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }


    /**
     * @return Returns the version.
     */
    public String getVersion() {
        return version;
    }


    /**
     * @param versionIn The version to set.
     */
    public void setVersion(String versionIn) {
        this.version = versionIn;
    }

}
