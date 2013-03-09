/**
 * Copyright (c) 2013 Red Hat, Inc.
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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.server.CrashFile;

import java.util.Date;


/**
 * SoftwareCrashFileDto
 * @version $Rev$
 */
public class SoftwareCrashFileDto extends BaseDto {

    private Long id;
    private String filename;
    private String path;
    private long filesize;
    private boolean isUploaded;
    private Date modified;
    private String downloadPath;

    /**
     * Constructor
     * @param cFile construct object according to crash file
     */
    public SoftwareCrashFileDto(CrashFile cFile) {
        id = cFile.getId();
        filename = cFile.getFilename();
        path = cFile.getPath();
        isUploaded = cFile.getIsUploaded();
        filesize = cFile.getFilesize();
        modified = cFile.getModified();
    }


    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }


    /**
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        id = idIn;
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
        filename = filenameIn;
    }


    /**
     * @return Returns the path.
     */
    public String getPath() {
        return path;
    }


    /**
     * @param pathIn The path to set.
     */
    public void setPath(String pathIn) {
        path = pathIn;
    }


    /**
     * @return Returns the filesize.
     */
    public long getFilesize() {
        return filesize;
    }


    /**
     * @param filesizeIn The filesize to set.
     */
    public void setFilesize(long filesizeIn) {
        filesize = filesizeIn;
    }

   /**
     * @return Returns the isUploaded flag.
     */
    public boolean getIsUploaded() {
        return isUploaded;
    }

    /**
     * @param isUploadedIn The isUploaded boolean flag.
     */
    public void setIsUploaded(boolean isUploadedIn) {
        isUploaded = isUploadedIn;
    }

    /**
     * @return Returns the modified.
     */
    public Date getModified() {
        return modified;
    }

    /**
     * @return Returns printable modified date.
     *
     */
    public String getModifiedString() {
        return LocalizationService.getInstance().formatDate(getModified());
    }

    /**
     * @param modifiedIn The modified to set.
     */
    public void setModified(Date modifiedIn) {
        modified = modifiedIn;
    }


    /**
     * @return Returns the downloadPath.
     */
    public String getDownloadPath() {
        return downloadPath;
    }


    /**
     * @param downloadPathIn The downloadPath to set.
     */
    public void setDownloadPath(String downloadPathIn) {
        downloadPath = downloadPathIn;
    }


    /**
     * Get a display friendly version of the file size
     * @return the size
     */
    public String getFilesizeString() {
        return StringUtil.displayFileSize(getFilesize());
    }
}
