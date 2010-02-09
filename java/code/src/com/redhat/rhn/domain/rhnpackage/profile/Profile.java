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
package com.redhat.rhn.domain.rhnpackage.profile;

import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.Identifiable;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.org.Org;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

import java.util.Set;

/**
 * Profile
 * @version $Rev$
 */
public class Profile extends BaseDomainHelper implements Identifiable {
    
    private Long id;
    private String name;
    private String description;
    private String info;
    private Org org;
    private Channel baseChannel;
    private ProfileType profileType;
    private Set packageEntries;
    

    /**
     * Default constructor
     */
    public Profile() {
    }
    
    /**
     * Constructs a Profile of the given type.
     * @param type Type of profile desired.
     */
    public Profile(ProfileType type) {
        profileType = type;
    }

    /**
     * @return Returns the baseChannel.
     */
    public Channel getBaseChannel() {
        return baseChannel;
    }
    
    /**
     * @param b The baseChannel to set.
     */
    public void setBaseChannel(Channel b) {
        this.baseChannel = b;
    }
    
    /**
     * @return Returns the description.
     */
    public String getDescription() {
        return description;
    }
    
    /**
     * @param d The description to set.
     */
    public void setDescription(String d) {
        this.description = d;
    }
    
    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }
    
    /**
     * @param i The id to set.
     */
    public void setId(Long i) {
        this.id = i;
    }
    
    /**
     * @return Returns the info.
     */
    public String getInfo() {
        return info;
    }
    
    /**
     * @param i The info to set.
     */
    public void setInfo(String i) {
        this.info = i;
    }
    
    /**
     * @return Returns the name.
     */
    public String getName() {
        return name;
    }
    
    /**
     * @param n The name to set.
     */
    public void setName(String n) {
        this.name = n;
    }
    
    /**
     * @return Returns the org.
     */
    public Org getOrg() {
        return org;
    }
    
    /**
     * @param o The org to set.
     */
    public void setOrg(Org o) {
        this.org = o;
    }
    
    /**
     * @return Returns the profileType.
     */
    public ProfileType getProfileType() {
        return profileType;
    }
    
    /**
     * @param p The profileType to set.
     */
    public void setProfileType(ProfileType p) {
        this.profileType = p;
    }
    
    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof Profile)) {
            return false;
        }
        Profile castOther = (Profile) other;
        return new EqualsBuilder().append(id, castOther.id)
                                  .append(name, castOther.name)
                                  .append(description, castOther.description)
                                  .append(info, castOther.info)
                                  .append(org, castOther.org)
                                  .append(baseChannel, castOther.baseChannel)
                                  .append(profileType, castOther.profileType)
                                  .isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(id)
                                    .append(name)
                                    .append(description)
                                    .append(info)
                                    .append(org)
                                    .append(baseChannel)
                                    .append(profileType)
                                    .toHashCode();
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return new ToStringBuilder(this).append("id", id).append("name", name).toString();
    }

    
    /**
     * @return Returns the packageEntries.
     */
    public Set getPackageEntries() {
        return packageEntries;
    }

    
    /**
     * @param packageEntriesIn The packageEntries to set.
     */
    public void setPackageEntries(Set packageEntriesIn) {
        this.packageEntries = packageEntriesIn;
    }

}
