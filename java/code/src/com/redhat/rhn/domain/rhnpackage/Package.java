/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.domain.rhnpackage;

import java.util.Date;
import java.util.HashSet;
import java.util.Set;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.common.Checksum;
import com.redhat.rhn.domain.errata.impl.PublishedErrata;
import com.redhat.rhn.domain.errata.impl.UnpublishedErrata;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rpm.SourceRpm;

/**
 * Package
 * @version $Rev$
 */
public class Package extends BaseDomainHelper {

    private Long id;
    private String rpmVersion;
    private String description;
    private String summary;
    private Long packageSize;
    private Long payloadSize;
    private String buildHost;
    private Date buildTime;
    private Checksum checksum;
    private String vendor;
    private String payloadFormat;
    private Long compat;
    private String path;
    private String headerSignature;
    private String copyright;
    private String cookie;
    private Date lastModified;
    private String sourcePath;
    private Set<PublishedErrata> publishedErrata = new HashSet<PublishedErrata>();
    private Set<UnpublishedErrata> unpublishedErrata = new HashSet<UnpublishedErrata>();
    private Set<Channel> channels = new HashSet<Channel>();
    private Set<PackageFile> packageFiles = new HashSet<PackageFile>();

    private Org org;
    private PackageName packageName;
    private PackageEvr packageEvr;
    private PackageGroup packageGroup;
    private SourceRpm sourceRpm;
    private PackageArch packageArch;
    private Set<PackageKey> packageKeys = new HashSet();

    private Long headerStart = new Long(0L);
    private Long headerEnd = new Long(0L);

    private Set<ChangeLogEntry> changeLog = new HashSet();
    private Set<PackageProvides> provides = new HashSet();
    private Set<PackageRequires> requires = new HashSet();
    private Set<PackageObsoletes> obsoletes = new HashSet();
    private Set<PackageConflicts> conflicts = new HashSet();

    /**
     * @return Returns the provides.
     */
    public Set<PackageProvides> getProvides() {
        return provides;
    }

    /**
     * @param providesIn The provides to set.
     */
    public void setProvides(Set<PackageProvides> providesIn) {
        this.provides = providesIn;
    }

    /**
     * @return Returns the changeLog
     */
    public Set<ChangeLogEntry> getChangeLog() {
        return changeLog;
    }

    /**
     * @param changeLogIn The ChangeLog to set
     */
    public void setChangeLog(Set<ChangeLogEntry> changeLogIn) {
        this.changeLog = changeLogIn;
    }

    /**
     * @param entry The ChangeLogEntry to add
     */
    public void addChangeLogEntry(ChangeLogEntry entry) {
        entry.setRhnPackage(this);
        changeLog.add(entry);
    }

    /**
     * Retrieves the file portion of the path. For example, if
     * path=/foo/bar/baz.rpm, getFile() would return 'baz.rpm'.
     * @return Returns the file portion of the path.
     */
    public String getFile() {
        String[] parts = StringUtils.split(getPath(), '/');
        if (parts != null && parts.length > 0) {
            return parts[parts.length - 1];
        }

        return null;
    }

    /**
     * @return Returns the buildHost.
     */
    public String getBuildHost() {
        return buildHost;
    }

    /**
     * @param b The buildHost to set.
     */
    public void setBuildHost(String b) {
        this.buildHost = b;
    }

    /**
     * @return Returns the buildTime.
     */
    public Date getBuildTime() {
        return buildTime;
    }

    /**
     * @param b The buildTime to set.
     */
    public void setBuildTime(Date b) {
        this.buildTime = b;
    }

    /**
     * @return Returns the compat.
     */
    public Long getCompat() {
        return compat;
    }

    /**
     * @param c The compat to set.
     */
    public void setCompat(Long c) {
        this.compat = c;
    }

    /**
     * @return Returns the cookie.
     */
    public String getCookie() {
        return cookie;
    }

    /**
     * @param c The cookie to set.
     */
    public void setCookie(String c) {
        this.cookie = c;
    }

    /**
     * @return Returns the copyright.
     */
    public String getCopyright() {
        return copyright;
    }

    /**
     * @param c The copyright to set.
     */
    public void setCopyright(String c) {
        this.copyright = c;
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
     * @return Returns the headerSignature.
     */
    public String getHeaderSignature() {
        return headerSignature;
    }

    /**
     * @param h The headerSig to set.
     */
    public void setHeaderSignature(String h) {
        this.headerSignature = h;
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
     * @return Returns the checksum.
     */
    public Checksum getChecksum() {
        return checksum;
    }

    /**
     * @param checksumIn The checksum to set.
     */
    public void setChecksum(Checksum checksumIn) {
        this.checksum = checksumIn;
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
     * @return Returns the packageArch.
     */
    public PackageArch getPackageArch() {
        return packageArch;
    }

    /**
     * @param p The packageArch to set.
     */
    public void setPackageArch(PackageArch p) {
        this.packageArch = p;
    }

    /**
     * @return Returns the packageEvr.
     */
    public PackageEvr getPackageEvr() {
        return packageEvr;
    }

    /**
     * @param p The packageEvr to set.
     */
    public void setPackageEvr(PackageEvr p) {
        this.packageEvr = p;
    }

    /**
     * @return Returns the packageGroup.
     */
    public PackageGroup getPackageGroup() {
        return packageGroup;
    }

    /**
     * @param p The packageGroup to set.
     */
    public void setPackageGroup(PackageGroup p) {
        this.packageGroup = p;
    }

    /**
     * @return Returns the packageName.
     */
    public PackageName getPackageName() {
        return packageName;
    }

    /**
     * @param p The packageName to set.
     */
    public void setPackageName(PackageName p) {
        this.packageName = p;
    }

    /**
     * @return Returns the packageSize.
     */
    public Long getPackageSize() {
        return packageSize;
    }

    /**
     * Get a display friendly version of the size
     * @return the size
     */
    public String getPackageSizeString() {
        return StringUtil.displayFileSize(this.getPackageSize());
    }

    /**
     * @param p The packageSize to set.
     */
    public void setPackageSize(Long p) {
        this.packageSize = p;
    }

    /**
     * @return Returns the path.
     */
    public String getPath() {
        return path;
    }

    /**
     * @param p The path to set.
     */
    public void setPath(String p) {
        this.path = p;
    }

    /**
     * @return Returns the payloadFormat.
     */
    public String getPayloadFormat() {
        return payloadFormat;
    }

    /**
     * @param p The payloadFormat to set.
     */
    public void setPayloadFormat(String p) {
        this.payloadFormat = p;
    }

    /**
     * @return Returns the payloadSize.
     */
    public Long getPayloadSize() {
        return payloadSize;
    }

    /**
     * Get a display friendly version of the payload size
     * @return the size
     */
    public String getPayloadSizeString() {
        return StringUtil.displayFileSize(this.getPayloadSize());
    }

    /**
     * @param p The payloadSize to set.
     */
    public void setPayloadSize(Long p) {
        this.payloadSize = p;
    }

    /**
     * @return Returns the rpmVersion.
     */
    public String getRpmVersion() {
        return rpmVersion;
    }

    /**
     * @param r The rpmVersion to set.
     */
    public void setRpmVersion(String r) {
        this.rpmVersion = r;
    }

    /**
     * @return Returns the sourceRpm.
     */
    public SourceRpm getSourceRpm() {
        return sourceRpm;
    }

    /**
     * @param s The sourceRpm to set.
     */
    public void setSourceRpm(SourceRpm s) {
        this.sourceRpm = s;
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
     * @return Returns the vendor.
     */
    public String getVendor() {
        return vendor;
    }

    /**
     * @param v The vendor to set.
     */
    public void setVendor(String v) {
        this.vendor = v;
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return new ToStringBuilder(this).append("id", getId()).append("packageName",
                getPackageName()).toString();
    }

    /**
     * Util to output package name + evr: krb5-devel-1.3.4-47
     * @return String name and evr
     */
    public String getNameEvr() {
        return this.getPackageName().getName() + "-" + this.getPackageEvr().toString();
    }

    /**
     * Util to output package name + evr: krb5-devel-1.3.4-47.i386
     * @return String name and evra
     */
    public String getNameEvra() {
        return this.getPackageName().getName() + "-" + this.getPackageEvr().toString() +
                "." + this.getPackageArch().getLabel();
    }

    /**
     * 
     * {@inheritDoc}
     */
    public boolean equals(Object other) {
        if (other instanceof Package) {
            Package otherPack = (Package) other;
            return new EqualsBuilder().append(this.getPackageName(),
                    otherPack.getPackageName()).append(this.getPackageArch(),
                    otherPack.getPackageArch()).append(this.getPackageEvr(),
                    this.getPackageEvr()).isEquals();
        }
        else {
            return false;
        }
    }

    /**
     * 
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(this.getPackageName()).append(
                this.getPackageArch()).append(this.getPackageEvr()).toHashCode();
    }

    /**
     * @return Returns the package keys.
     */
    public Set<PackageKey> getPackageKeys() {
        return packageKeys;
    }

    /**
     * @param keys The keys to set.
     */
    public void setPackageKeys(Set<PackageKey> keys) {
        this.packageKeys = keys;
    }

    /**
     * @return Returns the publishedErrata.
     */
    public Set<PublishedErrata> getPublishedErrata() {
        return publishedErrata;
    }

    /**
     * @param publishedErrataIn The publishedErrata to set.
     */
    public void setPublishedErrata(Set<PublishedErrata> publishedErrataIn) {
        this.publishedErrata = publishedErrataIn;
    }

    /**
     * @return Returns the unpublishedErrata.
     */
    public Set<UnpublishedErrata> getUnpublishedErrata() {
        return unpublishedErrata;
    }

    /**
     * @param unpublishedErrataIn The unpublishedErrata to set.
     */
    public void setUnpublishedErrata(Set<UnpublishedErrata> unpublishedErrataIn) {
        this.unpublishedErrata = unpublishedErrataIn;
    }

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
     * @return Returns the packageFiles.
     */
    public Set<PackageFile> getPackageFiles() {
        return packageFiles;
    }

    /**
     * @param packageFilesIn The packageFiles to set.
     */
    public void setPackageFiles(Set<PackageFile> packageFilesIn) {
        this.packageFiles = packageFilesIn;
    }

    /**
     * @return Returns the requires.
     */
    public Set<PackageRequires> getRequires() {
        return requires;
    }

    /**
     * @param requiresIn The requires to set.
     */
    public void setRequires(Set<PackageRequires> requiresIn) {
        this.requires = requiresIn;
    }

    /**
     * @return Returns the obsoletes.
     */
    public Set<PackageObsoletes> getObsoletes() {
        return obsoletes;
    }

    /**
     * @param obsoletesIn The obsoletes to set.
     */
    public void setObsoletes(Set<PackageObsoletes> obsoletesIn) {
        this.obsoletes = obsoletesIn;
    }

    /**
     * @return Returns the conflicts.
     */
    public Set<PackageConflicts> getConflicts() {
        return conflicts;
    }

    /**
     * @param conflictsIn The conflicts to set.
     */
    public void setConflicts(Set<PackageConflicts> conflictsIn) {
        this.conflicts = conflictsIn;
    }

    /**
     * @return Returns the headerStart.
     */
    public Long getHeaderStart() {
        return headerStart;
    }

    /**
     * @param headerStartIn The headerStart to set.
     */
    public void setHeaderStart(Long headerStartIn) {
        this.headerStart = headerStartIn;
    }

    /**
     * @return Returns the headerEnd.
     */
    public Long getHeaderEnd() {
        return headerEnd;
    }

    /**
     * @param headerEndIn The headerEnd to set.
     */
    public void setHeaderEnd(Long headerEndIn) {
        this.headerEnd = headerEndIn;
    }

    /**
     * @return Returns the pkgFile.
     */
    public String getFilename() {
        String pkgFile = getFile();
        if (pkgFile == null) {
            StringBuffer buf = new StringBuffer();
            buf.append(getPackageName().getName());
            buf.append("-");
            buf.append(getPackageEvr().getVersion());
            buf.append("-");
            buf.append(getPackageEvr().getRelease());
            buf.append(".");
            if (getPackageEvr().getEpoch() != null) {
                buf.append(getPackageEvr().getEpoch() + ".");
            }
            buf.append(getPackageArch().getLabel());
            buf.append(".");
            buf.append(getPackageArch().getArchType().getLabel());
            pkgFile = buf.toString();
        }
        return pkgFile;
    }

}
