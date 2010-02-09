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
package com.redhat.rhn.domain.rhnpackage;

import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.common.Checksum;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rpm.SourceRpm;

import org.apache.commons.lang.StringUtils;

import java.util.Date;

/**
 * Package
 * @version $Rev$
 */
public class PackageSource extends BaseDomainHelper {

    private Long id;
    private String rpmVersion;
    private Long packageSize;
    private Long payloadSize;
    private String buildHost;
    private Date buildTime;
    private Checksum checksum;
    private Checksum sigchecksum;
    private String vendor;
    private String path;
    private String cookie;
    private Date lastModified;

    private Org org;
    private PackageGroup packageGroup;
    private SourceRpm sourceRpm;

    /**
     * @return Returns the sig checksum.
     */
    public Checksum getSigchecksum() {
        return sigchecksum;
    }

    /**
     * @param sigchecksumIn The sigchecksum to set.
     */
    public void setSigchecksum(Checksum sigchecksumIn) {
        this.sigchecksum = sigchecksumIn;
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
     * @return Returns the packageSize.
     */
    public Long getPackageSize() {
        return packageSize;
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
     * @return Returns the payloadSize.
     */
    public Long getPayloadSize() {
        return payloadSize;
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

}
