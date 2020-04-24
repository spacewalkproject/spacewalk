/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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

import com.redhat.rhn.common.RhnRuntimeException;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.util.CompressionUtil;
import com.redhat.rhn.frontend.xmlrpc.packages.PackageHelper;

import java.sql.Blob;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;
/**
 * PackageDto
 * @version $Rev$
 *
 * DTO for a specific set of package data returned from some data source
 * package queries.
 */
public class PackageDto extends BaseDto {

    private Long id;
    private String name;
    private String version;
    private String release;
    private String epoch;
    private String archLabel;
    private String checksum;
    private String checksumType;
    private Long cid;
    private String channelName;
    private String summary;
    private String description;
    private Date buildTime;
    private Long packageSize;
    private Long payloadSize;
    private Long installedSize;
    private String path;
    private String copyright;
    private String vendor;
    private String packageGroupName;
    private String buildHost;
    private String sourceRpm;
    private Long headerStart;
    private Long headerEnd;
    private Blob primaryXml;
    private Blob otherXml;
    private Blob filelistXml;
    private String cookie;
    private String multiArch;
    private String preDepends;

    // Pre-existing queries returning this as a string.
    private String lastModified;

    /**
     * @return the id
     */
    public Long getId() {
        return id;
    }

    /**
     * @param idIn the id to set
     */
    public void setId(Long idIn) {
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
     * @return the version
     */
    public String getVersion() {
        return version;
    }

    /**
     * @param versionIn the version to set
     */
    public void setVersion(String versionIn) {
        this.version = versionIn;
    }

    /**
     * @return the release
     */
    public String getRelease() {
        return release;
    }

    /**
     * @param releaseIn the release to set
     */
    public void setRelease(String releaseIn) {
        this.release = releaseIn;
    }

    /**
     * @return the epoch
     */
    public String getEpoch() {
        return epoch;
    }

    /**
     * @param epochIn the epoch to set
     */
    public void setEpoch(String epochIn) {
        this.epoch = epochIn;
    }

    /**
     * @return the archLabel
     */
    public String getArchLabel() {
        return archLabel;
    }

    /**
     * @param archLabelIn the archLabel to set
     */
    public void setArchLabel(String archLabelIn) {
        this.archLabel = archLabelIn;
    }

    /**
     * @return the lastModified
     */
    public String getLastModified() {
        return lastModified;
    }

    /**
     * @param lastModifiedIn the lastModified to set
     */
    public void setLastModified(String lastModifiedIn) {
        this.lastModified = lastModifiedIn;
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
     *
     * @return Returns the checksum
     */
    public String getChecksum() {
        return checksum;
    }

    /**
     *
     * @param checksumIn The checksum to set
     */
    public void setChecksum(String checksumIn) {
        this.checksum = checksumIn;
    }

    /**
     *
     * @return Returns the checksum type
     */
    public String getChecksumType() {
        return checksumType;
    }

    /**
     *
     * @param checksumTypeIn The checksumtype to set
     */
    public void setChecksumType(String checksumTypeIn) {
        this.checksumType = checksumTypeIn;
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
     * Package build times are written to the database as GMT (see headerSource.py),
     * which means we have to parse in here as long as this is not changed!
     *
     * @param buildTimeIn The buildTime to set.
     * @throws RhnRuntimeException when buildTimeIn can't be parsed
     */
    public void setBuildTime(Date buildTimeIn) throws RhnRuntimeException {
        SimpleDateFormat dateFormatGMT = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.S");
        dateFormatGMT.setTimeZone(TimeZone.getTimeZone("GMT"));
        try {
            this.buildTime = (buildTimeIn == null ?
                        null : dateFormatGMT.parse(buildTimeIn.toString()));
        }
        catch (ParseException e) {
            throw new RhnRuntimeException(e);
        }
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
     * @return Returns the installed size
     */
    public Long getInstalledSize() {
        return installedSize;
    }

    /**
     *
     * @param installedSizeIn The installed size to set.
     */
    public void setInstalledSize(Long installedSizeIn) {
        this.installedSize = installedSizeIn;
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


    /**
     * @return Returns the primaryXml.
     */
    public Blob getPrimaryBlob() {
        return primaryXml;
    }

    /**
     * get the primary xml
     * @return the primary xml as a string
     */
    public String getPrimaryXml() {
        return transformXml(primaryXml);
    }

    /**
     * @param blobIn The primaryXml to set.
     */
    public void setPrimaryXml(Blob blobIn) {
        this.primaryXml =  blobIn;
    }

    /**
     * Interface for postgres byte array
     * @param byteArrayIn The primaryXml byte array to set.
     */
    public void setPrimaryXml(byte[] byteArrayIn) {
        this.primaryXml =  HibernateFactory.byteArrayToBlob(byteArrayIn);
    }

    /**
     * @return Returns the otherXml.
     */
    public Blob getOtherBlob() {
        return otherXml;
    }

    /**
     * Get the other repodata uncompressed
     * @return the other xml
     */
    public String getOtherXml() {
        return transformXml(otherXml);
    }


    /**
     * @param blobIn The otherXml to set.
     */
    public void setOtherXml(Blob blobIn) {
        this.otherXml = blobIn;
    }

    /**
     * Interface for postgres byte array
     * @param byteArrayIn The otherXml byte array to set.
     */
    public void setOtherXml(byte[] byteArrayIn) {
        this.otherXml =  HibernateFactory.byteArrayToBlob(byteArrayIn);
    }

    /**
     * @return Returns the filelistXml.
     */
    public Blob getFilelistBlob() {
        return filelistXml;
    }

    /**
     * Get the filelist repodata uncompressed
     * @return the filelist xml
     */
    public String getFilelistXml() {
        return transformXml(filelistXml);
    }

    /**
     * @param blobIn The filelistXml to set.
     */
    public void setFilelistXml(Blob blobIn) {
        this.filelistXml = blobIn;
    }

    /**
     * Interface for postgres byte array
     * @param byteArrayIn The filelistXml byte array to set.
     */
    public void setFilelistXml(byte[] byteArrayIn) {
        this.filelistXml =  HibernateFactory.byteArrayToBlob(byteArrayIn);
    }

    /**
     * Convert a blob into a string
     * @param blobIn
     * @return
     */
    private String transformXml(Blob blobIn) {
        return CompressionUtil.gzipDecompress(HibernateFactory.blobToByteArray(blobIn));
    }


    /**
     * @return Returns the cookie.
     */
    public String getCookie() {
        return cookie;
    }


    /**
     * @param cookieIn The cookie to set.
     */
    public void setCookie(String cookieIn) {
        cookie = cookieIn;
    }


    /**
     * @return Returns the file.
     */
    public String getFile() {
        return PackageHelper.getPackageFileFromPath(getPath());
    }

    /**
     * @param multiArchIn The Multi-Arch header value
     */
    public void setMultiArch(String multiArchIn) {
        this.multiArch = multiArchIn;
    }

    /**
     * @return The Multi-Arch value
     */
    public String getMultiArch() {
        return multiArch;
    }

    /**
     * @param preDependsIn The Pre-Depends header value
     */
    public void setPreDepends(String preDependsIn) {
        this.preDepends = preDependsIn;
    }

    /**
     * @return The Multi-Arch value
     */
    public String getPreDepends() {
        return preDepends;
    }
}
