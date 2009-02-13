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
package com.redhat.rhn.frontend.dto;

import java.util.Date;
/**
 * 
 * @version $Rev $
 *
 */
public class PackageDto extends BaseDto {

    private Long id;
    private String packageName;
    private String packageNvr;
    private String packageVersion;
    private String packageRelease;
    private String packageEpoch;
    private String packageArchLabel;
    private String md5sum;
    private Long cid;
    private String channelName;
    private String summary;
    private String description;
    private Date buildTime;
    private Long packageSize;
    private Long payloadSize;
    private String path;
    private String copyright;
    private String vendor;
    private String packageGroupName;
    private String buildHost;
    private String sourceRpm;
    private Long headerStart;
    private Long headerEnd;

    /**
     * @return Returns Id
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
     * @return Returns the channel Name.
     */
    public String getChannelName() {
        return channelName;
    }

    /**
     * @param channelNameIn The channel name to set.
     */
    public void setChannelName(String channelNameIn) {
        this.channelName = channelNameIn;
    }

    /**
     * @return Returns the channel id.
     */
    public Long getCid() {
        return cid;
    }

    /**
     * @param cidIn The channel id to set.
     */
    public void setCid(Long cidIn) {
        this.cid = cidIn;
    }

    /**
     * @return Returns the package name.
     */
    public String getPackageName() {
        return packageName;
    }

    /**
     * @param packageNameIn The packageName to set.
     */
    public void setPackageName(String packageNameIn) {
        this.packageName = packageNameIn;
    }

    /**
     * @return Returns the package version.
     */
    public String getPackageVersion() {
        return packageVersion;
    }

    /**
     * 
     * @param packageVersionIn package version
     */
    public void setPackageVersion(String packageVersionIn) {
        this.packageVersion = packageVersionIn;
    }

    /**
     * 
     * @return Returns package Release
     */
    public String getPackageRelease() {
        return packageRelease;
    }

    /**
     * 
     * @param packageReleaseIn The package release to set
     */
    public void setPackageRelease(String packageReleaseIn) {
        this.packageRelease = packageReleaseIn;
    }

    /**
     * 
     * @return Returns package epoch
     */
    public String getPackageEpoch() {
        return packageEpoch;
    }

    /**
     * 
     * @param packageEpochIn The package epoch to set.
     */
    public void setPackageEpoch(String packageEpochIn) {
        this.packageEpoch = packageEpochIn;
    }

    /**
     * 
     * @return Returns the md5sum
     */
    public String getMd5sum() {
        return md5sum;
    }

    /**
     * 
     * @param md5sumIn The md5sum to set
     */
    public void setMd5sum(String md5sumIn) {
        this.md5sum = md5sumIn;
    }

    /**
     * 
     * @return Returns Package Nvr
     */
    public String getPackageNvr() {
        return packageNvr;
    }

    /**
     * 
     * @param packageNvrIn The packageNvr to set.
     */
    public void setPackageNvr(String packageNvrIn) {
        this.packageNvr = packageNvrIn;
    }

    /**
     * 
     * @return The package arch label to set
     */
    public String getPackageArchLabel() {
        return packageArchLabel;
    }

    /**
     * 
     * @param packageArchLabelIn The package Arch label to set
     */
    public void setPackageArchLabel(String packageArchLabelIn) {
        this.packageArchLabel = packageArchLabelIn;
    }

    /**
     * 
     * @return Returns the summary.
     */
    public String getSummary() {
        return summary;
    }

    /**
     * 
     * @param summaryIn The summary to set.
     */
    public void setSummary(String summaryIn) {
        this.summary = summaryIn;
    }

    /**
     * 
     * @return Returns the description
     */
    public String getDescription() {
        return description;
    }

    /**
     * 
     * @param descriptionIn The description to set.
     */
    public void setDescription(String descriptionIn) {
        this.description = descriptionIn;
    }

    /**
     * 
     * @return Returns the buildtime.
     */
    public Date getBuildTime() {
        return buildTime;
    }

    /**
     * 
     * @param buildTimeIn The buildTime to set.
     */
    public void setBuildTime(Date buildTimeIn) {
        this.buildTime = buildTimeIn;
    }

    /**
     * 
     * @return Returns the package size
     */
    public Long getPackageSize() {
        return packageSize;
    }

    /**
     * 
     * @param packageSizeIn The packagesize to set.
     */
    public void setPackageSize(Long packageSizeIn) {
        this.packageSize = packageSizeIn;
    }

    /**
     * 
     * @return Returns the payload size
     */
    public Long getPayloadSize() {
        return payloadSize;
    }

    /**
     * 
     * @param payloadSizeIn The payload size to set.
     */
    public void setPayloadSize(Long payloadSizeIn) {
        this.payloadSize = payloadSizeIn;
    }

    /**
     * 
     * @return Returns the path
     */
    public String getPath() {
        return path;
    }

    /**
     * 
     * @param pathIn The path to set.
     */
    public void setPath(String pathIn) {
        this.path = pathIn;
    }

    /**
     * 
     * @return Returns the copyright
     */
    public String getCopyright() {
        return copyright;
    }

    /**
     * 
     * @param copyrightIn The copyright info to set
     */
    public void setCopyright(String copyrightIn) {
        this.copyright = copyrightIn;
    }

    /**
     * 
     * @return Returns the vendor
     */
    public String getVendor() {
        return vendor;
    }

    /**
     * 
     * @param vendorIn The vendor to set.
     */
    public void setVendor(String vendorIn) {
        this.vendor = vendorIn;
    }

    /**
     * 
     * @return Returns the packageGroupName
     */
    public String getPackageGroupName() {
        return packageGroupName;
    }

    /**
     * 
     * @param packageGroupNameIn The packageGroupName to set
     */
    public void setPackageGroupName(String packageGroupNameIn) {
        this.packageGroupName = packageGroupNameIn;
    }

    /**
     * 
     * @return Returns the build host
     */
    public String getBuildHost() {
        return buildHost;
    }

    /**
     * 
     * @param buildHostIn The buildHost to set
     */
    public void setBuildHost(String buildHostIn) {
        this.buildHost = buildHostIn;
    }

    /**
     * 
     * @return Returns the sourceRPM
     */
    public String getSourceRpm() {
        return sourceRpm;
    }

    /**
     * 
     * @param sourceRpmIn The sourceRpm to set.
     */
    public void setSourceRpm(String sourceRpmIn) {
        this.sourceRpm = sourceRpmIn;
    }

    /**
     * 
     * @return Returns the package HeaderStart
     */
    public Long getHeaderStart() {
        return headerStart;
    }

    /**
     * 
     * @param headerStartIn The package HeaderStart to set.
     */
    public void setHeaderStart(Long headerStartIn) {
        this.headerStart = headerStartIn;
    }

    /**
     * 
     * @return Returns the package HeaderEnd
     */
    public Long getHeaderEnd() {
        return headerEnd;
    }

    /**
     * 
     * @param headerEndIn The package HeaderEnd to set.
     */
    public void setHeaderEnd(Long headerEndIn) {
        this.headerEnd = headerEndIn;
    }

}
