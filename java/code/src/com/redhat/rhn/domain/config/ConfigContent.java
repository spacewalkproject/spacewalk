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
package com.redhat.rhn.domain.config;

import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.common.Checksum;

/**
 * ConfigContent - Class representation of the table rhnConfigContent.
 * @version $Rev$
 */
public class ConfigContent extends BaseDomainHelper {

    private Long id;
    private Long fileSize;
    private Checksum checksum;
    private boolean isBinary;
    private byte[] contents;
    private String delimStart;
    private String delimEnd;
    /**
     * protected constructor.
     * Use the ConfigurationFactory to get new ConfigContents
     */
    protected ConfigContent() {

    }

    /**
     * Getter for id
     * @return Long to get
    */
    public Long getId() {
        return this.id;
    }

    /**
     * Setter for id
     * @param idIn to set
    */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     * Getter for contents
     * @return byte array to get
    */
    public byte[] getContents() {
        return contents;
    }

    /**
     * set the contents
     * @param contentsIn the contents
     */
    public void setContents(byte[] contentsIn) {
        contents = contentsIn;
    }



    /**
     * Get the String version of the Contents content
     * @return String version of the Contents content
     */
    public String getContentsString() {
        return new String(contents);
    }


    /**
     * Getter for fileSize
     * @return Long to get
    */
    public Long getFileSize() {
        return this.fileSize;
    }

    /**
     * Setter for fileSize
     * @param fileSizeIn to set
    */
    public void setFileSize(Long fileSizeIn) {
        this.fileSize = fileSizeIn;
    }

    /**
     * Getter for checksum
     * @return String to get
    */
    public Checksum getChecksum() {
        return this.checksum;
    }

    /**
     * Setter for checksum
     * @param checksumIn to set
    */
    public void setChecksum(Checksum checksumIn) {
        this.checksum = checksumIn;
    }

    /**
     * Getter for isBinary
     * @return String to get
    */
    public boolean isBinary() {
        return this.isBinary;
    }

    /**
     * Setter for isBinary
     * @param isBinaryIn to set
    */
    public void setBinary(boolean isBinaryIn) {
        this.isBinary = isBinaryIn;
    }

    /**
     * Getter for delimStart
     * @return String to get
    */
    public String getDelimStart() {
        return this.delimStart;
    }

    /**
     * Setter for delimStart
     * @param delimStartIn to set
    */
    public void setDelimStart(String delimStartIn) {
        this.delimStart = delimStartIn;
    }

    /**
     * Getter for delimEnd
     * @return String to get
    */
    public String getDelimEnd() {
        return this.delimEnd;
    }

    /**
     * Setter for delimEnd
     * @param delimEndIn to set
    */
    public void setDelimEnd(String delimEndIn) {
        this.delimEnd = delimEndIn;
    }
}
