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
package com.redhat.rhn.frontend.dto;


/**
 * ErrataPackageFile
 * @version $Rev: 94459 $
 */
public class ErrataPackageFile {
    private Long packageId;
    private String checksum;
    private String checksumType;
    private String filename;
    private String channelName;
    
    
    /**
     * @return Returns the channelName.
     */
    public String getChannelName() {
        return channelName;
    }
    /**
     * @param channelNameIn The channelName to set.
     */
    public void setChannelName(String channelNameIn) {
        this.channelName = channelNameIn;
    }
    /**
     * @return Returns the filename.
     */
    public String getFilename() {
        return filename;
    }
    /**
     * @param filenameIn The filename to set.
     */
    public void setFilename(String filenameIn) {
        this.filename = filenameIn;
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
     * @return Returns the packageId.
     */
    public Long getPackageId() {
        return packageId;
    }
    /**
     * @param packageIdIn The packageId to set.
     */
    public void setPackageId(Long packageIdIn) {
        this.packageId = packageIdIn;
    }
}
