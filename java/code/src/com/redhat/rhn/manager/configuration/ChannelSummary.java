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
package com.redhat.rhn.manager.configuration;

import com.redhat.rhn.domain.action.config.ConfigDeployAction;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.server.Server;

/**
 * ChannelSummary
 * @version $Rev$
 * 
 * Data object to hold the values displayed for config-channel 
 * overview page.
 * 
 * Created and filled by ConfigurationManager
 * 
 */
public class ChannelSummary {
    
    private int numFiles;
    private int numDirs;
    private int numSymlinks;
    private int numSystems;
    private ConfigRevision mostRecentMod;
    private String recentFileDate;
    private ConfigDeployAction mostRecentDeploy;
    private String recentDeployDate;
    private Server mostRecentSystem;
    private String recentSystemDate;
    
    ChannelSummary() {
        super();
    }

    /**
     * Get the most-recent deploy action for a channel
     * @return the deploy-action
     */
    public ConfigDeployAction getMostRecentDeploy() {
        return mostRecentDeploy;
    }

    /**
     * Set the most recent deploy-action for a channel
     * @param cda most recent deploy-action taken
     */
    public void setMostRecentDeploy(ConfigDeployAction cda) {
        this.mostRecentDeploy = cda;
    }
    
    /**
     * Return the most recent file-revision made in a channel
     * @return the most-recent COnfigRevision
     */
    public ConfigRevision getMostRecentMod() {
        return mostRecentMod;
    }

    /**
     * Set the most-recent-file-revision info
     * @param cr  most recebt revision created
     */
    public void setMostRecentMod(ConfigRevision cr) {
        this.mostRecentMod = cr;
    }

    /**
     * The system most recently subscribed to this channel
     * @return most-recent Server
     */
    public Server getMostRecentSystem() {
        return mostRecentSystem;
    }

    
    /**
     * Set the most-recently-subscribed server
     * @param srv most recent server subscribed
     */
    public void setMostRecentSystem(Server srv) {
        this.mostRecentSystem = srv;
    }

    
    /**
     * How many directories are contained in this channel?
     * @return number of files of type "directory" controlled by this channel
     */
    public int getNumDirs() {
        return numDirs;
    }

    /**
     * Set num-dirs contained in this channel
     * @param dirs how many dirs are contained in the channel
     */
    public void setNumDirs(int dirs) {
        this.numDirs = dirs;
    }

    /**
     * How many files are contained in this channel?
     * @return number of non-directories controlled by this channel
     */
    public int getNumFiles() {
        return numFiles;
    }

    /**
     * Set num-files in the specified channel
     * @param files how many files are contained in the channel
     */
    public void setNumFiles(int files) {
        this.numFiles = files;
    }

    /**
     * How many symlinks are contained in this channel?
     * @return number of symlinks contained in this channel
     */
    public int getNumSymlinks() {
        return numSymlinks;
    }

    /**
     * Set num-symlinks contained in this channel
     * @param symlinks how many symlinks are contained in this channel
     */
    public void setNumSymlinks(int symlinks) {
        this.numSymlinks = symlinks;
    }

    /**
     * How many systems are subscribed to this channel?
     * @return num of systems subscribed
     */
    public int getNumSystems() {
        return numSystems;
    }

    /**
     * Set num-systems subscribed to a specified channel
     * @param systems how many systems are subscribed to the channel
     */
    public void setNumSystems(int systems) {
        this.numSystems = systems;
    }
    
    /**
     * Set date when mostRecentSystem's relationship to this channel was affected
     * @param aDate date of the change, from rhnServerConfigChannel
     */
    public void setSystemDate(String aDate) {
        recentSystemDate = aDate;
    }

    /**
     * date when mostRecentSystem's relationship to this channel was affected
     * @return date of the change
     */
    public String getSystemDate() {
        return recentSystemDate;
    }

    /**
     * Set date when mostRecentMod happened
     * @param aDate date of the change
     */
    public void setRecentFileDate(String aDate) {
        recentFileDate = aDate;
    }

    /**
     * date when mostRecentMod happened
     * @return date of the change
     */
    public String getRecentFileDate() {
        return recentFileDate;
    }
    
    /**
     * Set date-string for when mostRecentDeploy happened
     * @param aDate date of the change
     */
    public void setRecentDeployDate(String aDate) {
        recentDeployDate = aDate;
    }

    /**
     * date-string for when mostRecentDeploy happened
     * @return date of the change
     */
    public String getRecentDeployDate() {
        return recentDeployDate;
    }
}
