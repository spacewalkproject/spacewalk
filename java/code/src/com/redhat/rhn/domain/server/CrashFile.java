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

package com.redhat.rhn.domain.server;

import com.redhat.rhn.domain.BaseDomainHelper;
import java.util.Date;

/**
 * Represents the particulart file associated with a crash.
 * @version $Rev$
 */
public class CrashFile extends BaseDomainHelper {

    private Long id;
    private Crash crash;
    private String filename;
    private String path;
    private long filesize;
    private boolean isUploaded;
    private Date created;
    private Date modified;

    /**
     * Represents application crash information.
     */
    public CrashFile() {
        super();
    }

    /**
     * Returns the database id of the crash.
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }

    /**
     * Sets the database id of the crash.
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        id = idIn;
    }

    /**
     * The parent Crash.
     * @return Returns the parent crash.
     */
    public Crash getCrash() {
        return crash;
    }

    /**
     * Sets the parent crash.
     * @param crashIn The parent crash to set.
     */
    public void setCrash(Crash crashIn) {
        crash = crashIn;
    }

    /**
     * Get the filename.
     * @return Returns the crash filename.
     */
    public String getFilename() {
        return filename;
    }

    /**
     * Sets the filename.
     * @param filenameIn The filename to set.
     */
    public void setFilename(String filenameIn) {
        filename = filenameIn;
    }

    /**
     * Get the file path.
     * @return Returns the file path.
     */
    public String getPath() {
        return path;
    }

    /**
     * Set the file path.
     * @param pathIn The file path to set.
     */
    public void setPath(String pathIn) {
        path = pathIn;
    }

    /**
     * Get the file size.
     * @return Returns the file size.
     */
    public long getFilesize() {
        return filesize;
    }

    /**
     * Set the file size.
     * @param filesizeIn The file size to set.
     */
    public void setFilesize(long filesizeIn) {
        filesize = filesizeIn;
    }

    /**
     * Return isUploaded flag.
     * @return Returns the isUploaded flag.
     */
    public boolean getIsUploaded() {
        return isUploaded;
    }

    /**
     * Set the isUploaded flag.
     * @param isUploadedIn The boolean flag to set.
     */
    public void setIsUploaded(boolean isUploadedIn) {
        isUploaded = isUploadedIn;
    }

    /**
     * Returns the created date.
     * @return the created date.
     */
    public Date getCreated() {
        return created;
    }

    /**
     * Sets the created date.
     * @param createdIn The create date to set.
     */
    public void setCreated(Date createdIn) {
        created = createdIn;
    }

    /**
     * Returns the modified date.
     * @return the modified date.
     */
    public Date getModified() {
        return modified;
    }

    /**
     * Sets the modified date.
     * @param modifiedIn The modified date to set.
     */
    public void setModified(Date modifiedIn) {
        modified = modifiedIn;
    }
}
