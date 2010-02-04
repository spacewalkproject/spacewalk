/**
 * Copyright (c) 2008--2010 Red Hat, Inc.
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

package com.redhat.satellite.search.db.models;

/**
 * Simple Package DTO
 * @version $Rev$
 */
public class RhnPackage {

    private long id;
    private String name;
    private String epoch;
    private String version;
    private String release;
    private String arch;
    private String description;
    private String summary;

    /**
     * Getter for pkg id
     * @return pkg id
     */
    public long getId() {
        return id;
    }

    /**
     * Setter for pkg id
     * @param idIn pkg id
     */
    public void setId(long idIn) {
        this.id = idIn;
    }

    /**
     * Getter for pkg name
     * @return pkg name
     */
    public String getName() {
        return name;
    }

    /**
     * Setter for pkg name
     * @param nameIn pkg name
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /**
     * Getter for pkg epoch
     * @return pkg epoch
     */
    public String getEpoch() {
        return epoch;
    }

    /**
     * Setter for pkg epoch
     * @param epochIn pkg epoch
     */
    public void setEpoch(String epochIn) {
        this.epoch = epochIn;
    }

    /**
     * Getter for pkg version
     * @return pkg version
     */
    public String getVersion() {
        return version;
    }

    /**
     * Setter for pkg version
     * @param versionIn
     */
    public void setVersion(String versionIn) {
        this.version = versionIn;
    }

    /**
     * Getter for pkg release
     * @return pkg release
     */
    public String getRelease() {
        return release;
    }

    /**
     * Setter for pkg release
     * @param releaseIn pkg release
     */
    public void setRelease(String releaseIn) {
        this.release = releaseIn;
    }

    /**
     * Getter for pkg arch
     * @return pkg arch
     */
    public String getArch() {
        return arch;
    }

    /**
     * Setter for pkg arch
     * @param archIn pkg arch
     */
    public void setArch(String archIn) {
        this.arch = archIn;
    }
    
    /**
     * Setter for pkg description
     * @param desc pkg description
     */
    public void setDescription(String desc) {
        description = desc;
    }
    
    /**
     * Getter for pkg description
     * @return pkg description
     */
    public String getDescription() {
        return description;
    }
    
    /**
     * Setter for pkg summary
     * @param summaryIn pkg summary
     */
    public void setSummary(String summaryIn) {
        summary = summaryIn;
    }
    
    /**
     * Getter for pkg summary
     * @return pkg summary
     */
    public String getSummary() {
        return summary;
    }
    
    /**
     * Getter for "pretty" versino
     * @return <version>-<release>
     */
    public String getPrettyVersion() {
        return version + "-" + release;
    }
    
    /**
     * Reconstructs filename from various parts of pkg metadata
     * @return <name>-<version>-<release>.<arch>
     */
    public String getFileName() {
        return name + "-" + version + "-" + release + "." + arch;
    }
}
