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
    private BigDecimal cid;
    private String channelName;
    private String summary;
    private String description;
    private Date buildTime;
    private BigDecimal packageSize;
    private BigDecimal payloadSize;
    private String path;
    private String copyright;
    private String vendor;
    private String packageGroupName;
    private String buildHost;
    private String sourceRpm;
    private BigDecimal headerStart;
    private BigDecimal headerEnd;

    @Override
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getChannelName() {
        return channelName;
    }

    public void setChannelName(String channelName) {
        this.channelName = channelName;
    }
    
    public BigDecimal getCid() {
        return cid;
    }
    
    public void setCid(BigDecimal cid) {
        this.cid = cid;
    }

    public String getPackageName() {
        return packageName;
    }

    public void setPackageName(String packageName) {
        this.packageName = packageName;
    }

    public String getPackageVersion() {
        return packageVersion;
    }

    public void setPackageVersion(String packageVersion) {
        this.packageVersion = packageVersion;
    }

    public String getPackageRelease() {
        return packageRelease;
    }

    public void setPackageRelease(String packageRelease) {
        this.packageRelease = packageRelease;
    }

    public String getPackageEpoch() {
        return packageEpoch;
    }

    public void setPackageEpoch(String packageEpoch) {
        this.packageEpoch = packageEpoch;
    }

    public String getMd5sum() {
        return md5sum;
    }

    public void setMd5sum(String md5sum) {
        this.md5sum = md5sum;
    }

    public String getPackageNvr() {
        return packageNvr;
    }

    public void setPackageNvr(String packageNvr) {
        this.packageNvr = packageNvr;
    }

    public String getPackageArchLabel() {
        return packageArchLabel;
    }

    public void setPackageArchLabel(String packageArchLabel) {
        this.packageArchLabel = packageArchLabel;
    }

    public String getSummary() {
        return summary;
    }

    public void setSummary(String summary) {
        this.summary = summary;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Date getBuildTime() {
        return buildTime;
    }

    public void setBuildTime(Date buildTime) {
        this.buildTime = buildTime;
    }

    public BigDecimal getPackageSize() {
        return packageSize;
    }

    public void setPackageSize(BigDecimal packageSize) {
        this.packageSize = packageSize;
    }

    public BigDecimal getPayloadSize() {
        return payloadSize;
    }

    public void setPayloadSize(BigDecimal payloadSize) {
        this.payloadSize = payloadSize;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public String getCopyright() {
        return copyright;
    }

    public void setCopyright(String copyright) {
        this.copyright = copyright;
    }

    public String getVendor() {
        return vendor;
    }

    public void setVendor(String vendor) {
        this.vendor = vendor;
    }

    public String getPackageGroupName() {
        return packageGroupName;
    }

    public void setPackageGroupName(String packageGroupName) {
        this.packageGroupName = packageGroupName;
    }

    public String getBuildHost() {
        return buildHost;
    }

    public void setBuildHost(String buildHost) {
        this.buildHost = buildHost;
    }

    public String getSourceRpm() {
        return sourceRpm;
    }

    public void setSourceRpm(String sourceRpm) {
        this.sourceRpm = sourceRpm;
    }

    public BigDecimal getHeaderStart() {
        return headerStart;
    }

    public void setHeaderStart(BigDecimal headerStart) {
        this.headerStart = headerStart;
    }

    public BigDecimal getHeaderEnd() {
        return headerEnd;
    }

    public void setHeaderEnd(BigDecimal headerEnd) {
        this.headerEnd = headerEnd;
    }

}
