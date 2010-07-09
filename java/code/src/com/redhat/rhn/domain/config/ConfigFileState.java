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
 * ConfigFileState - Class representation of the table rhnConfigFileState.
 * @version $Rev$
 */
public class ConfigFileState extends BaseDomainHelper {

    private Long id;
    private String label;
    private String name;

    public static final String NORMAL =  "alive";
    public static final String DEAD =  "dead";

    /**
     *
     * @return the alive ConfigFileState
     */
    public static ConfigFileState normal() {
        return ConfigurationFactory.lookupConfigFileStateByLabel(NORMAL);
    }

    /**
     *
     * @return the dead ConfigFileState
     */
    public static ConfigFileState dead() {
        return ConfigurationFactory.lookupConfigFileStateByLabel(DEAD);
    }
    /**
     * protected constructor.
     * Use ConfigurationFactory to get ConfigFileStates.
     */
    protected ConfigFileState() {

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
     * Getter for label
     * @return String to get
    */
    public String getLabel() {
        return this.label;
    }

    /**
     * Setter for label
     * @param labelIn to set
    */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }

    /**
     * Getter for name
     * @return String to get
    */
    public String getName() {
        return this.name;
    }

    /**
     * Setter for name
     * @param nameIn to set
    */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

}
