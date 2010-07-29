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

/**
 * ConfigInfo - Class representation of the table rhnConfigInfo.
 * @version $Rev$
 */
public class ConfigInfo extends BaseDomainHelper {

    private Long id;
    private String username;
    private String groupname;
    private Long filemode;
    private String selinuxCtx;
    private ConfigFileName targetFileName;

    /**
     * protected constructor
     * Use the ConfigurationFactory to get new ConfigInfos
     */
    protected ConfigInfo() {

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
     * Getter for username
     * @return String to get
    */
    public String getUsername() {
        return this.username;
    }

    /**
     * Setter for username
     * @param usernameIn to set
    */
    public void setUsername(String usernameIn) {
        this.username = usernameIn;
    }

    /**
     * Getter for groupname
     * @return String to get
    */
    public String getGroupname() {
        return this.groupname;
    }

    /**
     * Setter for groupname
     * @param groupnameIn to set
    */
    public void setGroupname(String groupnameIn) {
        this.groupname = groupnameIn;
    }

    /**
     * Getter for filemode
     * @return Long to get
    */
    public Long getFilemode() {
        return this.filemode;
    }

    /**
     * Setter for filemode
     * @param filemodeIn to set
    */
    public void setFilemode(Long filemodeIn) {
        this.filemode = filemodeIn;
    }

    /**
     * Getter for selinux context
     * @return String to get
    */
    public String getSelinuxCtx() {
        return this.selinuxCtx;
    }

    /**
     * Setter for selinux context
     * @param ctxIn to set
    */
    public void setSelinuxCtx(String ctxIn) {
        this.selinuxCtx = ctxIn;
    }

    /**
     * @param targetFileNameIn The targetFileName to set.
     */
    public void setTargetFileName(ConfigFileName targetFileNameIn) {
        this.targetFileName = targetFileNameIn;
    }

    /**
     * @return Returns the targetFileName.
     */
    public ConfigFileName getTargetFileName() {
        return targetFileName;
    }
}
