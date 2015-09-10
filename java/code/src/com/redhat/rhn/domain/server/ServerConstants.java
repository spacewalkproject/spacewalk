/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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


/**
 * ServerConstants
 * @version $Rev$
 */
public class ServerConstants {
    /**
     * Feature constant for kickstarts
     */
    public static final String FEATURE_KICKSTART = "ftr_kickstart";

    private ServerConstants() {

    }

    /**
     * The constant representing the i686 ServerArch
     * @return ServerArch
     */
    public static final ServerArch getArchI686() {
        return ServerFactory.lookupServerArchByLabel("i686-redhat-linux");
    }
    /**
     * The constant representing the athlon ServerArch
     * @return ServerArch
     */
    public static final ServerArch getArchATHLON() {
        return ServerFactory.lookupServerArchByLabel("athlon-redhat-linux");
    }

    /**
     * Static representing the enterprise_entitled ServerGroup
     * @return ServerGroupType
     */
    public static final ServerGroupType getServerGroupTypeEnterpriseEntitled() {
       return  ServerFactory.lookupServerGroupTypeByLabel("enterprise_entitled");
    }

    /**
     * Static representing the provisioning entitled server group type
     * @return ServerGroupType
     */
    public static final ServerGroupType getServerGroupTypeVirtualizationEntitled() {
        return ServerFactory.lookupServerGroupTypeByLabel("virtualization_host");
    }
}
