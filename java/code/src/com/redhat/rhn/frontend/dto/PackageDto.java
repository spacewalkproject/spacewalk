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

}
