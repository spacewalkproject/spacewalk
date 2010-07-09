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
package com.redhat.rhn.frontend.dto;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;




/**
 *
 * OrgDto class represents Org lists
 * @version $Rev$
 */
public class OrgDto extends BaseDto {
    private Long id;
    private String name;
    private Long systems;
    private Long trusts;
    private Long users;
    private Long activationKeys;
    private Long kickstartProfiles;
    private Long serverGroups;
    private Long configChannels;

    /**
     *
     * {@inheritDoc}
     */
    public Long getId() {
        return id;
    }

    /**
     *
     * @param idIn OrgIn Id
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     *
     * @return Name of Org
     */
    public String getName() {
        return name;
    }

    /**
     *
     * @param nameIn of Org to set
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /**
     *
     * @return number of systems
     */
    public Long getSystems() {
        return systems;
    }

    /**
     *
     * @param systemsIn number to set
     */
    public void setSystems(Long systemsIn) {
        this.systems = systemsIn;
    }

    /**
     *
     * @return number of trusts
     */
    public Long getTrusts() {
        return trusts;
    }

    /**
     *
     * @param trustsIn number to set
     */
    public void setTrusts(Long trustsIn) {
        this.trusts = trustsIn;
    }

    /**
     *
     * @return number of users
     */
    public Long getUsers() {
        return users;
    }

    /**
     *
     * @param usersIn to set
     */
    public void setUsers(Long usersIn) {
        this.users = usersIn;
    }


    /**
     * @return the activationKeys
     */
    public Long getActivationKeys() {
        return activationKeys;
    }


    /**
     * @param keys the activationKeys to set
     */
    public void setActivationKeys(Long keys) {
        this.activationKeys = keys;
    }


    /**
     * @return the kickstartProfiles
     */
    public Long getKickstartProfiles() {
        return kickstartProfiles;
    }


    /**
     * @param ksProfiles the kickstartProfiles to set
     */
    public void setKickstartProfiles(Long ksProfiles) {
        this.kickstartProfiles = ksProfiles;
    }


    /**
     * @return the serverGroups
     */
    public Long getServerGroups() {
        return serverGroups;
    }


    /**
     * @param groups the serverGroups to set
     */
    public void setServerGroups(Long groups) {
        this.serverGroups = groups;
    }


    /**
     * @return the configChannels
     */
    public Long getConfigChannels() {
        return configChannels;
    }


    /**
     * @param channels the configChannels to set
     */
    public void setConfigChannels(Long channels) {
        this.configChannels = channels;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean equals(Object o) {
        if (o == this) {
            return true;
        }
        if (!(o instanceof OrgDto)) {
            return false;
        }
        OrgDto that = (OrgDto) o;
        EqualsBuilder b = new EqualsBuilder();
        b.append(this.getId(), that.getId());
        b.append(this.getName(), that.getName());
        return b.isEquals();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public int hashCode() {
        HashCodeBuilder b = new HashCodeBuilder();
        b.append(getId()).append(getName());
        return b.toHashCode();
    }

}
