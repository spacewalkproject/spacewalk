/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.satellite.search.db.models;

/**
 * Server
 * @version $Rev$
 */
public class Server {

    private long id;
    private String name;
    private String info;
    private String description;

    /**
    private String snapshotTagName;

    private Long channelId;
    private Long securityErrata;
    private Long bugErrata;
    private Long enhancementErrata;
    private Long outdatedPackages;
    private String serverName;
    private Long serverAdmins;
    private Long groupCount;
    private Long noteCount;
    private Date modified;
    private String channelLabels;
    private Long historyCount;
    private Long lastCheckinDaysAgo;
    private Long pendingUpdates;

    private String nameOfUserWhoRegisteredSystem;
    private String os;
    private String release;
    private String serverArchName;
    private Date lastCheckin;
    private Date created;
    private Long locked;
    private String monitoringStatus;

    private List status;
    private List actionId;
    private boolean rhnSatellite;
    private boolean rhnProxy;
    private List entitlement;
    private List serverGroupTypeId;
    private List entitlementPermanent;
    private List entitlementIsBase;
    private boolean selectable;
    private String statusDisplay;
    private String lastCheckinString;
    private boolean isVirtualHost;
    private boolean isVirtualGuest;
    **/


    /**
     * @return the id
     */
    public long getId() {
        return id;
    }

    /**
     * @param idIn the id to set
     */
    public void setId(long idIn) {
        this.id = idIn;
    }

    /**
     * @return the name
     */
    public String getName() {
        return name;
    }
    /**
     * @param nameIn the name to set
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /**
     * @return the info
     */
    public String getInfo() {
        return info;
    }

    /**
     * @param infoIn the info to set
     */
    public void setInfo(String infoIn) {
        this.info = infoIn;
    }

    /**
     * @return the description
     */
    public String getDescription() {
        return description;
    }

    /**
     * @param descriptionIn the description to set
     */
    public void setDescription(String descriptionIn) {
        this.description = descriptionIn;
    }
}
