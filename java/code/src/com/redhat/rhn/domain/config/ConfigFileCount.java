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
package com.redhat.rhn.domain.config;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

/**
 * Helper class to hold the number of files and directories
 * Mainly used by ConfigManagger & OverviewAction page.
 * ConfigFileCount
 * @version $Rev$
 */
public class ConfigFileCount {
    private long files;
    private long directories;
    
    /**
     * Creates a new instance of this class 
     * @param files the files to set
     * @param directories dirs to set
     * @return a new ConfigFileCount object using the params passed in
     */
    public static ConfigFileCount create(long files, long directories) {
        ConfigFileCount  cf = new  ConfigFileCount();
        cf.setFiles(files);
        cf.setDirectories(directories);
        return cf;
    }
    /**
     * 
     * @return the number of dirs
     */
    public long getDirectories() {
        return directories;
    }
    /**
     * 
     * @param directories the number dirs to set
     */
    private void setDirectories(long dirs) {
        this.directories = dirs;
    }
    /**
     * 
     * @return the number of files
     */
    public long getFiles() {
        return files;
    }
    /**
     * 
     * @param files the number of files to set
     */
    private void setFiles(long numFiles) {
        this.files = numFiles;
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public boolean equals(Object obj) {
        if (!(obj instanceof ConfigFileCount)) {
            return false;
        }
        ConfigFileCount that = (ConfigFileCount) obj;
        return new EqualsBuilder().
                    append(files, that.files).
                    append(directories, that.directories).
                    isEquals();
                    
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().
                        append(files).
                        append(directories).
                        toHashCode();
    }
}
