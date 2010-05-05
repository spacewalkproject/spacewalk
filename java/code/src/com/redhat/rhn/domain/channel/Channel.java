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

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;
import org.apache.log4j.Logger;

import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.common.ChecksumType;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.system.IncompatibleArchException;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * Channel
 * @version $Rev$
 */
public class Channel extends BaseDomainHelper implements Comparable {

    /**
     * Logger for this class
     */
    private static Logger log = Logger.getLogger(Channel.class);
    public static final String PUBLIC = "public";
    public static final String PROTECTED = "protected";
    public static final String PRIVATE = "private";

    private static List<String> releaseToSkipRepodata = new ArrayList<String>(Arrays
            .asList("2.1AS", "2.1ES", "2.1WS", "3AS", "3ES", "3WS", "3Desktop", "4AS",
                    "4ES", "4WS", "4Desktop"));
    private static List<String> archesToSkipRepodata = new ArrayList<String>(Arrays
            .asList("channel-sparc-sun-solaris", "channel-i386-sun-solaris", 
                    "channel-sparc"));
    private String baseDir;
    private ChannelArch channelArch;
    private ChecksumType checksumType;

    private String description;
    private Date endOfLife;
    private String GPGKeyUrl;
    private String GPGKeyId;
    private String GPGKeyFp;
    private Long id;
    private String label;
    private Date lastModified;
    private String name;
    private String access = PRIVATE;
    private Org org;
    private Channel parentChannel;
    private ChannelProduct product;
    private ProductName productName;
    private Comps comps;
    private String summary;
    private Set erratas = new HashSet();
    private Set packages = new HashSet();
    private Set<ContentSource> sources =  new HashSet<ContentSource>();
    private Set channelFamilies = new HashSet();
    private Set distChannelMaps = new HashSet();
    private Set trustedOrgs = new HashSet();
    private String maintainerName;
    private String maintainerEmail;
    private String maintainerPhone;
    private String supportPolicy;        
    
    /**
     * @param orgIn what org you want to know if it is globally subscribable in
     * @return Returns whether or not this channel is globally subscribable.
     */
    public boolean isGloballySubscribable(Org orgIn) {
        return ChannelFactory.isGloballySubscribable(orgIn, this);
    }

    /**
     * Sets the globally subscribable attribute for this channel
     * @param orgIn what org you want to set if it is globally subscribable in
     * @param value True if you want the channel to be globally subscribable,
     * false if not.
     */
    public void setGloballySubscribable(boolean value, Org orgIn) {
        ChannelFactory.setGloballySubscribable(orgIn, this, value);
    }

    /**
     * Returns true if this Channel is a satellite channel.
     * @return true if this Channel is a satellite channel.
     */
    public boolean isSatellite() {
        return getChannelFamily().getLabel().startsWith(
                ChannelFamilyFactory.SATELLITE_CHANNEL_FAMILY_LABEL);
    }

    /**
     * Returns true if this Channel is a Proxy channel.
     * @return true if this Channel is a Proxy channel.
     */
    public boolean isProxy() {
        ChannelFamily cfam = getChannelFamily();

        if (cfam != null) {
            return cfam.getLabel().startsWith(
                    ChannelFamilyFactory.PROXY_CHANNEL_FAMILY_LABEL);
        }
        else {
            return false;
        }
    }

    /**
     * @return Returns the baseDir.
     */
    public String getBaseDir() {
        return baseDir;
    }

    /**
     * @param b The baseDir to set.
     */
    public void setBaseDir(String b) {
        this.baseDir = b;
    }

    /**
     * @return Returns the channelArch.
     */
    public ChannelArch getChannelArch() {
        return channelArch;
    }

    /**
     * @param c The channelArch to set.
     */
    public void setChannelArch(ChannelArch c) {
        this.channelArch = c;
    }
    
    /**
     * @return Returns the channelChecksum.
     */
    public ChecksumType getChecksumType() {
        return checksumType;
    }

    /**
     * @param checksumTypeIn The checksum to set.
     */
    public void setChecksumType(ChecksumType checksumTypeIn) {
        this.checksumType = checksumTypeIn;
    }


    /**
     * @param compsIn The Comps to set.
     */
    public void setComps(Comps compsIn) {
        this.comps = compsIn;
    }

    /**
     * @return Returns the Comps.
     */
    public Comps getComps() {
        return comps;
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
     * @return Returns the endOfLife.
     */
    public Date getEndOfLife() {
        return endOfLife;
    }

    /**
     * @param e The endOfLife to set.
     */
    public void setEndOfLife(Date e) {
        this.endOfLife = e;
    }

    /**
     * @return Returns the gPGKeyFp.
     */
    public String getGPGKeyFp() {
        return GPGKeyFp;
    }

    /**
     * @param k The gPGKeyFP to set.
     */
    public void setGPGKeyFp(String k) {
        GPGKeyFp = k;
    }

    /**
     * @return Returns the gPGKeyId.
     */
    public String getGPGKeyId() {
        return GPGKeyId;
    }

    /**
     * @param k The gPGKeyId to set.
     */
    public void setGPGKeyId(String k) {
        GPGKeyId = k;
    }

    /**
     * @return Returns the gPGKeyUrl.
     */
    public String getGPGKeyUrl() {
        return GPGKeyUrl;
    }

    /**
     * @param k The gPGKeyUrl to set.
     */
    public void setGPGKeyUrl(String k) {
        GPGKeyUrl = k;
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
     * @return Returns the label.
     */
    public String getLabel() {
        return label;
    }

    /**
     * @param l The label to set.
     */
    public void setLabel(String l) {
        this.label = l;
    }

    /**
     * @return Returns the lastModified.
     */
    public Date getLastModified() {
        return lastModified;
    }

    /**
     * @param l The lastModified to set.
     */
    public void setLastModified(Date l) {
        this.lastModified = l;
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
     * @return Returns the parentChannel.
     */
    public Channel getParentChannel() {
        return parentChannel;
    }

    /**
     * @param p The parentChannel to set.
     */
    public void setParentChannel(Channel p) {
        this.parentChannel = p;
    }

    /**
     * @return Returns the summary.
     */
    public String getSummary() {
        return summary;
    }

    /**
     * @param s The summary to set.
     */
    public void setSummary(String s) {
        this.summary = s;
    }

    /**
     * @return Returns the set of erratas for this channel.
     */
    public Set getErratas() {
        return erratas;
    }

    /**
     * Sets the erratas set for this channel
     * @param erratasIn The set of erratas
     */
    public void setErratas(Set erratasIn) {
        this.erratas = erratasIn;
    }

    /**
     * Adds a single errata to the channel
     * @param errataIn The errata to add
     */
    public void addErrata(Errata errataIn) {
        erratas.add(errataIn);
    }

    /**
     * @deprecated
     * @return Returns the set of packages for this channel.
     */
    public Set getPackages() {
        return packages;
    }

    /**
     * @return Returns the size of the package set for this channel.
     */
    public int getPackageCount() {
        // we don;t want to use packages.size()
        // this could be a lot (we don't want to load all the packages
        // in Rhn-server to get a single number) ...
        // So we are better off using a hibernate query for the count...
        return ChannelFactory.getPackageCount(this);
    }
    
    /**
     * @return Returns the size of the package set for this channel.
     */
    public int getErrataCount() {
        return ChannelFactory.getErrataCount(this);
    }
    

    /**
     * Sets the packages set for this channel
     * @param packagesIn The set of erratas
     */
    public void setPackages(Set packagesIn) {
        this.packages = packagesIn;
    }
    
    /**
     * 
     * @param sourcesIn The set of yum repo sources
     */
    public void setSources(Set<ContentSource> sourcesIn) {
        this.sources = sourcesIn;
    }
    
    /**
     *    
     * @return set of yum repos for this channel
     */
    public Set<ContentSource> getSources() {
        return sources;
    }
    

    /**
     * Adds a single package to the channel
     * @param packageIn The package to add
     * @deprecated
     */
    public void addPackage(Package packageIn) {
        if (!getChannelArch().isCompatible(packageIn.getPackageArch())) {
            throw new IncompatibleArchException(packageIn.getPackageArch(),
                    getChannelArch());
        }
        packages.add(packageIn);
    }

    /**
     * Adds a single package to the channel
     * @param packageIn The package to add
     * @param user the user doign the add
     */
    public void addPackage(Package packageIn, User user) {
        if (!getChannelArch().isCompatible(packageIn.getPackageArch())) {
            throw new IncompatibleArchException(packageIn.getPackageArch(),
                    getChannelArch());
        }
        List<Long> list = new ArrayList<Long>();
        list.add(packageIn.getId());
        ChannelManager.addPackages(this, list, user);
    }


    /**
     * Removes a single package from the channel
     * @param user the user doing the remove
     * @param packageIn The package to remove
     */
    public void removePackage(Package packageIn, User user) {
            List<Long> list = new ArrayList<Long>();
            list.add(packageIn.getId());
            ChannelManager.removePackages(this, list, user);
    }

    /**
     * Some methods for hibernate to get and set channel families. However,
     * there should be only one channel family per channel.
     */

    /**
     * @return Returns the set of channelFamiliess for this channel.
     */
    public Set getChannelFamilies() {
        return channelFamilies;
    }

    /**
     * Sets the channelFamilies set for this channel
     * @param channelFamiliesIn The set of channelFamilies
     */
    public void setChannelFamilies(Set channelFamiliesIn) {
        if (channelFamiliesIn.size() > 1) {
            throw new TooManyChannelFamiliesException(this.getId(),
                    "A channel can only have one channel family");
        }
        this.channelFamilies = channelFamiliesIn;
    }

    /**
     * 
     * @param trustedOrgsIn set of trusted orgs for this channel
     */
    public void setTrustedOrgs(Set<Org> trustedOrgsIn) {
        this.trustedOrgs = trustedOrgsIn;
    }

    /**
     * 
     * @return set of trusted orgs for this channel
     */
    public Set<Org> getTrustedOrgs() {
        return this.trustedOrgs;
    }

    /**
     * @return number of trusted organizations that have access to this channel
     */
    public int getTrustedOrgsCount() {
        if (trustedOrgs != null) {
            return trustedOrgs.size();
        }
        else {
            return 0;
        }
    }

    /**
     * Adds a single channelFamily to the channel
     * @param channelFamilyIn The channelFamily to add
     */
    public void addChannelFamily(ChannelFamily channelFamilyIn) {
        if (this.getChannelFamilies().size() > 0) {
            throw new TooManyChannelFamiliesException(this.getId(),
                    "A channel can only have one channel family");
        }
        channelFamilies.add(channelFamilyIn);
    }

    /**
     * Set the channel family for this channel.
     * @param channelFamilyIn The channelFamily to add
     */
    public void setChannelFamily(ChannelFamily channelFamilyIn) {
        channelFamilies.clear();
        this.addChannelFamily(channelFamilyIn);
    }

    /**
     * Get the channel family for this channel.
     * @return the channel's family, or null if none found
     */
    public ChannelFamily getChannelFamily() {
        if (this.getChannelFamilies().size() == 1) {
            Object[] cfams = this.getChannelFamilies().toArray();
            return (ChannelFamily) cfams[0];
        }

        return null;
    }

    /**
     * Returns true if this channel is considered a base channel.
     * @return true if this channel is considered a base channel.
     */
    public boolean isBaseChannel() {
        return (getParentChannel() == null);
    }

    /**
     * Returns true if this channel is a cloned channel.
     * @return whether the channel is cloned or not
     */
    public boolean isCloned() {
        return false;
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof Channel)) {
            return false;
        }
        Channel castOther = (Channel) other;

        return new EqualsBuilder().append(getId(), castOther.getId()).isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(getId()).toHashCode();
    }

    /**
     * @return Returns the product.
     */
    public ChannelProduct getProduct() {
        return product;
    }

    /**
     * @param productIn The product to set.
     */
    public void setProduct(ChannelProduct productIn) {
        this.product = productIn;
    }

    /**
     * @return Returns the distChannelMaps.
     */
    public Set<DistChannelMap> getDistChannelMaps() {
        return distChannelMaps;
    }

    /**
     * @param distChannelMapsIn The distChannelMaps to set.
     */
    public void setDistChannelMaps(Set distChannelMapsIn) {
        this.distChannelMaps = distChannelMapsIn;
    }

    /**
     * Check if this channel is subscribable by the Org passed in. Checks:
     * 
     * 1) If channel is a Proxy or Spacewalk channel == false 2) If channel has
     * 0 (or less) available subscriptions == false.
     * 
     * @param orgIn to check available subs
     * @param server to check if subscribable
     * @return boolean if subscribable or not
     */
    public boolean isSubscribable(Org orgIn, Server server) {

        if (log.isDebugEnabled()) {
            log.debug("isSubscribable.archComp: " +
                    SystemManager.verifyArchCompatibility(server, this));
            log.debug("isProxy: " + this.isProxy());
            log.debug("isSatellite: " + this.isSatellite());
        }

        return (SystemManager.verifyArchCompatibility(server, this) &&
                !this.isProxy() && !this
                .isSatellite());
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return new ToStringBuilder(this).append("id", id).append("label", label).toString();
    }

    /**
     * @return the productName
     */
    public ProductName getProductName() {
        return productName;
    }

    /**
     * @param productNameIn the productName to set
     */
    public void setProductName(ProductName productNameIn) {
        this.productName = productNameIn;
    }

    /**
     * Returns true if the access provided is a valid value.
     * @param acc the access value being checked
     * @return true if the access provided is valid
     */
    public boolean isValidAccess(String acc) {
        if (acc.equals(Channel.PUBLIC) || acc.equals(Channel.PRIVATE) ||
                acc.equals(Channel.PROTECTED)) {
            return true;
        }
        return false;
    }

    /**
     *@param acc public, protected, or private
     */
    public void setAccess(String acc) {
        access = acc;
    }

    /**
     * @return public, protected, or private
     */
    public String getAccess() {
        return access;
    }

    /**
     * 
     * @return wheter channel is protected
     */
    public boolean isProtected() {
        return this.getAccess().equals(Channel.PROTECTED);
    }

    /**
     * Returns the child channels associated to a base channel
     * @param user the User needed for accessibility issues
     * @return a list of child channels or empty list if there are none.
     */
    public List<Channel> getAccessibleChildrenFor(User user) {
        if (isBaseChannel()) {
            return ChannelFactory.getAccessibleChildChannels(this, user);
        }
        return Collections.EMPTY_LIST;
    }

    /**
     * {@inheritDoc}
     */
    public int compareTo(Object o) {
        return this.getName().compareTo(((Channel) o).getName());
    }

    /**
     * @return maintainer's name
     */
    public String getMaintainerName() {
        return maintainerName;
    }

    /**
     * @return maintainer's email
     */
    public String getMaintainerEmail() {
        return maintainerEmail;
    }

    /**
     * @return maintainer's phone number
     */
    public String getMaintainerPhone() {
        return maintainerPhone;
    }

    /**
     * @return channel's support policy
     */
    public String getSupportPolicy() {
        return supportPolicy;
    }

    /**
     * @param mname maintainer's name
     */
    public void setMaintainerName(String mname) {
        maintainerName = mname;
    }

    /**
     * @param email maintainer's email
     */
    public void setMaintainerEmail(String email) {
        maintainerEmail = email;
    }

    /**
     * @param phone maintainer's phone number (string)
     */
    public void setMaintainerPhone(String phone) {
        maintainerPhone = phone;
    }

    /**
     * @param policy channel support policy
     */
    public void setSupportPolicy(String policy) {
        supportPolicy = policy;
    }

    /**
     * Created for taskomatic -- probably shouldn't be called from the webui
     * @return returns if custom channel
     */
    public boolean isCustom() {
        return getOrg() != null;
    }

    /**
     * does this Channel need repodata generated for it Criteria: 1. All custom
     * channels need repodata 2. RH channels need it if: They are made by RH The
     * top-most channel in their hierarchy (yes we currently only have 1 level
     * deep, but you know what assumptions make...) has a 'minor' version of 5
     * or higher Note: This makes an assumption that taxonomy will work the way
     * that it continues to work, or at least that version.compareTo will remain
     * valid and function only on minor version
     * @return Returns a boolena if repodata generation Required
     */
    public boolean isChannelRepodataRequired() {
        boolean repodataRequired = false;
        // generate repodata for all custom channels except solaris
        if (this.isCustom() &&
                !archesToSkipRepodata.contains(this.channelArch.getLabel())) {
            repodataRequired = true;
            log.debug("isChannelRepodataRequired for channel(" + this.id +
                    ") set to true because it is a custom Channel");
        }

        // Walk to the top of the tree
        Channel toConsider = this;
        while (toConsider.getParentChannel() != null) {
            toConsider = toConsider.getParentChannel();
        }

        String release = null;
        DistChannelMap channelDist = ChannelFactory.lookupDistChannelMap(toConsider);
        if (channelDist != null) {
            release = channelDist.getRelease();
        } 
        else { // and now again for zstreams
            ReleaseChannelMap channelRelease = 
                ChannelFactory.lookupDefaultReleaseChannelMapForChannel(toConsider);
            if (channelRelease != null) {
                release = channelRelease.getRelease();
            }
        }
        if (release != null) {
            if (!releaseToSkipRepodata.contains(release)) {
                repodataRequired = true;
                log.debug("isChannelRepodataRequired for channel(" + this.id + ") " +
                        "set to true because top level parent has a release of " + release);
            }
            else {
                log.debug("isChannelRepodataRequired for channel(" + this.id + ") " +
                        "set to false because we have'nt met the minimum release");
            }
        }

        log.debug("isChannelRepodataRequired for channel(" + this.id + ") = " +
                repodataRequired);
        return repodataRequired;
    }

    /**
     * true if the channel contains any kickstartstartable distros
     * @return true if the channel contains any distros.
     */
    public boolean containsDistributions() {
        return ChannelFactory.containsDistributions(this);
    }
        
    /**
     * 
     * @param sourceIn source repo to add 
     */
    public void addYumContentSource(ContentSource sourceIn) {
        this.getSources().add(sourceIn);
        ChannelFactory.save(this);
    }
    
    /**
     * get the compatible checksum type to be used for repomd.xml
     * based on channel release. 
     * If its a custom channel use the checksum_type_id from db set at creation time
     * If its RHEL-5 we use sha1 anything newer will be sha256.
     * @return checksumType
     */
    public String getChecksumTypeLabel() {
        
        if ((checksumType == null) || (checksumType.getLabel() == null)) {
            // each channel shall have set checksumType
            return null;
        }
        return checksumType.getLabel();
    }
}
