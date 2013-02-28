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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.BaseDomainHelper;

import java.util.Date;
import java.util.Set;

/**
 * Represents a particular crash.
 * @version $Rev$
 */
public class Crash extends BaseDomainHelper {

    private Long id;
    private Server server;
    private String crash;
    private String path;
    private long count;
    private String analyzer;
    private String architecture;
    private String cmdline;
    private String component;
    private String executable;
    private String kernel;
    private String reason;
    private String username;
    private Long packageNameId;
    private Long packageEvrId;
    private Long packageArchId;
    private String storagePath;
    private Date created;
    private Date modified;
    private Set<CrashFile> crashFiles;

    /**
     * Represents application crash information.
     */
    public Crash() {
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
     * The parent server.
     * @return Returns the server.
     */
    public Server getServer() {
        return server;
    }

    /**
     * Sets the parent server.
     * @param serverIn The server to set.
     */
    public void setServer(Server serverIn) {
        server = serverIn;
    }

    /**
     * Get the crash string.
     * @return Returns the crash string.
     */
    public String getCrash() {
        return crash;
    }

    /**
     * Sets the crash string.
     * @param crashIn The crash string to set.
     */
    public void setCrash(String crashIn) {
        crash = crashIn;
    }

    /**
     * Get the crash path.
     * @return Returns the crash path.
     */
    public String getPath() {
        return path;
    }

    /**
     * Set the crash path.
     * @param pathIn The crash path to set.
     */
    public void setPath(String pathIn) {
        path = pathIn;
    }

    /**
     * Get the crash count.
     * @return Returns the crash count.
     */
    public long getCount() {
        return count;
    }

    /**
     * Set the crash count.
     * @param countIn The crash count to set.
     */
    public void setCount(long countIn) {
        count = countIn;
    }

    /**
     * Get the crash analyzer.
     * @return Returns the crash analyzer.
     */
    public String getAnalyzer() {
        return analyzer;
    }

    /**
     * Set the crash analyzer.
     * @param analyzerIn The crash analyzer to set.
     */
    public void setAnalyzer(String analyzerIn) {
        analyzer = analyzerIn;
    }

    /**
     * Get the crash architecture.
     * @return Returns the crash architecture.
     */
    public String getArchitecture() {
        return architecture;
    }

    /**
     * Set the crash architecture.
     * @param architectureIn The crash architecture to set.
     */
    public void setArchitecture(String architectureIn) {
        architecture = architectureIn;
    }

    /**
     * Get the crash cmdline.
     * @return Returns the crash cmdline.
     */
    public String getCmdline() {
        return cmdline;
    }

    /**
     * Set the crash cmdline.
     * @param cmdlineIn The cmdline to set.
     */
    public void setCmdline(String cmdlineIn) {
        cmdline = cmdlineIn;
    }

    /**
     * Get the crash component.
     * @return Returns the crash component.
     */
    public String getComponent() {
        return component;
    }

    /**
     * Set the crash component.
     * @param componentIn The crash component to set.
     */
    public void setComponent(String componentIn) {
        component = componentIn;
    }

    /**
     * Get the crash executable.
     * @return Returns the crash executable.
     */
    public String getExecutable() {
        return executable;
    }

    /**
     * Set the crash executable.
     * @param executableIn The executable to set.
     */
    public void setExecutable(String executableIn) {
        executable = executableIn;
    }

    /**
     * Get the crash kernel.
     * @return Returns the crash kernel.
     */
    public String getKernel() {
        return kernel;
    }

    /**
     * Set the crash kernel.
     * @param kernelIn The crash kernel to set.
     */
    public void setKernel(String kernelIn) {
        kernel = kernelIn;
    }

    /**
     * Get the crash reason.
     * @return Returns the crash reason.
     */
    public String getReason() {
        return reason;
    }

    /**
     * Set the crash reason.
     * @param reasonIn The crash reason to set.
     */
    public void setReason(String reasonIn) {
        reason = reasonIn;
    }

    /**
     * Get the crash username.
     * @return Returns the crash username.
     */
    public String getUsername() {
        return username;
    }

    /**
     * Set the crash username.
     * @param usernameIn The username to set.
     */
    public void setUsername(String usernameIn) {
        username = usernameIn;
    }

    /**
     * Get the crash package name id.
     * @return Returns the crash package name id.
     */
    public Long getPackageNameId() {
        return packageNameId;
    }

    /**
     * Set the crash package name id.
     * @param packageNameIdIn The crash package name id to set.
     */
    public void setPackageNameId(Long packageNameIdIn) {
        packageNameId = packageNameIdIn;
    }

    /**
     * Get the crash package EVR id.
     * @return Returns the crash package EVR id.
     */
    public Long getPackageEvrId() {
        return packageEvrId;
    }

    /**
     * Set the crash package EVR id.
     * @param packageEvrIdIn The crash package EVR id to set.
     */
    public void setPackageEvrId(Long packageEvrIdIn) {
        packageEvrId = packageEvrIdIn;
    }

    /**
     * Get the crash package arch id.
     * @return Returns the crash package arch id.
     */
    public Long getPackageArchId() {
        return packageArchId;
    }

    /**
     * Set the crash package arch id.
     * @param packageArchIdIn The package arch id to set.
     */
    public void setPackageArchId(Long packageArchIdIn) {
        packageArchId = packageArchIdIn;
    }

    /**
     * Get the crash storage path.
     * @return Returns the crash storage path.
     */
    public String getStoragePath() {
        return storagePath;
    }

    /**
     * Set the crash storage path.
     * @param storagePathIn The storage path to set.
     */
    public void setStoragePath(String storagePathIn) {
        storagePath = storagePathIn;
    }

    /**
     * Get the crash absolute storage path.
     * @return Returns the crash storage path.
     */
    public String getAbsStoragePath() {
        return Config.get().getString(ConfigDefaults.MOUNT_POINT) + "/" + storagePath;
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

    /**
     * @return Returns the crash files.
     */
    public Set<CrashFile> getCrashFiles() {
        return crashFiles;
    }

    /**
     * @param cf The crash files to set.
     */
    public void setCrashFiles(Set<CrashFile> cf) {
        this.crashFiles = cf;
    }

}
