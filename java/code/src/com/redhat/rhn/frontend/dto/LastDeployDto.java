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

import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.config.ConfigurationFactory;

import java.util.Date;

/**
 * LastDeployDto - information about the last sucessful deploy of a given filename to a
 * specific server.  See config_queries.successful_deploys_for
 * @version $Rev$
 */
public class LastDeployDto extends BaseDto {

    private Long id;
    private Long fileId;
    private Long revId;
    private Date       when;
    private Long whenceId;
    private String     who;

    /**
     * {@inheritDoc}
     */
    public Long getId() {
        return id;
    }

    /**
     * get the file-id of the last-deployed-file
     * @return db id
     */
    public Long getFileId() {
        return fileId;
    }

    /**
     * Set the file-id of the last-deployed file
     * @param inFileId db id
     */
    public void setFileId(Long inFileId) {
        this.fileId = inFileId;
    }

    /**
     * Get the config-revision-id of the last-deployed revision
     * @return config-revision-id
     */
    public Long getRevId() {
        return revId;
    }

    /**
     * Set the db-id of the last-deployed config-revision
     * @param inRevId new dbid
     */
    public void setRevId(Long inRevId) {
        this.revId = inRevId;
    }

    /**
     * Get the date of the last successful deploy
     * @return success-date of the deploy
     */
    public Date getWhen() {
        return when;
    }

    /**
     * Set the date of the last-sucessful deploy
     * @param inWhen date of deploy
     */
    public void setWhen(Date inWhen) {
        this.when = inWhen;
    }

    /**
     * Get the id of the config-channel the file was deployed from
     * @return config-channel dbid
     */
    public Long getWhenceId() {
        return whenceId;
    }

    /**
     * Set the id of the config-channel the deploy came from
     * @param inWhenceId config-channel dbid
     */
    public void setWhenceId(Long inWhenceId) {
        this.whenceId = inWhenceId;
    }

    /**
     * Get the username of the user that scheduled the deploy
     * @return user-name
     */
    public String getWho() {
        return who;
    }

    /**
     * Set the user-name of the user that scheduled this deploy
     * @param inWho user-name
     */
    public void setWho(String inWho) {
        this.who = inWho;
    }

    /**
     * Get the config-channel the file was deployed from
     * @return config-channel
     */
    public ConfigChannel getChannel() {
        ConfigChannel cc = ConfigurationFactory.lookupConfigChannelById(
                new Long(whenceId.longValue()));
        return cc;
    }

    /**
     * Get the config-revision that was deployed
     * @return config-revision
     */
    public ConfigRevision getConfigRevision() {
        ConfigRevision cr = ConfigurationFactory.lookupConfigRevisionById(
                new Long(revId.longValue()));
        return cr;
    }
}
