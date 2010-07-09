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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.download.DownloadManager;

import java.io.File;

/**
 * ISOImage
 * @version $Rev$
 */
public class ISOImage extends BaseDto {
    private String downloadName;
    private String downloadPath;
    private String downloadChecksum;
    private Long downloadSize;
    private Long fileId;
    private Long id;
    private Long ordering;
    private String category;
    private String url;

    /**
     * {@inheritDoc}
     */
    public Long getId() {
        return id;
    }

    /**
     * Set new id
     * @param newId id to set
     */
    public void setId(Long newId) {
        id = newId;
    }

    /**
     * getter for ISO category
     * @return category
     */
    public String getCategory() {
        return category;
    }

    /**
     * Set category
     * @param cat category to set
     */
    public void setCategory(String cat) {
        category = cat;
    }

    /**
     * getter for ISO checksum
     * @return cksum
     */
    public String getDownloadChecksum() {
        return downloadChecksum;
    }

    /**
     * Set checksum
     * @param dlSum checksum to set
     */
    public void setDownloadChecksum(String dlSum) {
        downloadChecksum = dlSum;
    }

    /**
     * getter for ISO name
     * @return name
     */
    public String getDownloadName() {
        return downloadName;
    }

    /**
     * Set name
     * @param dlName name to set
     */
    public void setDownloadName(String dlName) {
        downloadName = dlName;
    }

    /**
     * getter for ISO file-path
     * @return path
     */
    public String getDownloadPath() {
        return downloadPath;
    }

    /**
     * Set path
     * @param dlPath new path
     */
    public void setDownloadPath(String dlPath) {
        downloadPath = dlPath;
    }

    /**
     * Human-readable string describing the image's filesize
     * @return filesize string
     */
    public String getSize() {
        return StringUtil.displayFileSize(downloadSize.longValue(), true);
    }

    /**
     * getter for ISO size in bytes
     * @return size
     */
    public Long getDownloadSize() {
        return downloadSize;
    }

    /**
     * Set size (bytes)
     * @param dlSz size to set
     */
    public void setDownloadSize(Long dlSz) {
        downloadSize = dlSz;
    }

    /**
     * getter for ISO file-id
     * @return DB fid
     */
    public Long getFileId() {
        return fileId;
    }

    /**
     * Set id of associated file
     * @param fid new fid
     */
    public void setFileId(Long fid) {
        fileId = fid;
    }

    /**
     * Given a user and a mount-point, create the appropriate download-url for this
     * ISO image
     * @param u User requesting the download
     */
    public void createDownloadUrl(User u) {
        setUrl(DownloadManager.getISODownloadPath(this, u));
    }

    /**
     * Set the fully-qualified download-URL for this ISO image
     * @param newUrl complete URL for this image's download
     */
    public void setUrl(String newUrl) {
        url = newUrl;
    }

    /**
     * Get the fully-qualified download-URL for this ISO image
     * @return url
     */
    public String getUrl() {
        return url;
    }

    /**
     * Returns true if this image is accessible from this machine
     * @return true if we can find web.mount_point/download/<path>, false else
     */
    public boolean getExists() {
        String mtpt = Config.get().getString("web.mount_point");
        File f = new File(mtpt + "/download/" + getDownloadPath());
        return f.exists();
    }

    protected long getExpires() {
        int lifetime = Config.get().getInt("web.download_url_lifetime");
        // SECONDS! *NOT* milliseconds
        return (System.currentTimeMillis() / 1000 + lifetime);
    }

    //return RHN::SessionSwap->rhn_hmac_data($self->{expires}, $self->{user_id},
    //  $self->{file_id} || 0, $self->{path_trail});
    protected String getToken(User u, long expires) {
        return DownloadManager.getFileSHA1Token(this.getId(), this.getDownloadName(),
                u, expires, DownloadManager.DOWNLOAD_TYPE_ISO);
    }

    /**
     * Extracts the base filename of an ISO from its download path
     * @return base name (e.g., "RHEL5-Server-20060830.1-i386-disc4-ftp.iso")
     */
    public String getBaseISOName() {
        int lastSlash = getDownloadPath().lastIndexOf('/');
        return getDownloadPath().substring(lastSlash + 1);
    }

    /**
     * get the ISO-ordering information
     * @return ordinal for  this ISO within its group
     */
    public Long getOrdering() {
        return ordering;
    }

    /**
     * Set the order of this ISO in its grouping
     * @param ordr new ordering
     */
    public void setOrdering(Long ordr) {
        ordering = ordr;
    }
}
