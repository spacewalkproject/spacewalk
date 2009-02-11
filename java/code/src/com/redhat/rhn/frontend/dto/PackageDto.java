/**
 * Copyright (C) 2008 Red Hat, Inc.
 * All Rights Reserved.
 *
 * This software is the confidential and proprietary information of
 * Red Hat, Inc. ("Confidential Information").  You shall not
 * disclose such Confidential Information and shall use it only in
 * accordance with the terms of the license agreement you entered into
 * with Red Hat.
 */
package com.redhat.rhn.frontend.dto;

import java.math.BigDecimal;
import java.util.Date;

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

    @Override
    public Long getId() {
        return id;
    }
    /**
     * @param id The id to set.
     */
    public void setId(Long id) {
        this.id = id;
    }
    /**
     * @return Returns the channel Name.
     */
    public String getChannelName() {
        return channelName;
    }
    /**
     * @param channelName The channel name to set.
     */
    public void setChannelName(String channelName) {
        this.channelName = channelName;
    }
    /**
     * @return Returns the channel id.
     */
    public Long getCid() {
        return cid;
    }
    /**
     * @param channelName The channel id to set.
     */
    public void setCid(Long cid) {
        this.cid = cid;
    }
    /**
     * @return Returns the package name.
     */
    public String getPackageName() {
        return packageName;
    }
    /**
     * @param packageName The packageName to set.
     */
    public void setPackageName(String packageName) {
        this.packageName = packageName;
    }
    /**
     * @return Returns the package version.
     */
    public String getPackageVersion() {
        return packageVersion;
    }
    /**
     * 
     * @param packageVersion
     */
    public void setPackageVersion(String packageVersion) {
        this.packageVersion = packageVersion;
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
     * @param packageRelease The package release to set
     */
    public void setPackageRelease(String packageRelease) {
        this.packageRelease = packageRelease;
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
     * @param packageEpoch The package epoch to set.
     */
    public void setPackageEpoch(String packageEpoch) {
        this.packageEpoch = packageEpoch;
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
     * @param md5sum The md5sum to set
     */
    public void setMd5sum(String md5sum) {
        this.md5sum = md5sum;
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
     * @param packageNvr The packageNvr to set.
     */
    public void setPackageNvr(String packageNvr) {
        this.packageNvr = packageNvr;
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
     * @param packageArchLabel The package Arch label to set
     */
    public void setPackageArchLabel(String packageArchLabel) {
        this.packageArchLabel = packageArchLabel;
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
     * @param summary The summary to set.
     */
    public void setSummary(String summary) {
        this.summary = summary;
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
     * @param description The description to set.
     */
    public void setDescription(String description) {
        this.description = description;
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
     * @param buildTime The buildTime to set.
     */
    public void setBuildTime(Date buildTime) {
        this.buildTime = buildTime;
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
     * @param packageSize The packagesize to set.
     */
    public void setPackageSize(Long packageSize) {
        this.packageSize = packageSize;
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
     * @param payloadSize The payload size to set.
     */
    public void setPayloadSize(Long payloadSize) {
        this.payloadSize = payloadSize;
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
     * @param path The path to set.
     */
    public void setPath(String path) {
        this.path = path;
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
     * @param copyright The copyright info to set
     */
    public void setCopyright(String copyright) {
        this.copyright = copyright;
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
     * @param vendor The vendor to set.
     */
    public void setVendor(String vendor) {
        this.vendor = vendor;
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
     * @param packageGroupName The packageGroupName to set
     */
    public void setPackageGroupName(String packageGroupName) {
        this.packageGroupName = packageGroupName;
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
     * @param buildHost The buildHost to set
     */
    public void setBuildHost(String buildHost) {
        this.buildHost = buildHost;
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
     * @param sourceRpm The sourceRpm to set.
     */
    public void setSourceRpm(String sourceRpm) {
        this.sourceRpm = sourceRpm;
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
     * @param headerStart The package HeaderStart to set.
     */
    public void setHeaderStart(Long headerStart) {
        this.headerStart = headerStart;
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
     * @param headerEnd The package HeaderEnd to set.
     */
    public void setHeaderEnd(Long headerEnd) {
        this.headerEnd = headerEnd;
    }

}
