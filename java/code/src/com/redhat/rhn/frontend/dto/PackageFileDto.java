/**
 * Copyright (c) 2014 Red Hat, Inc.
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
 * Simple DTO for transfering data from the DB to the UI through datasource.
 * @version $Rev$
 */
public class PackageFileDto {

    private String name;
    private Long fileSize;
    private String checksum;
    private String checksumtype;
    private Long fileMode;
    private String linkto;
    private String mtime;

    /**
     * @return filename
     */
    public String getName() {
        return name;
    }

    /**
     * @param nameIn name to set
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /**
     * @return fileSize
     */
    public Long getFileSize() {
        return fileSize;
    }

    /**
     * @param fileSizeIn fileSize to set
     */
    public void setFileSize(Long fileSizeIn) {
        this.fileSize = fileSizeIn;
    }

    /**
     * @return checksum
     */
    public String getChecksum() {
        return checksum;
    }

    /**
     * @param checksumIn checksum to set
     */
    public void setChecksum(String checksumIn) {
        this.checksum = checksumIn;
    }

    /**
     * @return checksumtype
     */
    public String getChecksumtype() {
        return checksumtype;
    }

    /**
     * @param checksumtypeIn checksumtype to set
     */
    public void setChecksumtype(String checksumtypeIn) {
        this.checksumtype = checksumtypeIn;
    }

    /**
     * @return filemode
     */
    public Long getFileMode() {
        return fileMode;
    }

    /**
     * @param fileModeIn filemode to set
     */
    public void setFileMode(Long fileModeIn) {
        this.fileMode = fileModeIn;
    }

    /**
     * @return linkto
     */
    public String getLinkto() {
        return linkto;
    }

    /**
     * @param linktoIn linkto to set
     */
    public void setLinkto(String linktoIn) {
        this.linkto = linktoIn;
    }

    /**
     * @return mtime
     */
    public String getMtime() {
        return mtime;
    }

    /**
     * @param mtimeIn mtime to set
     */
    public void setMtime(String mtimeIn) {
        this.mtime = mtimeIn;
    }

    /**
     * Get a formatted checksum if one is available, else empty string
     * @return the formatted checksum
     */
    public String getFormattedChecksum() {
        if (this.checksum == null || this.checksum.equals("")) {
            if (this.linkto == null || this.linkto.equals("")) {
                return "(Directory)";
            }
            return "(Symlink)";
        }
        return this.checksumtype + ": " + this.checksum;
    }

    /**
     * Get a formatted size if one is applicable, else empty string
     * @return the formatted size
     */
    public String getFormattedSize() {
        if (this.checksum == null || this.checksum.equals("")) {
            return "";
        }
        return this.fileSize.toString() + " bytes";
    }
}
